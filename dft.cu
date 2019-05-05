#include "dft.h"


// API ENDPOINTS

// "blur" the values of a 2d array
void blur(image* img) {
  char** data = img->data;

  // allocate an array of complex numbers for DFT operations
  carray2d carr;

  complex* red = (complex*)malloc(dim.x * dim.y * sizeof(complex));
  complex* green = (complex*)malloc(dim.x * dim.y * sizeof(complex));
  complex* blue = (complex*)malloc(dim.x * dim.y * sizeof(complex));

  complex* arr[3] = (complex**)malloc(3 * sizeof(complex*));
  arr[0] = red;
  arr[1] = green;
  arr[2] = blue;

  carr.arr = arr;
  carr.x = img->width;
  carr.y = img->height;


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
  dft_row(&carr);
  dft_col(&carr);
  round(&carr);
  dft_inv_col(&carr);
  dft_inv_row(&carr);

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
//void dft_row(carray2d* carr);

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
//complex* fft(carray1d carr, bool inv);
//complex* fft_recursive(carray1d carr, int* indices, int indices_len, bool inv);
//complex* dft_combine(carray1d carr_odd, carray1d carr_even, bool inv);
