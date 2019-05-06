#include "dft.h"


// API ENDPOINTS

// "blur" the values of a 2d array
void blur(image* img) {
  char** data = img->data;

  // allocate an array of complex numbers for DFT operations
  int width_pow_2 = 1;
  while (width_pow_2 < img->width) width_pow_2 *= 2;
  int height_pow_2 = 1;
  while (height_pow_2 < img->height) height_pow_2 *= 2;
  complex zero;
  zero.real = 0.0;
  zero.imaginary = 0.0;

  complex* red = (complex*)malloc(width_pow_2 * height_pow_2 * sizeof(complex));
  complex* green = (complex*)malloc(width_pow_2 * height_pow_2 * sizeof(complex));
  complex* blue = (complex*)malloc(width_pow_2 * height_pow_2 * sizeof(complex));

  complex** arr = (complex**)malloc(3 * sizeof(complex*));
  arr[0] = red;
  arr[1] = green;
  arr[2] = blue;

  for (int color = 0; color < 3; color++) {
    for (int y = 0; y < height_pow_2; y++) {
      int row_offset = y * width_pow_2;
      for (int x = 0; x < width_pow_2; x++) {
        int offset = row_offset + x;

        arr[color][offset] = zero;
      }
    }
  }

  carray2d carr_red;
  carr_red.arr = red;
  carr_red.x = width_pow_2;
  carr_red.y = height_pow_2;

  carray2d carr_green;
  carr_green.arr = green;
  carr_green.x = width_pow_2;
  carr_green.y = height_pow_2;

  carray2d carr_blue;
  carr_blue.arr = blue;
  carr_blue.x = width_pow_2;
  carr_blue.y = height_pow_2;

  carray2d* carr = (carray2d*)malloc(3 * sizeof(carray2d));
  carr[0] = carr_red;
  carr[1] = carr_green;
  carr[2] = carr_blue;

  // create gaussian kernel
  complex* kernel = get_gaussian_kernel(img->height, img->width, 1, 1);

  // FFT on kernel
  carray2d karr;
  karr.arr = kernel;
  karr.y = height_pow_2;
  karr.x = width_pow_2;
  dft_row(&karr, false);
  dft_col(&karr, false);

  // convert data into complex numbers
  // TODO: move into helper function
  printf("blur: Converting RGB data into complex numbers\n");
  for (int color = 0; color < 3; color++) {
    for (int y = 0; y < img->height; y++) {
      int row_data = y * img->bytespercolor * img->width;
      int row_arr = y * width_pow_2;

      for (int x = 0; x < img->width; x++) {
        int col_data = x * img->bytespercolor;
        int col_arr = x;
        int offset_data = row_data + col_data;
        int offset_arr = row_arr + col_arr;

        unsigned int value = 0;
        for (int i = 0; i < img->bytespercolor; i++) {
          value *= 256;
          value += (unsigned int)(data[color][offset_data + i]);
        }
        double dvalue = (double)value;
        for (int i = 0; i < img->bytespercolor; i++) {
          dvalue /= 256.0;
        }

        complex cvalue;
        cvalue.real = dvalue;
        cvalue.imaginary = 0.0;

        arr[color][offset_arr] = cvalue;
      }
    }
  }

  // blur the image
  char* red_s = "red";
  char* green_s = "green";
  char* blue_s = "blue";
  char** colors_s = (char**)malloc(3 * sizeof(char*));
  colors_s[0] = red_s;
  colors_s[1] = green_s;
  colors_s[2] = blue_s;

  for (int i = 0; i < 3; i++) {
    printf("blur: beginning DFT on %s pixels\n", colors_s[i]);

    printf("blur: DFT by row\n");
    dft_row(carr + i, false);

    printf("blur: DFT by column\n");
    dft_col(carr + i, false);

    printf("blur: round\n");
    //round(carr + i, 0.0);
    for (int y = 0; y < img->height; y++) {
      for (int x = 0; x < img->width; x++) {
        int idx = y * width_pow_2 + x;
//        arr[i][idx] = complex_mult(kernel + idx, (arr[i]) + idx);
      }
    }

    printf("blur: inverse DFT by column\n");
    dft_col(carr + i, true);

    printf("blur: inverse DFT by row\n");
    dft_row(carr + i, true);
  }

  // convert back to data
  // TODO: move into helper function
  printf("blur: converting complex numbers to RGB\n");
  for (int color = 0; color < 3; color++) {
    for (int y = 0; y < img->height; y++) {
      int row_data = y * img->bytespercolor * img->width;
      int row_arr = y * width_pow_2;

      for (int x = 0; x < img->width; x++) {
        int col_data = x * img->bytespercolor;
        int col_arr = x;

        int offset_data = row_data + col_data;
        int offset_arr = row_arr + col_arr;

        // the following code assumes bytespercolor is equal to 1 (todo?)
        complex cvalue = arr[color][offset_arr];
        double abs_val = complex_abs(&cvalue);
        unsigned int int_val = (unsigned int)(abs_val * 256.0);
        char next_char = (char)(int_val);
        data[color][offset_data] = next_char;
      }
    }
  }

  // cleanup
  free(red);
  free(green);
  free(blue);
  free(arr);
  free(kernel);
}



