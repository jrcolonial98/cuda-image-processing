#include <stdio.h>
#include "bmp.h"

int main() {
	bmp image;
	printf("i got here\n");
	init_bmp(&image, "MARBLES.bmp");
	printf("got here\n");
	bmp_to_file(&image, "outtest.bmp");
}
