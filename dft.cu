#include "dft.h"
#include "bmp.h"


// API ENDPOINTS

// "blur" the values of a 2d array
int** blur(complex** arr, dim_2d dim);



// BLUR HELPERS

complex** dft_row(complex** arr, dim_2d dim);

// DFT by column
complex** dft_col(complex** arr, dim_2d dim);

// inverse DFT by row
complex** dft_inv_row(complex** arr, dim_2d dim);

// inverse DFT by column
complex** dft_inv_col(complex** arr, dim_2d dim);

// remove data based on distance from the corner
complex** round(complex** arr, dim_2d dim);

// round absolute value of a complex back to int
int** normalize(complex** arr, dim_2d dim);



// DFT HELPERS
complex* fft(complex* x, dim_1d dim, bool inv);
complex* fft_recursive(complex* x, int* indices, dim_1d idim, bool inv);
complex* dft_combine(complex* odd, complex* even, dim_1d dim, bool inv);



// MISC

char** extract_rgb_cpu(bmp* bdata) {
  char* data = bdata->data;
  int bytespercolor = bdata->bitsperpixel / 24; // generally equals 1
  int bytesperrow_new = bytespercolor * bdata->width;
  int bytesperrow_old = bytesperrow_new * 3;
  while (bytesperrow_old % 4 != 0) { // BMP format requires row length % 4 == 0
    bytesperrow_old++;
  }  
  int bytesperpixel = bytespercolor * 3; // generall equals 3

  char* red = (char*)malloc(bdata->width * bdata->height * bytespercolor);
  char* green = (char*)malloc(bdata->width * bdata->height * bytespercolor);
  char* blue = (char*)malloc(bdata->width * bdata->height * bytespercolor);

  char** converted_data = (char**)malloc(3 * sizeof(char*));
  converted_data[0] = red;
  converted_data[1] = green;
  converted_data[2] = blue;

  for (int color = 0; color < 3; color++) {
    int color_old = color * bytespercolor;

    for (int y = 0; y < bdata->height; y++) {
      int row_old = y * bytesperrow_old;
      int row_new = y * bytesperrow_new;

      for (int x = 0; x < bdata->width; x++) {
        int col_old = x * bytesperpixel;
        int col_new = x * bytespercolor;
        int offset_old = row_old + col_old + color_old;
        int offset_new = row_new + col_new;

        for (int i = 0; i < bytespercolor; i++) {
          converted_data[color][offset_new + i] = data[offset_old + i];
        }
      }
    }
  }

  return converted_data;
}

char* combine_rgb_cpu(char** data) {
  
}
