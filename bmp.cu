#include "bmp.h"

void init_bmp(bmp* data, char* file_name) {
  bmp_header *bdata = &(data->bmpheader);
  file_header *fdata = &(bdata->fileheader);
  FILE *file;
  int n; // return value of file operations

  // open file
  file = fopen(file_name, "r"); // read binary mode
  if (file == NULL) {
    // error - cleanup
    fclose(file);
    free(file);
    free(data);
    data = NULL;
    printf("error opening file\n");
    return;
  }

  // read file header
  char file_type[2];
  file_type[0] = '\0';
  file_type[1] = '\0';
  n = fread(file_type, 2, 1, file);
  if (file_type[0] != 'B' || file_type[1] != 'M') {
    fclose(file);
    free(file);
    free(data);
    data = NULL;
    printf("file is not bitmap encoded\n");
    return;
  }
  n = fread(bdata, sizeof(bmp_header), 1, file);
  if (n < 1) {
    // error - cleanup
    fclose(file);
    free(file);
    free(data);
    data = NULL;
    printf("error reading file header\n");
    return;
  }
  format_bmp_data(bdata);
  if (bdata->bitsperpixel != 24) {
    // error - cleanup
    fclose(file);
    free(file);
    free(data);
    data = NULL;
    printf("image unsupported: bits per pixel is not 24\n");
    return;
  }
  print_bmp_data(bdata);

  // read the data of the image
  data->data = (unsigned char*)malloc(sizeof(char) * bdata->bitmapsize);
  if(data->data==NULL){
    // error - cleanup
    fclose(file);
    free(file);
    free(data);
    data = NULL;
    printf("error reading image data\n");
    return;
  }
  fseek(file, sizeof(unsigned char) * fdata->dataoffset, SEEK_SET);
  n=fread(data->data, sizeof(unsigned char), bdata->bitmapsize, file);
  if(n<1){
    // error - cleanup
    fclose(file);
    free(file);
    free(data);
    data = NULL;
    printf("error reading image data 2\n");
    return;
  }

  // cleanup
  fclose(file);
  free(file);

}

void bmp_to_file(bmp* data, char* file_name) {
  bmp_header *bdata = &(data->bmpheader);
  file_header *fdata = &(bdata->fileheader);
  FILE *out;
  int n; // return value of file operations

  // open output file
  out = fopen(file_name, "wb"); // write binary mode
  if (out == NULL) {
    // cleanup
    fclose(out);
    free(out);
  }

  // write "BM" to file
  char bm[2];
  bm[0] = 'B';
  bm[1] = 'M';
  n = fwrite(bm, sizeof(unsigned char) * 2, 1, out);
  if (n < 1) {
    // cleanup
    fclose(out);
    free(out);
  }

  // write header to file
  n = fwrite(bdata, sizeof(unsigned char), sizeof(bmp_header), out);
  if (n < 1) {
    // cleanup
    fclose(out);
    free(out);
  }

  // write data to file
  fseek(out, sizeof(unsigned char) * fdata->dataoffset, SEEK_SET);
  n = fwrite(data->data, sizeof(unsigned char), bdata->bitmapsize, out);
  if (n < 1) {
    // cleanup
    fclose(out);
    free(out);
  }

  // cleanup
  fclose(out);
  free(out);

}

void format_bmp_data(bmp_header *data) {
  if (data->bitmapsize == 0) {
    int width_size = data->bitsperpixel * data->width;
    while (width_size % 32 != 0) {
      width_size++;
    }
    int full_size = width_size * data->height / 8;
    data->bitmapsize = full_size;
  }
}

void print_bmp_data(bmp_header *data) {
	printf("File information:\n");
	printf("FILE HEADER: (size=%d)\n", (int)sizeof(file_header));
	//printf("filetype : char = %c %c\n", data->fileheader.filetype[0],
	//	data->fileheader.filetype[1]);
	printf("filesize : uint = %d\n", data->fileheader.filesize);
	printf("reserved1, reserved2 : short = %d %d\n", data->fileheader.reserved1,
		data->fileheader.reserved2);
	printf("dataoffset : uint = %d\n", data->fileheader.dataoffset);

	printf("\nBMP HEADER: (size-%d)\n", (int)sizeof(bmp_header));
	printf("headersize : uint = %d\n", data->headersize);
	printf("width : int = %d\n", data->width);
	printf("height : int = %d\n", data->height);
	printf("planes : short = %d\n", data->planes);
	printf("bitsperpixel : short = %d\n", data->bitsperpixel);
	printf("compression : uint = %d\n", data->compression);
	printf("bitmapsize : uint = %d\n", data->bitmapsize);
	printf("horizontalres : int = %d\n", data->horizontalres);
	printf("verticalres : int = %d\n", data->verticalres);
	printf("numcolors : uint = %d\n", data->numcolors);
	printf("importantcolors : uint = %d\n", data->importantcolors);
}



