#include "bmp.h"

void init_bmp(bmp* data, char* file_name) {
  bmp_header *bdata = &(data->bmpheader);
  file_header *fdata = &(bdata->fileheader);
  FILE *file;
  int n; // return value of file operations

  // open file
  file = fopen(file_name, "rb"); // read binary mode
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
  print_bmp_data(bdata);

  // read the data of the image
  data->data = (char*)malloc(sizeof(char) * bdata->bitmapsize);
  if(data->data==NULL){
    // error - cleanup
    fclose(file);
    free(file);
    free(data);
    data = NULL;
    printf("error reading image data\n");
    return;
  }
  fseek(file, sizeof(char) * fdata->dataoffset, SEEK_SET);
  n=fread(data->data, sizeof(char), bdata->bitmapsize, file);
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

  // write header to file
  n = fwrite(bdata, sizeof(char), sizeof(bmp_header), out);
  if (n < 1) {
    // cleanup
    fclose(out);
    free(out);
  }

  // write data to file
  fseek(out, sizeof(char) * fdata->dataoffset, SEEK_SET);
  printf("writing this many bytes %d", bdata->bitmapsize);
  n = fwrite(data->data, sizeof(char), bdata->bitmapsize, out);
  if (n < 1) {
    // cleanup
    fclose(out);
    free(out);
  }

  // cleanup
  fclose(out);
  free(out);

}

void print_bmp_data(bmp_header *data) {
	printf("FILE HEADER:\n");
	printf("filetype : char = %c %c\n", data->fileheader.filetype[0],
		data->fileheader.filetype[1]);
	printf("filesize : uint = %d\n", data->fileheader.filesize);
	printf("reserved1, reserved2 : short = %d %d\n", data->fileheader.reserved1,
		data->fileheader.reserved2);
	printf("dataoffset : uint = %d\n", data->fileheader.dataoffset);

	printf("\nBMP HEADER:\n");
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
