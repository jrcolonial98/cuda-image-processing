#include <stdio.h>
#include "bmp.h"

int main() {
	bmp image;
	init_bmp(&bmp, "MARBLES.BMP");
	bmp_to_file(&bmp, "marbs.bmp");
}
