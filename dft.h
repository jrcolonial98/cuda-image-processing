#ifndef DFT_H
#define DFT_H

#include "complex.h"
#include "bmp.h"

// API ENDPOINTS

// "blur" the values of a 2d array
void blur(image* image, bool parallel);


// BLUR HELPERS

// DFT by row
void dft_row(carray2d* carr, bool inv);

// DFT by column
void dft_col(carray2d* carr, bool inv);

// create gaussian kernel for blurring
complex* get_gaussian_kernel(int height, int width, int height_pow_2, int width_pow_2, double sigma);



// DFT HELPERS
void fft(carray1d* carr, bool inv);
complex* fft_recursive(complex* arr, int* indices, int indices_len, bool inv);
complex* dft_combine(complex* even, complex* odd, int groupsize, bool inv);



#endif
