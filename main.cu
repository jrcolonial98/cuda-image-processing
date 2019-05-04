#include <stdio.h>
#include "bmp.h"

int main(int argc, char *argv[]) {
  char* file_name = argv[1];
  char* out_file_name = "outtest.bmp";

  bmp image;
  printf("Initializing image from file: %s\n\n", file_name);
  init_bmp(&image, file_name);

  /*
  formatted_data = convert(image.data);
  new_data = blur(formatted_data);
  image.data = new_data;
  */

  printf("Writing data to file: %s\n\n", out_file_name);
  bmp_to_file(&image, out_file_name);
}
