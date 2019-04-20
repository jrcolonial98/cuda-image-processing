#include <stdio.h>

typedef struct {
  char filetype[2]; // always 'B' 'M'
  unsigned int filesize;
  short reserved1;
  short reserved2;
  unsigned int dataoffset;
} file_header;

typedef struct {
  file_header fileheader;
  unsigned int headersize;
  int width;
  int height;
  short planes;
  short bitsperpixel; // must be 24
  unsigned int compression; // not supported
  unsigned int bitmapsize;
  int horizontalres;
  int verticalres;
  unsigned int numcolors;
  unsigned int importantcolors;
} bmp_header;

typedef struct {
  bmp_header bmpheader;
    // 2D array, indexed first by one-dimensional pixel number then R/G/B val
    // for example data[y * width + x][0] = redval;
  char* data;
} bmp;



void init_bmp(bmp* data, char* file_name);

void bmp_to_file(bmp* data, char* file_name);
