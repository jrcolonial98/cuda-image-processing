#ifndef BMP_H
#define BMP_H

#include <stdio.h>

typedef struct {
  //char filetype[2]; // always 'B' 'M'
  unsigned int filesize;
  short reserved1;
  short reserved2;
  unsigned int dataoffset;
} file_header;

typedef struct {
  file_header fileheader;
  unsigned int headersize; // the size of this header (40 bytes)
  int width; // in pixels
  int height; // in pixels
  short planes; // number of color planes (must be 1)
  short bitsperpixel; // usually 24 - 3 bytes - R/G/B
  unsigned int compression; // not supported
  unsigned int bitmapsize; // size of the data in bytes (can be calculated)
  int horizontalres; // pixels per meter
  int verticalres; // pixels per meter
  unsigned int numcolors; // number of colors within the palette
  unsigned int importantcolors; // this is generally ignored
} bmp_header;

typedef struct {
  bmp_header bmpheader;
    // 2D array, indexed first by one-dimensional pixel number then R/G/B val
    // for example data[y * width + x][0] = redval;
  unsigned char* data;
} bmp;

typedef struct {
  int width;
  int height;

  unsigned char** data;
}  image;


// BITMAP OPERATIONS

void init_bmp(bmp* data, char* file_name);
void bmp_to_file(bmp* data, char* file_name);
void format_bmp_data(bmp_header *data);
void print_bmp_data(bmp_header *data);



// IMAGE CONVERSIONS

// convert from data[row][col][r/g/b] to data[r/g/b][row][col]
// returns result where result[0] = red, result[1] = green, result[2] = blue
void extract_rgb_cpu(bmp* bmpdata, image* img);

// undo the process in extract_rgb
void combine_rgb_cpu(bmp* bmpdata, image* img);



// IMAGE OPERATIONS

void to_black_and_white(char** data);
#endif
