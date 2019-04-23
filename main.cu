#include <stdio.h>
#include "bmp.h"

int main() {
	bmp image;
	init_bmp(&image, "MARBLES.BMP");

	/*
	formatted_data = convert(image.data);
	new_data = blur(formatted_data);
	image.data = new_data;
	*/

	bmp_to_file(&image, "outtest.bmp");
}
