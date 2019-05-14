#include "dft.h"

// KERNELS

__global__ void dft_gpu(complex* arr, int dimx, int dimy, bool inv, bool by_row) {
  // initialize things specific to the block and the type of FFT (by row, by col)
  int n; // length of row or column
  int num_lists;
  int list_idx = blockIdx.x; // which row or column we are on
  int list_offset; // the difference between the start of the array and the list
  int list_dx; // the difference between two items on the row or column
  if (by_row) {
    n = dimx;
    num_lists = dimy;
    list_offset = dimx * list_idx;
    list_dx = 1;
  }
  else {
    n = dimy;
    num_lists = dimx;
    list_offset = list_idx;
    list_dx = dimx;
  }

  // get logN
  int m_temp = 1;
  int logn = 0;
  while (m_temp < n) {
    m_temp *= 2;
    logn += 1;
  }

  for (int level = 1; level <= logn; level++) {
    int offset_old = (level - 1) * dimx * dimy + list_offset; // absolute offset of list
    int offset_new = offset_old + dimx * dimy; // same offset, moved up one level

    int oldSize = pow(2, level - 1);
    int newSize = 2 * oldSize; // the size of the group we are expanding into
    int dx = n / newSize; // difference b/w two items in a list to be combined
    int base = threadIdx.x % dx; // first element in the list
    int x = (threadIdx.x / dx) * (2 * dx) + base; // the lower of the two elements this thread will combine
    int k = x / (2 * dx); // the index of x within the old list
    //int k_new = x / dx; // within the new list


    if (threadIdx.x < n/2 && blockIdx.x < num_lists) {
      // offsets of the values to be read and then written
      int in1_offset = x * list_dx;
      int in2_offset = (x + dx) * list_dx;
      int out1_offset = (base + k * dx) * list_dx;
      int out2_offset = (base + (k + oldSize) * dx) * list_dx;

      complex e = arr[offset_old + in1_offset];
      complex o = arr[offset_old + in2_offset];

      // exp_to_complex inlined
      double exponent = -2 * M_PI * k / newSize;
      if (inv) exponent *= -1;
      complex factor;
      factor.real = cos(exponent);
      factor.imaginary = sin(exponent);

      // complex_mult inlined
      complex o_factor;
      o_factor.real = o.real * factor.real - o.imaginary * factor.imaginary;
      o_factor.imaginary = o.real * factor.imaginary + o.imaginary * factor.real;

      __syncthreads();
      // complex_add inlined
      (arr[offset_new + out1_offset]).real = e.real + o_factor.real;
      (arr[offset_new + out1_offset]).imaginary = e.imaginary + o_factor.imaginary;

      // complex_sub inlined
      (arr[offset_new + out2_offset]).real = e.real - o_factor.real;
      (arr[offset_new + out2_offset]).imaginary = e.imaginary - o_factor.imaginary;
      __syncthreads();
    }

  }

  // scale at very end, only once
  if (inv && threadIdx.x < n) {
    int scales_per_thd = 1;
    if (n > blockDim.x) {
      scales_per_thd = n / blockDim.x;
    }
    double scale = 1.0 / (double)n;
    for (int i = 0; i < scales_per_thd; i++) {
      int offset = threadIdx.x + i * blockDim.x;
      (arr[logn * n + offset]).real *= scale;
      (arr[logn * n + offset]).imaginary *= scale;
    }
  }
}


// API ENDPOINTS

