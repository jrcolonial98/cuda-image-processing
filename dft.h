#ifndef DFT_H
#define DFT_H

#include "complex.h"



// API ENDPOINTS

// "blur" the values of a 2d array
void blur(image* image);



// BLUR HELPERS

// DFT by row
void dft_row(carray2d* carr);

// DFT by column
void dft_col(carray2d* carr);

// inverse DFT by row
void dft_inv_row(carray2d* carr);

// inverse DFT by column
void dft_inv_col(carray2d* carr);

// remove data based on distance from the corner
void round(carray2d* carr);

// round absolute value of a complex back to int
void normalize(carray2d* carr);



// DFT HELPERS
void fft(carray1d carr, bool inv);
complex* fft_recursive(complex* arr, int* indices, int indices_len, bool inv);
complex* dft_combine(complex** arrs, int num_groups, int groupsize, bool inv);



#endif
