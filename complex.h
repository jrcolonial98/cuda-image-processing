typedef struct complex complex_t;

struct complex {
	double real;
	double imaginary;
};

// absolute value of complex
double complex_abs(complex_t *c);

complex_t complex_add(complex_t *a, complex_t *b);

complex_t complex_sub(complex_t *a, complex_t *b);

complex_t complex_mult(complex_t *a, complex_t *b);

// scale complex by a given factor
complex_t complex_scale(complex_t *c, double val);

// returns e^(-2 * pi * i)
complex_t exp_to_complex(int k, int n, bool inv);
