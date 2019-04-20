#include "bmp.h"

void init_bmp(bmp* data, char* file_name) {
  bmp_header *bdata = &(data->bmpheader);
  file_header *fdata = &(bdata->fileheader);
  FILE *file;
  int n; // return value of file operations

  // open file
  file = fopen(file_name, "r");
  if (file == NULL) {
    // error - cleanup
    fclose(file);
    free(file);
    free(data);
    data = NULL;
  }

  // read file header
  n = fread(bdata, sizeof(bmp_header), 1, file);
  if (n < 1) {
    // error - cleanup
    fclose(file);
    free(file);
    free(data);
    data = NULL;
  }

  // read the data of the image
  data->data = (char*)malloc(sizeof(char) * bdata->bitmapsize);
  if(data->data==NULL){
    // error - cleanup
    fclose(file);
    free(file);
    free(data);
    data = NULL;
  }
  fseek(file, sizeof(char) * fdata->dataoffset, SEEK_SET);
  n=fread(data->data, sizeof(char), bdata->bitmapsize, file);
  if(n<1){
    // error - cleanup
    fclose(file);
    free(file);
    free(data);
    data = NULL;
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
  out = fopen(file_name, "w");
  if (out == NULL) {
    // cleanup
    fclose(out);
    free(out);
  }

  // write header to file
  n = fwrite(&(data->bmpheader), sizeof(char), sizeof(bmp_header), out);
  if (n < 1) {
    // cleanup
    fclose(out);
    free(out);
  }

  // write data to file
  fseek(out, sizeof(char) * fdata->dataoffset, SEEK_SET);
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
