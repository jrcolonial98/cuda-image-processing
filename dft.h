#ifndef DFT_H
#define DFT_H

#include "complex.h"
#include "bmp.h"


// API ENDPOINTS

// "blur" the values of a 2d array
void blur(image* image);



// BLUR HELPERS

// DFT by row
void dft_row(carray2d* carr, bool inv);

// DFT by column
void dft_col(carray2d* carr, bool inv);

// remove data based on distance from the corner
void round(carray2d* carr, double round_factor);

// round absolute value of a complex back to int
void normalize(carray2d* carr);



// DFT HELPERS
void fft(carray1d* carr, bool inv);
complex* fft_recursive(complex* arr, int* indices, int indices_len, bool inv);
complex* dft_combine(complex* even, complex* odd, int groupsize, bool inv);



#endif