// BLUR HELPERS

// DFT by row
void dft_row(carray2d* carr, bool inv) {
  complex* arr = carr->arr;

  // generate padded array
  int least_pow_2 = 1;
  while (least_pow_2 < carr->x) {
    least_pow_2 *= 2;
  }
  complex zero;
  zero.real = 0.0;
  zero.imaginary = 0.0;
  complex* padded_row = (complex*)malloc(least_pow_2 * sizeof(complex));

  // for every row
  for (int i = 0; i < carr->y; i++) {
    int row_offset = carr->x * i;
    complex* row = arr + row_offset;

    // copy into padded array
    for (int j = 0; j < least_pow_2; j++) {
      if (j < carr->x) {
        padded_row[j] = row[j];
      }
      else {
        padded_row[j] = zero;
      }
    }

    // perform FFT
    carray1d crow;
    crow.arr = padded_row;
    crow.x = least_pow_2;
    fft(&crow, inv);

    // copy back from padded array
    for (int j = 0; j < carr->x; j++) {
      row[j] = padded_row[j];
    }
  }

  free(padded_row);
}

// DFT by column
void dft_col(carray2d* carr, bool inv) {
  complex* arr = carr->arr;

  // generate padded array
  int least_pow_2 = 1;
  while (least_pow_2 < carr->y) {
    least_pow_2 *= 2;
  }
  complex zero;
  zero.real = 0.0;
  zero.imaginary = 0.0;
  complex* padded_col = (complex*)malloc(least_pow_2 * sizeof(complex));

  // for every column
  for (int i = 0; i < carr->x; i++) {

    // copy into padded array
    for (int j = 0; j < least_pow_2; j++) {
      if (j < carr->y) {
        padded_col[j] = arr[j * carr->x + i];
      }
      else {
        padded_col[j] = zero;
      }
    }

    // perform FFT
    carray1d ccol;
    ccol.arr = padded_col;
    ccol.x = least_pow_2;
    fft(&ccol, inv); // transform array

    // copy back from padded array
    for (int j = 0; j < carr->y; j++) {
      arr[j * carr->x + i] = padded_col[j];
    }
  }

  free(padded_col);
}

// remove data based on distance from the corner
void round(carray2d* carr, double round_factor) {
  complex* arr = carr->arr;

  //double max_d = round_factor * (double)(carr->x); // temp
  //double max = (double)round(max_d);
  double a = round_factor * (double)(carr->x);
  double asq = a * a;
  double b = round_factor * (double)(carr->y);
  double bsq = b * b;

  for (int y = 0; y < carr->y; y++) {
    int y2 = carr->y - 1 - y;
    double min_y = (double)(y < y2 ? y : y2);

    for (int x = 0; x < carr->x; x++) {
      int x2 = carr->x - 1 - x;
      double min_x = (double)(x < x2 ? x : x2);

      //double sum_of_squares = min_y * min_y + min_x * min_x;
      //double sqrt_of_sum = sqrt(sum_of_squares);
      double ellipse = (min_x * min_x / asq) + (min_y * min_y / bsq);

      if (ellipse <= 1.0) {
        complex czero;
        czero.real = 0.0;
        czero.imaginary = 0.0;

        arr[y * carr->x + x] = czero;
      }
    }
  }
}

