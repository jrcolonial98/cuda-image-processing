#include <stdio.h>
#include "bmp.h"
#include "dft.h"

int main(int argc, char *argv[]) {
  char* file_name = argv[1];
  char* out_file_name = "outtest.bmp";

  // initialize bitmap
  bmp bitmap;
  printf("Initializing image from file: %s\n\n", file_name);
  init_bmp(&bitmap, file_name);

  // convert into image
  printf("Converting image data... \n\n");
  image img;
  extract_rgb_cpu(&bitmap, &img);

  printf("Blurring image (SERIAL)...\n\n");
  blur(&img);

  // write to file
  printf("Writing data to file: %s\n\n", out_file_name);
  combine_rgb_cpu(&bitmap, &img);
  bmp_to_file(&bitmap, out_file_name);
}
