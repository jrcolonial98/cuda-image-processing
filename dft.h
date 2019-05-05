#ifndef DFT_H
#define DFT_H

#include "complex.h"
#include "bmp.h"

// structs for size of arrays when needed
typedef struct {
  int x; // rows
  int y; // columns
} dim_2d;

typedef struct {
  int x;
} dim_1d;



// API ENDPOINTS

// "blur" the values of a 2d array
int** blur(complex** arr, dim_2d dim);



// BLUR HELPERS

// DFT by row
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

// convert from data[row][col][r/g/b] to data[r/g/b][row][col]
// returns result where result[0] = red, result[1] = green, result[2] = blue
char** extract_rgb_cpu(bmp* bmpdata);

// undo the process in extract_rgb
void combine_rgb_cpu(bmp* bmpdata, char** data);


#endif
