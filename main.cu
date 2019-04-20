#include <stdio.h>
#include "bmp.h"

int main() {
	bmp image;
	init_bmp(&image, "MARBLES.BMP");
	bmp_to_file(&image, "outtest.bmp");
}
