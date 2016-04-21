#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "tp2.h"
#include "helper/tiempo.h"
#include "helper/libbmp.h"
#include "helper/utils.h"
#include "helper/imagenes.h"

#define N_ENTRADAS_cropflip 1
#define N_ENTRADAS_sepia 1
#define N_ENTRADAS_ldr 1

DECLARAR_FILTRO(cropflip)
DECLARAR_FILTRO(sepia)
DECLARAR_FILTRO(ldr)

filtro_t filtros[] = {
	DEFINIR_FILTRO(cropflip) ,
	DEFINIR_FILTRO(sepia) ,
	DEFINIR_FILTRO(ldr) ,
	{0,0,0,0,0}
};

int main()
{
	fopen("data.csv", "w");
	

	return 0;
}