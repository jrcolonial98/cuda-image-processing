#include "dft.h"


// API ENDPOINTS

// "blur" the values of a 2d array
void blur(image* img) {
  char** data = img->data;

  // allocate an array of complex numbers for DFT operations
  complex* red = (complex*)malloc(img->width * img->height * sizeof(complex));
  complex* green = (complex*)malloc(img->width * img->height * sizeof(complex));
  complex* blue = (complex*)malloc(img->width * img->height * sizeof(complex));

  complex** arr = (complex**)malloc(3 * sizeof(complex*));
  arr[0] = red;
  arr[1] = green;
  arr[2] = blue;

  carray2d carr_red;
  carr_red.arr = red;
  carr_red.x = img->width;
  carr_red.y = img->height;

  carray2d carr_green;
  carr_green.arr = green;
  carr_green.x = img->width;
  carr_green.y = img->height;

  carray2d carr_blue;
  carr_blue.arr = blue;
  carr_blue.x = img->width;
  carr_blue.y = img->height;

  carray2d* carr = (carray2d*)malloc(3 * sizeof(carray2d));
  carr[0] = carr_red;
  carr[1] = carr_green;
  carr[2] = carr_blue;


  // convert data into complex numbers
  // TODO: move into helper function
  printf("blur: Converting RGB data into complex numbers\n");
  for (int color = 0; color < 3; color++) {
    for (int y = 0; y < img->height; y++) {
      int row_data = y * img->bytespercolor * img->width;
      int row_arr = y * img->width;

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
    //dft_col(carr + i, false);

    printf("blur: round\n");
    //round(carr + i, 0.15);

    printf("blur: inverse DFT by column\n");
    //dft_col(carr + i, true);

    printf("blur: inverse DFT by row\n");
    dft_row(carr + i, true);
  }

  // convert back to data
  // TODO: move into helper function
  printf("blur: converting complex numbers to RGB\n");
  for (int color = 0; color < 3; color++) {
    for (int y = 0; y < img->height; y++) {
      int row_data = y * img->bytespercolor * img->width;
      int row_arr = y * img->width;

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
}



// BLUR HELPERS

// DFT by row
void dft_row(carray2d* carr, bool inv) {
  complex* arr = carr->arr;

  for (int i = 0; i < carr->y; i++) { // for every row
    int row_offset = carr->x * i;
    complex* row = arr + row_offset;

    carray1d crow;
    crow.arr = row;
    crow.x = carr->x;

    fft(&crow, inv);
  }
}

// DFT by column
void dft_col(carray2d* carr, bool inv) {
  complex* arr = carr->arr;

  for (int i = 0; i < carr->x; i++) { // for every column
    complex* column = (complex*)malloc(carr->x * sizeof(complex));
    for (int j = 0; j < carr->y; j++) { // copy into new array
      column[j] = arr[j * carr->x + i];
    }

    carray1d ccol;
    ccol.arr = column;
    ccol.x = carr->y;

    fft(&ccol, inv); // transform array

    for (int j = 0; j < carr->y; j++) { // copy back
      arr[j * carr->x + i] = column[j];
    }

    free(column);
  }
}

// remove data based on distance from the corner
void round(carray2d* carr, double round_factor) {
  complex* arr = carr->arr;

  double max = round_factor * (double)(carr->x); // temp
  double max_dist_squared = max * max;

  for (int y = 0; y < carr->y; y++) {
    double min_y = (double)(y < carr->y - 1 - y ? y : carr->y - 1 -y);

    for (int x = 0; x < carr->x; x++) {
      double min_x = (double)(x < carr->x - 1 - x ? x : carr->x - 1 - x);

      double sum_of_squares = min_y * min_y + min_x * min_x;

      if (sum_of_squares <= max_dist_squared) {
        int y2 = carr->y - 1 - y;
        int x2 = carr->x - 1 - x;

        complex czero;
        czero.real = 0.0;
        czero.imaginary = 0.0;

        arr[y * carr->x + x] = czero;
        arr[y * carr->x + x2] = czero;
        arr[y2 * carr->x + x] = czero;
        arr[y2 * carr->x + x2] = czero;
      }
      else {
        break; // move to next row
      }
    }
  }
}

// round absolute value of a complex back to int
void normalize(carray2d* carr) {

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

  // split into groups
  int num_groups = 2; // temporary
  while (indices_len % num_groups != 0) {
    num_groups++;
  }
  int groupsize = indices_len / num_groups;
  int** index_groups = (int**)malloc(num_groups * sizeof(int*));
  for (int i = 0; i < num_groups; i++) {
    index_groups[i] = (int*)malloc(groupsize * sizeof(int));
    for (int j = 0; j < groupsize; j++) {
      int idx = j * num_groups + i;
      index_groups[i][j] = indices[idx];
    }
  }

  // recurse
  complex** rec_results = (complex**)malloc(num_groups * sizeof(complex*));
  for (int i = 0; i < num_groups; i++) {
    rec_results[i] = fft_recursive(arr, index_groups[i], groupsize, inv);
  }

  // combine
  result = dft_combine(rec_results, num_groups, groupsize, inv);

  // cleanup
  for (int i = 0; i < num_groups; i++) {
    free(index_groups[i]);
    free(rec_results[i]);
  }
  free(index_groups);
  free(rec_results);

  return result;
}
complex* dft_combine(complex** arrs, int num_groups, int groupsize, bool inv) {
  int N = num_groups * groupsize;

  complex* result = (complex*)malloc(N * sizeof(complex));


  for (int k = 0; k < N; k++) {
    complex total;
    total.real = 0.0;
    total.imaginary = 0.0;

    for (int i = 0; i < num_groups; i++) {
      int idx = i * groupsize + (k % groupsize);
      complex num = result[idx];
      complex factor = exp_to_complex(k * i, N, inv);
      complex num_times_factor = complex_mult(&factor, &num);

      total = complex_add(&total, &num_times_factor);
    }

    result[k] = total;
  }

  return result;
}