void convert_le(bmp_header *data) {
  data->fileheader.filesize = convert_le_4(data->fileheader.filesize);
  data->fileheader.reserved1 = convert_le_2(data->fileheader.reserved1);
  data->fileheader.reserved2 = convert_le_2(data->fileheader.reserved2);
  data->fileheader.dataoffset = convert_le_4(data->fileheader.dataoffset);

  data->headersize = convert_le_4(data->headersize);
  data->width = convert_le_4(data->width);
  data->height = convert_le_4(data->height);
  data->planes = convert_le_2(data->planes);
  data->bitsperpixel = convert_le_2(data->bitsperpixel);
  data->compression = convert_le_4(data->compression);
  data->bitmapsize = convert_le_4(data->bitmapsize);
  data->horizontalres = convert_le_4(data->horizontalres);
  data->verticalres = convert_le_4(data->verticalres);
  data->numcolors = convert_le_4(data->numcolors);
  data->importantcolors = convert_le_4(data->importantcolors);
}

short convert_le_2(short data) {
  int idata = (int)data;
  int low_byte = idata >> 8;
  idata = idata << 8;
  idata = idata + low_byte;
  short sdata = (short)idata;

  return sdata;
}

int convert_le_4(int data) {
  // split into two shorts, convert_le_2 both shorts
  // then reverse the order of the shorts
  int low_2bytes = data >> 16;
  short slow_2bytes = (short)low_2bytes;
  slow_2bytes = convert_le_2(slow_2bytes);

  short shigh_2bytes = (short)data;
  shigh_2bytes = convert_le_2(shigh_2bytes);

  int idata = (int)shigh_2bytes;
  idata = idata << 16;
  idata = idata + (int)slow_2bytes;

  return idata;
}

void extract_rgb_cpu(bmp* bmpdata, image* img) {
  unsigned char* data = bmpdata->data;
  bmp_header* bdata = &(bmpdata->bmpheader);
  int bytesperrow_new = bdata->width;
  int bytesperrow_old = bdata->width * 3;
  while (bytesperrow_old % 4 != 0) { // BMP format requires row length % 4 == 0
    bytesperrow_old++;
  }

  unsigned char* red = (unsigned char*)malloc(bdata->width * bdata->height);
  unsigned char* green = (unsigned char*)malloc(bdata->width * bdata->height);
  unsigned char* blue = (unsigned char*)malloc(bdata->width * bdata->height);

  unsigned char** converted_data = (unsigned char**)malloc(3 * sizeof(unsigned char*));
  converted_data[0] = red;
  converted_data[1] = green;
  converted_data[2] = blue;

  for (int color = 0; color < 3; color++) {
    for (int y = 0; y < bdata->height; y++) {
      int row_old = y * bytesperrow_old;
      int row_new = y * bytesperrow_new;

      for (int x = 0; x < bdata->width; x++) {
        int col_old = x * 3;
        int col_new = x;
        int offset_old = row_old + col_old + color;
        int offset_new = row_new + col_new;

        converted_data[color][offset_new] = data[offset_old + i];
      }
    }
  }

  img->data = converted_data;
  img->width = bdata->width;
  img->height = bdata->height;
}

void combine_rgb_cpu(bmp* bmpdata, image* img) {
  unsigned char** data = img->data;
  unsigned char* combined_data = bmpdata->data;
  bmp_header* bdata = &(bmpdata->bmpheader);
  int bytesperrow_old = bdata->width;
  int bytesperrow_new = bdata->width * 3;
  while (bytesperrow_new % 4 != 0) { // BMP format requires row length % 4 == 0
    bytesperrow_new++;
  }

  for (int color = 0; color < 3; color++) {
    for (int y = 0; y < bdata->height; y++) {
      int row_new = y * bytesperrow_new;
      int row_old = y * bytesperrow_old;

      for (int x = 0; x < bdata->width; x++) {
        int col_new = x * 3;
        int col_old = x;
        int offset_new = row_new + col_new + color;
        int offset_old = row_old + col_old;

        combined_data[offset_new] = data[(color+0)%3][offset_old];
      }
    }
  }
}
