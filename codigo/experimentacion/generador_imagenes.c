#include "../helper/libbmp.h"
#include<time.h>
#include<stdint.h>

BMP* generador_aleatorio(int filas, int columnas) {
    int i, j;
    BMP* res;
    BMPV5H* header;
    filas = filas + 4 - (filas % 4); // Lo llevamos al multiplo de 4 mas cercano y mas grande.
    columnas = columnas + 4 - (columnas % 4); // Lo llevamos al multiplo de 4 mas cercano y mas grande.
    header = get_BMPV5H(columnas, filas);

    srand(time(NULL));
    res = bmp_create(header, 0);
    uint8_t* data = bmp_data(res);
    for(i = 0; i < filas; i++) {
        for(j = 0; j < columnas; j++) {
            data[j*filas*4 + 0] = rand() % 256;
            data[j*filas*4 + 1] = rand() % 256;
            data[j*filas*4 + 2] = rand() % 256;
            data[j*filas*4 + 3] = rand() % 256;
        }
    }
    return res;

}

BMP* generador_constante(int filas, int columnas, uint8_t r, uint8_t g, uint8_t b, uint8_t a) {
    int i, j;
    BMP* res;
    BMPV5H* header;
    filas = filas + 4 - (filas % 4); // Lo llevamos al multiplo de 4 mas cercano y mas grande.
    columnas = columnas + 4 - (columnas % 4); // Lo llevamos al multiplo de 4 mas cercano y mas grande.
    header = get_BMPV5H(columnas, filas);

    res = bmp_create(header, 0);
    uint8_t* data = bmp_data(res);
    for(i = 0; i < filas; i++) {
        for(j = 0; j < columnas; j++) {
            data[j*filas*4 + 0] = b;
            data[j*filas*4 + 1] = g;
            data[j*filas*4 + 2] = r;
            data[j*filas*4 + 3] = a;
        }
    }
    return res;
}


BMP* generador_todoscolores() {
    int i, j, filas, columnas;
    BMP* res;
    BMPV5H* header;
    filas = 255*255;
    columnas = 255*255;

    filas = filas + 4 - (filas % 4); // Lo llevamos al multiplo de 4 mas cercano y mas grande.
    columnas = columnas + 4 - (columnas % 4); // Lo llevamos al multiplo de 4 mas cercano y mas grande.
    header = get_BMPV5H(columnas, filas);

    res = bmp_create(header, 0);
    uint8_t* data = bmp_data(res);
    for(i = 0; i < filas; i++) {
        for(j = 0; j < columnas; j++) {
            data[j*filas*4 + 0] = j % 256;
            data[j*filas*4 + 1] = j / 256;
            data[j*filas*4 + 2] = i % 256;
            data[j*filas*4 + 3] = i / 256;
        }
    }
    return res;
}
