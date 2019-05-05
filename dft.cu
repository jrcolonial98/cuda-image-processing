#include "dft.h"


// API ENDPOINTS

// "blur" the values of a 2d array
void blur(image* img) {
  char** data = img->data;

  // allocate an array of complex numbers for DFT operations
  complex* red = (complex*)malloc(dim.x * dim.y * sizeof(complex));
  complex* green = (complex*)malloc(dim.x * dim.y * sizeof(complex));
  complex* blue = (complex*)malloc(dim.x * dim.y * sizeof(complex));

  complex* arr[3] = (complex**)malloc(3 * sizeof(complex*));
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

  carray2d* carr[3] = (carray2d**)malloc(3 * sizeof(carray2d*));
  carr[0] = carr_red;
  carr[1] = carr_green;
  carr[2] = carr_blue;


  // convert data into complex numbers
  // TODO: move into helper function
  for (int color = 0; color < 3; color++) {
    for (int y = 0; y < bdata->height; y++) {
      int row_data = y * img->bytespercolor * dim.x;
      int row_arr = y * dim.x;

      for (int x = 0; x < bdata->width; x++) {
        int col_data = x * img->bytespercolor;
        int col_arr = x;
        int offset_data = row_data + col_data;
        int offset_arr = row_arr + col_arr;

        int value = 0;
        for (int i = 0; i < bytespercolor; i++) {
          value *= 256;
          value += (int)(data[color][offset_data + i]);
        }

        complex cvalue;
        cvalue.real = (double)value;
        cvalue.imaginary = 0.0;

        arr[color][offset_arr] = cvalue;
      }
    }
  }

  // blur the image
  for (int i = 0; i < 3; i++) {
    dft_row(carr + i);
    dft_col(carr + i);
    round(carr + i);
    dft_inv_col(carr + i);
    dft_inv_row(carr + i);
  }

  // normalize the data and convert back
  normalize(img, carr);

  // cleanup
  free(red);
  free(green);
  free(blue);
  free(arr);
}



// BLUR HELPERS

// DFT by row
void dft_row(carray2d* carr) {
  complex* arr = carr->arr;

  for (int i = 0; i < carr->y; i++) { // for every row
    int row_offset = carr->x * i;
    complex* row = arr + row_offset;

    carray1d crow;
    crow->arr = row;
    crow->x = carr->x;

    fft(crow, false);
  }
}

// DFT by column
//void dft_col(carray2d* carr);

// inverse DFT by row
//void dft_inv_row(carray2d* carr);

// inverse DFT by column
//void dft_inv_col(carray2d* carr);

// remove data based on distance from the corner
//void round(carray2d* carr);

// round absolute value of a complex back to int
//void normalize(carray2d* carr);



// DFT HELPERS
void fft(carray1d carr, bool inv) {
  complex* arr = carr->arr;
  int* all_indices = (int*)malloc(carr->x * sizeof(int));
  for (int i = 0; i < carr->x; i++) {
    all_indices[i] = i;
  }

  complex* new_arr = fft_recursive(carr, all_indices, inv);
  carr->arr = new_arr;

  if (inv) {
    double scale = 1.0 / (double)(carr->x);
    for (int i = 0; i < carr->x; i++) {
      arr[i] = complex_scale(arr + i, scale);
    }
  }

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
  int NUM_GROUPS = 2; // temporary
  int groupsize = indices_len / NUM_GROUPS;
  int** index_groups = (int**)malloc(NUM_GROUPS * sizeof(int*));
  for (int i = 0; i < NUM_GROUPS; i++) {
    index_groups[i] = (int*)malloc(groupsize * sizeof(int));
    for (int j = 0; j < groupsize; j++) {
      int idx = j * NUM_GROUPS + i;
      index_groups[i][j] = indices[idx];
    }
  }

  // recurse
  complex** rec_results = (complex**)malloc(NUM_GROUPS * sizeof(complex*));
  for (int i = 0; i < NUM_GROUPS; i++) {
    rec_results[i] = fft_recursive(arr, index_groups[i], inv);
  }

  // combine
  result = combine(rec_results, NUM_GROUPS, groupsize, inv);

  // cleanup
  for (int i = 0; i < NUM_GROUPS; i++) {
    free(index_groups[i]);
    free(rec_results[i]);
  }
  free(index_groups);
  free(rec_results);

  return result;
}
complex* dft_combine(complex** arrs, int num_groups, int groupsize, bool inv) {
  complex* result = (complex*)malloc(num_groups * groupsize * sizeof(complex));

  for (int k = 0; k < groupsize; k++) {
    
  }
}
