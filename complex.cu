#include "complex.h"

double complex_abs(complex *c) {
	return sqrt(c->real * c->real + c->imaginary * c->imaginary);
}
complex complex_add(complex *a, complex *b) {
	complex sum;
	sum.real = a->real + b->real;
	sum.imaginary = a->imaginary + b-> imaginary;
	return sum;
}
complex complex_sub(complex *a, complex *b) {
	complex diff;
	diff.real = a->real - b->real;
	diff.imaginary = a->imaginary - b->imaginary;
	return diff;
}
complex complex_mult(complex *a, complex *b) {
	complex prod;
	prod.real = a->real * b->real - a->imaginary * b->imaginary;
	prod.imaginary = a->real * b->imaginary + a->imaginary * b->real;
	return prod;
}
complex complex_scale(complex *c, double val) {
	complex scaled;
	scaled.real = c->real * val;
	scaled.imaginary = c->imaginary * val;
	return scaled;
}


complex exp_to_complex(int k, int n, bool inv) {
	double exponent = -2 * M_PI * k / n;
	if (inv) exponent *= -1;
	complex c;
	c.real = cos(exponent);
	c.imaginary = sin(exponent);
	return c;
}
