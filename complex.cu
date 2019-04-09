#include <math.h>
#include "complex.h"

double complex_abs(complex_t *c) {
	return sqrt(c->real * c->real + c->imaginary * c->imaginary);
}
complex_t add(complex_t *a, complex_t *b) {
	complex_t sum;
	sum.real = a->real + b->real;
	sum.imaginary = a->imaginary + b-> imaginary;
	return sum;
}
complex_t sub(complex_t *a, complex_t *b) {
	complex_t diff;
	diff.real = a->real - b->real;
	diff.imaginary = a->imaginary - b->imaginary;
	return diff;
}
complex_t mult(complex_t *a, complex_t *b) {
	complex_t prod;
	prod.real = a->real * b->real - a->imaginary * b->imaginary;
	prod.imaginary = a->real * b->imaginary - a->imaginary * b->real;
	return prod;
}
complex_t scale(complex_t *c, double val) {
	complex_t scaled;
	scaled.real = c->real * val;
	scaled.imaginary = c->imaginary * val;
	return scaled;
}


complex_t exp_to_complex(int k, int n, bool inv) {
	double exponent = -2 * M_PI * k / n;
	if (inv) exponent *= -1;
	complex_t c;
	c.real = cos(exponent);
	c.imaginary = sin(exponent);
	return c;
}