// round absolute value of a complex back to int
void normalize(carray2d* carr) {

}

// create gaussian kernel for blurring
complex* get_gaussian_kernel(int rows, int cols, double sigmax, double sigmay) {
  int rows_pow_2 = 1;
  while (rows_pow_2 < rows) rows_pow_2 *= 2;
  int cols_pow_2 = 1;
  while (cols_pow_2 < cols) cols_pow_2 *= 2;

  complex* kernel = (complex*)malloc(rows_pow_2 * cols_pow_2 * sizeof(complex));
  complex zero;
  zero.real = 0.0;
  zero.imaginary = 0.0;
  for (int j = 0; j < rows_pow_2; j++) {
    for (int i = 0; i < cols_pow_2; i++) {
      kernel[j * cols_pow_2 + i] = zero;
    }
  }

  double meanj = rows/2;
  double meani = cols/2;
  double sum = 0.0;
  double temp = 0.0;

  int sigma = 2 * sigmay * sigmax;

  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < cols; i++) {
      //temp = exp( -((j-meanj)*(j-meanj) + (i-meani)*(i-meani))  / (sigma));
      temp = exp( -0.5 * (pow((j-meanj)/sigma, 2.0) + pow((i-meani)/sigma,2.0)) ) / (2 * M_PI * sigma * sigma);
      complex c;
      c.real = temp;
      c.imaginary = 0.0;
      kernel[j * cols_pow_2 + i] = c;
      sum += temp;
    }
  }

  double scale = 1.0 / sum;
  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < cols; i++) {
      kernel[j * cols_pow_2 + i] = complex_scale(kernel + (j * cols_pow_2 + i), scale);
    }
  }

  return kernel;
}



// DFT HELPERS
void fft(carray1d* carr, bool inv) {
  complex* arr = carr->arr;
  int* all_indices = (int*)malloc(carr->x * sizeof(int));
  for (int i = 0; i < carr->x; i++) {
    all_indices[i] = i;
  }

  complex* new_arr = fft_recursive(arr, all_indices, carr->x, inv);
  for (int i = 0; i < carr->x; i++) {
    arr[i] = new_arr[i];
  }

  if (inv) {
    double scale = 1.0 / (double)(carr->x);
    for (int i = 0; i < carr->x; i++) {
      arr[i] = complex_scale(arr + i, scale);
    }
  }

  free(new_arr);
  free(all_indices);
}
complex* fft_recursive(complex* arr, int* indices, int indices_len, bool inv) {
  complex* result;

  // base case N=1
  if (indices_len == 1) {
    result = (complex*)malloc(indices_len * sizeof(complex));
    result[0] = arr[indices[0]];
    return result;
  }

  // split into even and odd
  int groupsize = indices_len / 2;
  int* even_indices = (int*)malloc(groupsize * sizeof(int));
  int* odd_indices = (int*)malloc(groupsize * sizeof(int));
  for (int i = 0; i < groupsize; i++) {
    even_indices[i] = indices[i * 2];
    odd_indices[i] = indices[i * 2 + 1];
  }

  // recurse
  complex* even = fft_recursive(arr, even_indices, groupsize, inv);
  complex* odd = fft_recursive(arr, odd_indices, groupsize, inv);

  // combine
  result = dft_combine(even, odd, groupsize, inv);

  // cleanup
  free(even_indices);
  free(odd_indices);
  free(even);
  free(odd);

  return result;
}
complex* dft_combine(complex* even, complex* odd, int groupsize, bool inv) {
  int N = 2 * groupsize;

  complex* result = (complex*)malloc(N * sizeof(complex));


  for (int k = 0; k < groupsize; k++) {
    complex o = odd[k];
    complex e = even[k];

    complex factor = exp_to_complex(k, N, inv);
    complex o_factor = complex_mult(&o, &factor);

    result[k] = complex_add(&e, &o_factor);
    result[k + groupsize] = complex_sub(&e, &o_factor);
  }

  return result;
}
