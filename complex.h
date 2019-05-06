#ifndef COMPLEX_H
#define COMPLEX_H

#include <math.h>

typedef struct {
	double real;
	double imaginary;
} complex;

typedef struct {
	complex* arr;
	int x;
	int y;
} carray2d;

typedef struct {
	complex* arr;
	int x;
} carray1d;

// absolute value of complex
double complex_abs(complex *c);

complex complex_add(complex *a, complex *b);

complex complex_sub(complex *a, complex *b);

complex complex_mult(complex *a, complex *b);

// scale complex by a given factor
complex complex_scale(complex *c, double val);

// returns e^(-2 * pi * i)
complex exp_to_complex(int k, int n, bool inv);

#endif
