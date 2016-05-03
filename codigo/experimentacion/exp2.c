#include "generador_imagenes.h"
#include "../helper/tiempo.h"
#include "filtros.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>
#define alpha 0.1
#define PATH "mediciones_exp2/"

int compare_function(const void *a,const void *b) {
    int *x = (int *) a;
    int *y = (int *) b;
    return *x - *y;
}

enum experimentos {
    aleatorio_cropflip_asm,
    aleatorio_cropflip_c, 
    aleatorio_ldr_asm,
    aleatorio_ldr_c, 
    aleatorio_sepia_asm,
    aleatorio_sepia_c,
    constante_cropflip_asm,
    constante_cropflip_c, 
    constante_ldr_asm,
    constante_ldr_c, 
    constante_sepia_asm,
    constante_sepia_c
};

// Uso: exp tam_maximo paso mediciones ldr-alpha r g b a
// Calculamos el promedio 10%-podado superiormente, o sea nos sacamos los 10% valores mas altos.
int main(int argc, char* argv[]) {
    int tm, step, n, ldr_alpha, r, g, b, a;
    if(argc < 9) {
        printf("Faltan Parametros.");
        return 0;
    }
    tm = atoi(argv[1]);
    step = atoi(argv[2]);
    n = atoi(argv[3]);
    ldr_alpha = atoi(argv[4]);
    r = atoi(argv[5]);
    g = atoi(argv[6]);
    b = atoi(argv[7]);
    a = atoi(argv[8]);

    printf("Aleatorio Cropflip Asm:\n");
    correr_exp(aleatorio_cropflip_asm, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Aleatorio Cropflip C:\n");
    correr_exp(aleatorio_cropflip_c, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Aleatorio Ldr Asm:\n");
    correr_exp(aleatorio_ldr_asm, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Aleatorio Ldr C:\n");
    correr_exp(aleatorio_ldr_c, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Aleatorio Sepia Asm:\n");
    correr_exp(aleatorio_sepia_asm, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Aleatorio Sepia C:\n");
    correr_exp(aleatorio_sepia_c, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Constante Cropflip Asm:\n");
    correr_exp(constante_cropflip_asm, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Constante Cropflip C:\n");
    correr_exp(constante_cropflip_c, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Constante Ldr Asm:\n");
    correr_exp(constante_ldr_asm, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Constante Ldr C:\n");
    correr_exp(constante_ldr_c, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Constante Sepia Asm:\n");
    correr_exp(constante_sepia_asm, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Constante Sepia C:\n");
    correr_exp(constante_sepia_c, tm, step, n, ldr_alpha, r, g, b, a); 
    printf("Listo!\n");
    return 0;

}

void correr_exp(enum experimentos exp, int tm, int step, int n, int ldr_alpha, int r, int g, int b, int a) {
    int i, k, na;
    unsigned long long avg, sd, start;
    unsigned long long* mediciones;
    FILE* fa;
    FILE* fs;
    BMP* img;
    BMP* imgD;
    na = alpha*n;
    mediciones = malloc(n*sizeof(unsigned long long));

    switch(exp) {
        case aleatorio_cropflip_c:
            fa = fopen(PATH"aleatorio_cropflip_c_avg.csv", "w");
            fs = fopen(PATH"aleatorio_cropflip_c_sd.csv", "w");
            break;
        case aleatorio_cropflip_asm: 
            fa = fopen(PATH"aleatorio_cropflip_asm_avg.csv", "w");
            fs = fopen(PATH"aleatorio_cropflip_asm_sd.csv", "w");
            break;
        case aleatorio_ldr_asm:
            fa = fopen(PATH"aleatorio_ldr_asm_avg.csv", "w");
            fs = fopen(PATH"aleatorio_ldr_asm_sd.csv", "w");
            break;
        case aleatorio_ldr_c: 
            fa = fopen(PATH"aleatorio_ldr_c_avg.csv", "w");
            fs = fopen(PATH"aleatorio_ldr_c_sd.csv", "w");
            break;
        case aleatorio_sepia_asm:
            fa = fopen(PATH"aleatorio_sepia_asm_avg.csv", "w");
            fs = fopen(PATH"aleatorio_sepia_asm_sd.csv", "w");
            break;
        case aleatorio_sepia_c:
            fa = fopen(PATH"aleatorio_sepia_c_avg.csv", "w");
            fs = fopen(PATH"aleatorio_sepia_c_sd.csv", "w");
            break;
        case constante_cropflip_c:
            fa = fopen(PATH"constante_cropflip_c_avg.csv", "w");
            fs = fopen(PATH"constante_cropflip_c_sd.csv", "w");
            break;
        case constante_cropflip_asm: 
            fa = fopen(PATH"constante_cropflip_asm_avg.csv", "w");
            fs = fopen(PATH"constante_cropflip_asm_sd.csv", "w");
            break;
        case constante_ldr_asm:
            fa = fopen(PATH"constante_ldr_asm_avg.csv", "w");
            fs = fopen(PATH"constante_ldr_asm_sd.csv", "w");
            break;
        case constante_ldr_c: 
            fa = fopen(PATH"constante_ldr_c_avg.csv", "w");
            fs = fopen(PATH"constante_ldr_c_sd.csv", "w");
            break;
        case constante_sepia_asm:
            fa = fopen(PATH"constante_sepia_asm_avg.csv", "w");
            fs = fopen(PATH"constante_sepia_asm_sd.csv", "w");
            break;
        case constante_sepia_c:
            fa = fopen(PATH"constante_sepia_c_avg.csv", "w");
            fs = fopen(PATH"constante_sepia_c_sd.csv", "w");
            break;

    }
    for( i = step; i <= tm; i*=step) {
        sd = 0;
        avg = 0;
        switch(exp) {
            case aleatorio_cropflip_c:
            case aleatorio_cropflip_asm: 
            case aleatorio_ldr_asm:
            case aleatorio_ldr_c: 
            case aleatorio_sepia_asm:
            case aleatorio_sepia_c:
                img = generador_aleatorio(i, i);
                break;
            case constante_cropflip_c:
            case constante_cropflip_asm: 
            case constante_ldr_asm:
            case constante_ldr_c: 
            case constante_sepia_asm:
            case constante_sepia_c:
                img = generador_constante(i, i, r, g, b, a);
                break;
        }
        imgD = generador_constante(i, i, 0, 0, 0, 0);
        for( k = 0; k < n; k++) {
            switch(exp) {
                case constante_cropflip_c:
                case aleatorio_cropflip_c:
                    MEDIR_TIEMPO_START(start);
                    cropflip_c(bmp_data(img), bmp_data(imgD), i, i, i*4, i*4, i, i, 0, 0);
                    MEDIR_TIEMPO_STOP(mediciones[k]);
                    break;
                case constante_cropflip_asm: 
                case aleatorio_cropflip_asm: 
                    MEDIR_TIEMPO_START(start);
                    cropflip_asm(bmp_data(img), bmp_data(imgD), i, i, i*4, i*4, i, i, 0, 0);
                    MEDIR_TIEMPO_STOP(mediciones[k]);
                    break;
                case constante_ldr_asm:
                case aleatorio_ldr_asm:
                    MEDIR_TIEMPO_START(start);
                    ldr_asm(bmp_data(img), bmp_data(imgD), i, i, i*4, i*4, ldr_alpha);
                    MEDIR_TIEMPO_STOP(mediciones[k]);
                    break;
                case constante_ldr_c: 
                case aleatorio_ldr_c: 
                    MEDIR_TIEMPO_START(start);
                    ldr_c(bmp_data(img), bmp_data(imgD), i, i, i*4, i*4, ldr_alpha);
                    MEDIR_TIEMPO_STOP(mediciones[k]);
                    break;
                case constante_sepia_asm:
                case aleatorio_sepia_asm:
                    MEDIR_TIEMPO_START(start);
                    sepia_asm(bmp_data(img), bmp_data(imgD), i, i, i*4, i*4);
                    MEDIR_TIEMPO_STOP(mediciones[k]);
                    break;
                case constante_sepia_c:
                case aleatorio_sepia_c:
                    MEDIR_TIEMPO_START(start);
                    sepia_c(bmp_data(img), bmp_data(imgD), i, i, i*4, i*4);
                    MEDIR_TIEMPO_STOP(mediciones[k]);
                    break;
            }
            mediciones[k] -= start;
        }
        qsort(mediciones,n, sizeof(long long int),compare_function);
        for( k = 0; k < na; k++) {
            avg += mediciones[k];
        }
        avg = avg / na;
        for( k = 0; k < na; k++) {
            sd += (mediciones[k]-avg)*(mediciones[k]-avg);
        }
        sd = sd / na;
        sd = sqrt(sd);
        fprintf(fa, "%d, %f\n", i, ((double) avg) / ((double) (i*i)));
        fprintf(fs, "%d, %f\n", i, ((double) sd) / ((double) (i*i)));
        bmp_delete(img);
        bmp_delete(imgD);
    }
    fclose(fa);
    fclose(fs);

    free(mediciones);

}
