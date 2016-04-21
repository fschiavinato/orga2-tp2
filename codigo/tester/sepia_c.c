
#include "../tp2.h"
#include <limits.h>


void sepia_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j * 4];
            
            unsigned short suma = 0;
            suma += p_s->b;
            suma += p_s->g;
            suma += p_s->r;

            p_d->b = (unsigned short) ((suma * 2) / 10);
            p_d->g = (unsigned short) ((suma * 3) / 10);
            suma = ((suma * 5) / 10);
            if(suma > UCHAR_MAX) p_d->r = UCHAR_MAX;
            else p_d->r = suma;
            p_d->a = p_s->a;

        }
    }	//COMPLETAR
}



