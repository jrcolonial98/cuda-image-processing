#include <stdio.h>
#include "bmp.h"

int main() {
	bmp image;
	printf("i got here\n");
	init_bmp(&image, "MARBLES.bmp");
	printf("got here\n");

	/*
	formatted_data = convert(image.data);
	new_data = blur(formatted_data);
	image.data = new_data;
	*/

	bmp_to_file(&image, "outtest.bmp");
}