// "blur" the values of a 2d array
void blur(image* img, bool parallel) {
  unsigned char** data = img->data;

  // allocate an array of complex numbers for DFT operations
  int width_pow_2 = 1;
  while (width_pow_2 < img->width) width_pow_2 *= 2;
  int height_pow_2 = 1;
  while (height_pow_2 < img->height) height_pow_2 *= 2;

  printf("Allocating array of %d by %d\n", width_pow_2, height_pow_2);
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
  double sigma = 10;
  complex* kernel = get_gaussian_kernel(25, 25, height_pow_2, width_pow_2, sigma);

  // FFT on kernel
  carray2d karr;
  karr.arr = kernel;
  karr.y = height_pow_2;
  karr.x = width_pow_2;

  printf("kernel: DFT by row\n");
  dft_row(&karr, false, parallel);
  printf("kernel: DFT by column\n");
  dft_col(&karr, false, parallel);

  // convert data into complex numbers
  // TODO: move into helper function
  printf("blur: Converting RGB data into complex numbers\n");
  for (int color = 0; color < 3; color++) {
    for (int y = 0; y < img->height; y++) {
      int row_data = y * img->width;
      int row_arr = y * width_pow_2;

      for (int x = 0; x < img->width; x++) {
        int col_data = x;
        int col_arr = x;
        int offset_data = row_data + col_data;
        int offset_arr = row_arr + col_arr;

        unsigned int value = (unsigned int)(data[color][offset_data]);
        double dvalue = (double)value;
        dvalue /= 256.0;

        complex cvalue;
        cvalue.real = dvalue;
        cvalue.imaginary = 0;

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
    dft_row(carr + i, false, parallel);

    printf("blur: DFT by column\n");
    dft_col(carr + i, false, parallel);

    printf("blur: apply filter\n");
    for (int y = 0; y < height_pow_2; y++) {
      int row_offset = y * width_pow_2;
      for (int x = 0; x < width_pow_2; x++) {
        int offset = row_offset + x;
        complex c1 = kernel[offset];
        complex c2 = arr[i][offset];
        arr[i][offset] = complex_mult(&c1, &c2);
      }
    }

    printf("blur: inverse DFT by column\n");
    dft_row(carr + i, true, parallel);

    printf("blur: inverse DFT by row\n");
    dft_col(carr + i, true, parallel);
  }


  // convert back to data
  // TODO: move into helper function
  printf("blur: converting complex numbers to RGB\n");
  for (int color = 0; color < 3; color++) {
    for (int y = 0; y < img->height; y++) {
      int row_data = y * img->width;
      int row_arr = y * width_pow_2;

      for (int x = 0; x < img->width; x++) {
        int col_data = x;
        int col_arr = x;

        int offset_data = row_data + col_data;
        int offset_arr = row_arr + col_arr;

        complex cvalue = arr[color][offset_arr];
        double abs_val = complex_abs(&cvalue);
        unsigned int int_val = (unsigned int)(abs_val * 256);
        unsigned char next_char = (unsigned char)(int_val);

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
void dft_row(carray2d* carr, bool inv, bool parallel) {
  complex* arr = carr->arr;
  int len = 1;
  int loglen = 0;
  while (len < carr->x) {
    len *= 2;
    loglen += 1;
  }

  complex* garr;
  if (parallel) {
    cudaMalloc((void**) &garr, carr->x * carr->y * (loglen + 1) * sizeof(complex));

    cudaMemcpy(garr, arr, carr->x * carr->y * sizeof(complex), cudaMemcpyHostToDevice);
    dft_gpu<<<1024, 1024>>>(garr, carr->x, carr->y, inv, true);
    int offset = carr->x * carr->y * (loglen);
    cudaMemcpy(arr, garr + offset, carr->x * carr->y * sizeof(complex), cudaMemcpyDeviceToHost);
    return;
  }


  // for every row
  complex* row = (complex*)malloc(len * sizeof(complex));
  for (int i = 0; i < carr->y; i++) {
    int row_offset = len * i;
    complex* arow = arr + row_offset;

    // copy into array
    for (int j = 0; j < len; j++) {
      row[j] = arow[j];
    }

    carray1d crow;
    crow.arr = row;
    crow.x = len;
    fft(&crow, inv);

    // copy back from padded array
    for (int j = 0; j < len; j++) {
      arow[j] = row[j];
    }
  }

  free(row);
  cudaFree(garr);
}

// DFT by column
void dft_col(carray2d* carr, bool inv, bool parallel) {
  complex* arr = carr->arr;
  int len = 1;
  int loglen = 0;
  while (len < carr->y) {
    len *= 2;
    loglen += 1;
  }

  complex* garr;
  if (parallel) {
    cudaMalloc((void**) &garr, carr->x * carr->y * (loglen + 1) * sizeof(complex));

    cudaMemcpy(garr, arr, carr->x * carr->y * sizeof(complex), cudaMemcpyHostToDevice);
    dft_gpu<<<2048, 512>>>(garr, carr->x, carr->y, inv, false);
    int offset = carr->x * carr->y * (loglen);
    cudaMemcpy(arr, garr + offset, carr->x * carr->y * sizeof(complex), cudaMemcpyDeviceToHost);
    return;
  }

  // for every column
  complex* col = (complex*)malloc(len * sizeof(complex));;
  for (int i = 0; i < carr->x; i++) {
    // copy into array
    for (int j = 0; j < len; j++) {
      col[j] = arr[j * carr->x + i];
    }

    // perform FFT
    carray1d ccol;
    ccol.arr = col;
    ccol.x = len;
    fft(&ccol, inv); // transform array

    // copy back from padded array
    for (int j = 0; j < len; j++) {
      arr[j * carr->x + i] = col[j];
    }
  }

  free(col);
  cudaFree(garr);
}

// create gaussian kernel for blurring
complex* get_gaussian_kernel(int height, int width, int height_pow_2, int width_pow_2, double sigma) {
  printf("Generating Gaussian kernel of %d by %d\n", width_pow_2, height_pow_2);

  // initialize to zero
  complex* kernel = (complex*)malloc(height_pow_2 * width_pow_2 * sizeof(complex));
  complex zero;
  zero.real = 0.0;
  zero.imaginary = 0.0;
  for (int y = 0; y < height_pow_2; y++) {
    for (int x = 0; x < width_pow_2; x++) {
      kernel[y * width_pow_2 + x] = zero;
    }
  }

  double meany = height/2;
  double meanx = width/2;
  double sum = 0.0;
  double temp = 0.0;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int row = y - height / 2;
      if (row < 0) row += height_pow_2;
      int col = x - width / 2;
      if (col < 0) col += width_pow_2;
      int offset = row * width_pow_2 + col;

      temp = exp( -0.5 * (pow((x-meanx)/sigma, 2.0) + pow((y-meany)/sigma,2.0)) )
                         / (2 * M_PI * sigma * sigma);
      complex c;
      c.real = temp;
      c.imaginary = 0.0;
      kernel[offset] = c;
      sum += temp;
    }
  }

  // scale result so all elements add up to 1
  double scale = 1.0 / sum;
  for (int y = 0; y < height_pow_2; y++) {
    for (int x = 0; x < width_pow_2; x++) {
      int offset = y * width_pow_2 + x;
      kernel[offset] = complex_scale(kernel + (offset), scale);
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
