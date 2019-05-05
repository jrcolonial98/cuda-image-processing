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
  char* data;
} bmp;



// BITMAP OPERATIONS

void init_bmp(bmp* data, char* file_name);
void bmp_to_file(bmp* data, char* file_name);
void format_bmp_data(bmp_header *data);
void print_bmp_data(bmp_header *data);



// LITTLE ENDIAN TO BIG ENDIAN CONVERSIONS

void convert_le(bmp_header *data);

short convert_le_2(short data);
int convert_le_4(int data);


#endif
