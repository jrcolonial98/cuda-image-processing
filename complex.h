typedef struct {
	double real;
	double imaginary;
} complex;

// absolute value of complex
double complex_abs(complex *c);

complex complex_add(complex *a, complex *b);

complex complex_sub(complex *a, complex *b);

complex complex_mult(complex *a, complex *b);

// scale complex by a given factor
complex complex_scale(complex *c, double val);

// returns e^(-2 * pi * i)
complex exp_to_complex(int k, int n, bool inv);
