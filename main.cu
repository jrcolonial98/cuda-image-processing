#include <stdio.h>
#include "bmp.h"
#include "dft.h"
#include "timerc.h"

__global__ void warmup() {}

int main(int argc, char *argv[]) {
  warmup<<<1,1>>>();

  char* file_name = argv[1];
  bool parallel = argv[2][0] == 'p';
  char* out_file_name = "outtest.bmp";

  // initialize bitmap
  bmp bitmap;
  printf("Initializing image from file: %s\n\n", file_name);
  init_bmp(&bitmap, file_name);


  // convert into image
  printf("Converting image data... \n\n");
  image img;
  extract_rgb_cpu(&bitmap, &img);


  // blur image
  float time;
  if (parallel) {
    printf("Blurring image (PARALLEL)...\n\n");
    //cstart();
    blur(&img, true);
    //cend(&time);
  }
  else {
    printf("Blurring image (SERIAL)...\n\n");
    //cstart();
    blur(&img, false);
    //cend(&time);
  }
  printf("Time taken: %f", time);


  // write to file
  printf("Writing data to file: %s\n\n", out_file_name);
  combine_rgb_cpu(&bitmap, &img);
  bmp_to_file(&bitmap, out_file_name);

  free(bitmap.data);
  free(img.data);
}
