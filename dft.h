#include "complex.h"

//function prototypes - not finished

int** blur(complex** arr);



// BLUR HELPERS

// DFT by row
complex** dft_row(complex** arr);

// DFT by column
complex** dft_col(complex** arr);

// inverse DFT by row
complex** dft_inv_row(complex** arr);

// inverse DFT by column
complex** dft_inv_col(complex** arr);

// remove data based on distance from the corner
complex** round(complex** arr);

// round absolute value to 0 or 1
int** normalize(complex** arr);



// DFT HELPERS
complex* fft(complex* x, bool inv);
complex* fft_recursive(complex* x, int* indices, bool inv);
complex* dft_combine(complex* odd, complex* even, bool inv);
