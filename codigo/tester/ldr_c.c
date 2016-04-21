
#include "../tp2.h"
#include<limits.h>

#define MIN(x,y) ( x < y ? x : y )
#define MAX(x,y) ( x > y ? x : y )

#define P 2
#define MAXSUM 4876875 // 5*5*3*255*255

void ldr_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size,
	int alpha)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j * 4];
            if( i < P || j < P || (i+P) >= filas || (j+P) >= cols) { 
                *p_d = *p_s;
            }
            else {
                // Necesitamos 64bits porque al hacer ultima la division el numero mas grande posible es 255*255+255*4876875=4A20DEB6
                long long r = 0;
                long long g;
                long long b;
                for(int k = -P; k <= P; k++) {
                    for(int l = -P; l <= P; l++) {
                        bgra_t *p_si = (p_s + l) + k * cols;
                        r += p_si->r;
                        r += p_si->g;
                        r += p_si->b;
                    }
                }
                r = r * alpha;
                g = r;
                b = r;

                r = (r * p_s->r + ((long long) p_s->r ) * MAXSUM) / MAXSUM;
                g = (g * p_s->g + ((long long) p_s->g ) * MAXSUM) / MAXSUM;
                b = (b * p_s->b + ((long long) p_s->b ) * MAXSUM) / MAXSUM;

                p_d->r = (unsigned char) MAX(MIN(r, UCHAR_MAX), 0);
                p_d->g = (unsigned char) MAX(MIN(g, UCHAR_MAX), 0);
                p_d->b = (unsigned char) MAX(MIN(b, UCHAR_MAX), 0);

            }
        }
    }
}

