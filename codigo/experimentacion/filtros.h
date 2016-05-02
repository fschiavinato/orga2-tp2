void cropflip_asm    (unsigned char *src, unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size, int tamx, int tamy, int offsetx, int offsety);
void cropflip_c    (unsigned char *src, unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size, int tamx, int tamy, int offsetx, int offsety);

void ldr_asm    (unsigned char *src, unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size, int alpha);
void ldr_c    (unsigned char *src, unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size, int alpha);
void sepia_asm    (unsigned char *src, unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size);

void sepia_c    (unsigned char *src, unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size);


