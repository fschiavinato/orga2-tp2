%define pXi 4
%define vmax 4876875
%define  vmax_f 4876875.0
global ldr_asm
%define bs_byte 8
%define a_quitador 8
%define bs_word 16
%define bs_dword 32
%define s_xmm 16
%define s_dqword 16
%define s_qword 8
%define s_pixel 4
%define ss_pixel 16 ;(s_pixel *4)
%define alpha rbp+16


section .data
max: dd vmax, vmax, vmax, vmax
max_f: dd vmax_f, vmax_f, vmax_f, vmax_f

section .text
;void ldr_asm    (
	;unsigned char *src,
	;unsigned char *dst,
	;int filas,
	;int cols,
	;int src_row_size,
	;int dst_row_size,
	;int alpha)
;   rdi = src
;   rsi = dst
;   edx = cols
;   ecx = filas
;   r8d = src_row_size
;   r9d = dst_row_size
;   rbp+8 = alpha


ldr_asm:
    push rbp
    mov rbp, rsp
    mov r10, [rbp+16]
    push r12
    push r13
    push rbx
    push r14
    push r15

    and r8, 0000FFFFh;decia 00000000FFFFFFFFh
    and r9, 0000FFFFh

    mov r10d, [alpha]
    mov r14, r9 
    sub r14, 2
    mov r15, r14
    add r15, ss_pixel
    sub ecx, 2 ;para que las dos ultimas filas no se vean involucradas   

    xor r11, r11 ; indice fila
    xor r12, r12 ; indice columna

    movdqu xmm14, [max]  ; puse los corchetes para que sea direccion de memoria...
    movdqu xmm13, [max_f]
.empiezo:
    ; estamos afuera del marco
    and r12, r12 ; Nos fijamos si es cero
    jz .cargar    
    jmp .cargar_precarga

.cargado:
    punpcklbw xmm10, xmm0 ; xmm10 = |a01|*|r01|*|g01|*|b01|*|a00|*|r00|*|g00|*|b00|*|
    psrlw xmm10, bs_byte
    punpckhbw xmm11, xmm0 ; xmm11 = |a03|*|r03|*|g03|*|b03|*|a02|*|r02|*|g02|*|b02|*|
    psrlw xmm11, bs_byte

    punpcklbw xmm0, xmm1 ; xmm0 = |a11|*|r11|*|g11|*|b11|*|a10|*|r10|*|g10|*|b10|*|
    psrlw xmm0, bs_byte ; xmm0 = |a11|r11|g11|b11|a10|r10|g10|b10|
    ;psrld xmm0, a_quitador ; xmm0 = |0|r11|g11|b11|0|r10|g10|b10| Esto lo agrege yo, puede que este mal. pero es para limpiar los a de la suma
    punpckhbw xmm12, xmm1 ; xmm12 = |a13|*|r13|*|g13|*|b13|*|a12|*|r12|*|g12|*|b12|*|
    psrlw xmm12, bs_byte ; xmm12 = |a13|r13|g13|b13|a12|r12|g12|b12|
    ;psrld xmm12, a_quitador  ; xmm12 = |0|r13|g13|b13|0|r12|g12|b12|; Otra casilla clave que agrege
    paddw xmm10, xmm0 ; xmm10 = |p11+p01|p10+p00| Reemplazar? paddw x paddusw, para que sature suma los componente y no las a--Aca y en otros lados mas decia xmm12, pero lo cambie por xmm0 para que tenga sentido 
    paddw xmm11, xmm12 ; xmm11 = |p13+p03|p12+p02| Aca y en otros lados mas decia xmm13, pero lo cambie por xmm12 para que tenga sentido

    ;Atencion, aunque no este escrito, suma bytre a byte? Aca estamos sumando los a-- tambien, que no deberiamos sumar... 

    punpcklbw xmm0, xmm2 ; xmm0 = |a21|*|r21|*|g21|*|b21|*|a20|*|r20|*|g20|*|b20|*|
    psrlw xmm0, bs_byte  ; xmm0 = |a21|r21|g21|b21|a20|r20|g20|b20|
    ;psrld xmm0, a_quitador; xmm0 = |0|r21|g21|b21|0|r20|g20|b20|
    punpckhbw xmm12, xmm2 ; xmm12 = |a23|*|r23|*|g23|*|b23|*|a22|*|r22|*|g22|*|b22|*|
    psrlw xmm12, bs_byte ; xmm12 = |a23|r23|g23|b23|a22|r22|g22|b22|
    ;psrld xmm12, bs_byte ; xmm12 = |0|r23|g23|b23|0|r22|g22|b22| No hace esto. estaria enrealidad |0|a23|r23|g23|0|a22|r22|g22| 
    paddw xmm10, xmm0 ; xmm10 = |p21+p11+p01|p20+p10+p00|
    paddw xmm11, xmm12 ; xmm11 = |p23+p13+p03|p22+p12+p02|

    punpcklbw xmm0, xmm3 ; xmm12 = |a31|*|r31|*|g31|*|b31|*|a30|*|r30|*|g30|*|b30|*|
    psrlw xmm0, bs_byte  ; xmm12 = |a31|r31|g31|b31|a30|r30|g30|b30|
    punpckhbw xmm12, xmm3 ; xmm12 = |a33|*|r33|*|g33|*|b33|*|a32|*|r32|*|g32|*|b32|*|
    psrlw xmm12, bs_byte ; xmm12 = |a33|r33|g33|b33|a32|r32|g32|b32|
    paddw xmm10, xmm0 ; xmm10 = |p31+p21+p11+p01|p30+p20+p10+p00|
    paddw xmm11, xmm12 ; xmm11 = |p33+p23+p13+p03|p32+p22+p12+p02|

    punpcklbw xmm0, xmm4 ; xmm0 = |a41|*|r41|*|g41|*|b41|*|a40|*|r40|*|g40|*|b40|*|
    psrlw xmm0, bs_byte  ; xmm0 = |a41|r41|g41|b41|a40|r40|g40|b40|
    punpckhbw xmm12, xmm4 ; xmm12 = |a43|*|r43|*|g43|*|b43|*|a42|*|r42|*|g42|*|b42|*|
    psrlw xmm12, bs_byte ; xmm12 = |a43|r43|g43|b43|a42|r42|g42|b42|
    paddw xmm10, xmm0 ; xmm10 = |p41+p31+p21+p11+p01|p40+p30+p20+p10+p00|
    paddw xmm11, xmm12 ; xmm11 = |p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|

    ;Vamos a asumir que no hay problema con los a hasta aca (no lo creo).
    ; pij = |aij|rij|gij|bij|
    psllq xmm10, bs_word
    psllq xmm11, bs_word
    ; pij = |rij|gij|bij|0|

    phaddw xmm10, xmm11 ; xmm10 = |p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|p41+p31+p21+p11+p01|p40+p30+p20+p10+p00| Algo me dice que seria |p43+p33+p23+p13+p03|p41+p31+p21+p11+p01|p42+p32+p22+p12+p02|p40+p30+p20+p10+p00| pero no importa
    ; pij = |rij+gij|bij|
    phaddw xmm10, xmm10 ; xmm10 = |p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|p41+p31+p21+p11+p01|p40+p30+p20+p10+p00|p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|p41+p31+p21+p11+p01|p40+p30+p20+p10+p00|
    ; pij = |rij+gij+bij|

    movdqa xmm0, xmm10
    
    ; Hacemos lo mismo con las columnas de la derecha

    punpcklbw xmm10, xmm5 ; xmm10 = |a05|*|r05|*|g05|*|b05|*|a04|*|r04|*|g04|*|b04|*|
    psrlw xmm10, bs_byte ; xmm10 = |a05|r05|g05|b05|a04|r04|g04|b04|
    punpckhbw xmm11, xmm5 ; xmm11 = |a07|*|r07|*|g07|*|b07|*|a06|*|r06|*|g06|*|b06|*|
    psrlw xmm11, bs_byte ; xmm10 = |a07|r07|g07|b07|a06|r06|g06|b06|

    punpcklbw xmm1, xmm6 ; xmm1 = |a15|*|r15|*|g15|*|b15|*|a14|*|r14|*|g14|*|b14|*|
    psrlw xmm1, bs_byte ; xmm1 = |a15|r15|g15|b15|a14|r14|g14|b14|
    punpckhbw xmm2, xmm6 ; xmm2 = |a17|*|r17|*|g17|*|b17|*|a16|*|r16|*|g16|*|b16|*|
    psrlw xmm2, bs_byte ; xmm2 = |a17|r17|g17|b17|a16|r16|g16|b16|
    paddw xmm10, xmm1 ; xmm10 = |p15+p05|p14+p04|
    paddw xmm11, xmm2 ; xmm11 = |p17+p07|p16+p06|Aqui tambien cambio xmm12 x xmm1 y xmm13 x xmm2

    punpcklbw xmm1, xmm7 ; xmm1 = |a25|*|r25|*|g25|*|b25|*|a24|*|r24|*|g24|*|b24|*|
    psrlw xmm1, bs_byte ; xmm1 = |a25|r25|g25|b25|a24|r24|g24|b24|
    punpckhbw xmm2, xmm7 ; xmm2 = |a27|*|r27|*|g27|*|b27|*|a26|*|r26|*|g26|*|b26|*|
    psrlw xmm2, bs_byte ; xmm2 = |a27|r27|g27|b27|a26|r26|g26|b26|
    paddw xmm10, xmm1 ; xmm10 = |p25+p15+p05|p24+p14+p04|
    paddw xmm11, xmm2 ; xmm11 = |p27+p17+p07|p26+p16+p06|

    punpcklbw xmm1, xmm8 ; xmm1 = |a35|*|r35|*|g35|*|b35|*|a34|*|r34|*|g34|*|b34|*|
    psrlw xmm1, bs_byte ; xmm1 = |a35|r35|g35|b35|a34|r34|g34|b34|
    punpckhbw xmm2, xmm8 ; xmm2 = |a33|*|r33|*|g33|*|b33|*|a32|*|r32|*|g32|*|b32|*|
    psrlw xmm2, bs_byte ; xmm2 = |a33|r33|g33|b33|a32|r32|g32|b32|
    paddw xmm10, xmm1 ; xmm10 = |p35+p25+p15+p05|p34+p24+p14+p04|
    paddw xmm11, xmm2 ; xmm11 = |p37+p27+p17+p07|p36+p26+p16+p06|

    punpcklbw xmm1, xmm9 ; xmm1 = |a45|*|r45|*|g45|*|b45|*|a44|*|r44|*|g44|*|b44|*|
    psrlw xmm1, bs_byte ; xmm1 = |a45|r45|g45|b45|a44|r44|g44|b44|
    punpckhbw xmm2, xmm9 ; xmm2 = |a47|*|r47|*|g47|*|b47|*|a46|*|r46|*|g46|*|b46|*|
    psrlw xmm2, bs_byte ; xmm2 = |a47|r47|g47|b47|a46|r46|g46|b46|
    paddw xmm10, xmm1 ; xmm10 = |p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|
    paddw xmm11, xmm2 ; xmm11 = |p47+p37+p27+p17+p07|p46+p36+p26+p16+p06|


    ; pij = |aij|rij|gij|bij|
    psllq xmm10, bs_word
    psllq xmm11, bs_word
    ; pij = |rij|gij|bij|0|

    phaddw xmm10, xmm11 ; xmm10 = |p47+p37+p27+p17+p07|p46+p36+p26+p16+p06|p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|
    ; pij = |rij+gij|bij|
    phaddw xmm10, xmm10 ; xmm10 = |p47+p37+p27+p17+p07|p46+p36+p26+p16+p06|p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|p47+p37+p27+p17+p07|p46+p36+p26+p16+p06|p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|
    ; pij = |rij+gij+bij|

    punpckhwd xmm0, xmm0 ; xmm0 = |p43+p33+p23+p13+p03|*|p42+p32+p22+p12+p02|*|p41+p31+p21+p11+p01|*|p40+p30+p20+p10+p00|*|
    psrld xmm0, bs_word
    punpckhwd xmm10, xmm10 ; xmm10 = |p47+p37+p27+p17+p07|*|p46+p36+p26+p16+p06|*|p45+p35+p25+p15+p05|*|p44+p34+p24+p14+p04|*|
    psrld xmm10, bs_word ; xmm10 =  |p47+p37+p27+p17+p07|p46+p36+p26+p16+p06|p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|

    movdqa xmm1, xmm0
    psrldq xmm1, bs_dword ; xmm1 = |0|p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|p41+p31+p21+p11+p01|
    paddw xmm0, xmm1 ; xmm0 = |p43+p33+p23+p13+p03|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02|p42+p32+p22+p12+p02+p41+p31+p21+p11+p01|p41+p31+p21+p11+p01+p40+p30+p20+p10+p00|
    psrldq xmm1, bs_dword ; xmm1 = |0|p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|
    paddw xmm0, xmm1 ; xmm0 = |p43+p33+p23+p13+p03|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02+p41+p31+p21+p11+p01|p42+p32+p22+p12+p02+p41+p31+p21+p11+p01+p40+p30+p20+p10+p00|

    psrldq xmm1, bs_dword ; xmm1 = |0|p43+p33+p23+p13+p03|
    paddw xmm0, xmm1 ; xmm0 = |p43+p33+p23+p13+p03|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02+p41+p31+p21+p11+p01|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02+p41+p31+p21+p11+p01+p40+p30+p20+p10+p00|

    paddw xmm0, xmm10 ; xmm0 = |p47+p37+p27+p17+p07+p43+p33+p23+p13+p03|p46+p36+p26+p16+p06+p43+p33+p23+p13+p03+p42+p32+p22+p12+p02|p45+p35+p25+p15+p05+p43+p33+p23+p13+p03+p42+p32+p22+p12+p02+p41+p31+p21+p11+p01|sumargb22|
    pslldq xmm10, bs_dword ; xmm10 = |p46+p36+p26+p16+p06|p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|0|
    paddw xmm0, xmm10 ; xmm0 = |p47+p37+p27+p17+p07+p46+p36+p26+p16+p06+p43+p33+p23+p13+p03|p46+p36+p26+p16+p06+p45+p35+p25+p15+p05+p43+p33+p23+p13+p03+p42+p32+p22+p12+p02|sumargb23|sumargb22|
    pslldq xmm10, bs_dword ; xmm10 = |p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|0|
    paddw xmm0, xmm10 ; xmm0 = |p47+p37+p27+p17+p07+p46+p36+p26+p16+p06+p45+p35+p25+p15+p05+p43+p33+p23+p13+p03|sumargb24|sumargb23|sumargb22|
    pslldq xmm10, bs_dword ; xmm10 = |p44+p34+p24+p14+p04|0|
    paddw xmm0, xmm10 ; xmm0 = |sumargb25|sumargb24|sumargb23|sumargb22|

    pinsrw xmm3, r10d, 00h ; xmm3 = |*|*|*|alpha|
    pshufd xmm3, xmm3, 00h ; xmm3 = |alpha|alpha|alpha|alpha| Esta instruccion...hace lo que deberia hacer, lei la guia, pero....hay dos descripciones distintas....

    pmulld xmm0, xmm3 ; xmm0 = |alpha*sumargb25|alpha*sumargb24|alpha*sumargb23|alpha*sumargb22| Tiene sentido porque sumargb25 no ocupa los bits mas significativos..
    movdqa xmm1, xmm0
    movdqa xmm2, xmm0

    ; xmm15 = |a25|r25|g25|b25|a24|r24|g24|b24|a23|r23|g23|b23|a22|r22|g22|b22| Era el dato principal.
    movdqa xmm3, xmm15
    pslld xmm3, 3*bs_byte ; xmm3 = |b25|0|b24|0|b23|0|b22|0|
    psrld xmm3, 3*bs_byte ; xmm3 = |b25|b24|b23|b22|
    movdqa xmm4, xmm15
    pslld xmm4, 2*bs_byte ; xmm4 = |g25|b25|0|g24|b24|0|g23|b23|0|g22|b22|0|
    psrld xmm4, 3*bs_byte ; xmm4 = |g25|g24|g23|g22|
    movdqa xmm10, xmm15
    pslld xmm10, 1*bs_byte ; xmm10 = |r25|g25|b25|0|r24|g24|b24|0|r23|g23|b23|0|r22|g22|b22|0|
    psrld xmm10, 3*bs_byte ; xmm10 = |r25|r24|r23|r22|

    pmulld xmm0, xmm3 ; xmm0 = |alpha*sumargb25*b25|..|alpha*sumargb22*b22|
    pmulld xmm1, xmm4 ; xmm1 = |alpha*sumargb25*g25|..|alpha*sumargb22*g22|
    pmulld xmm2, xmm10 ; xmm2 = |alpha*sumargb25*r25|..|alpha*sumargb22*r22|

    pmulld xmm3, xmm14 ; xmm3 = |b25*max|b24*max|b23*max|b22*max| xmm14????????????????
    pmulld xmm4, xmm14 ; xmm4 = |g25*max|g24*max|g23*max|g22*max|
    pmulld xmm10, xmm14 ; xmm10 = |r25*max|r24*max|r23*max|r22*max|

    paddd xmm0, xmm3 ; xmm0 = |b25*max+alpha*sumargb25*b25|..|b22*max+alpha*sumargb22*b22| Aca podria ser paddw
    paddd xmm1, xmm4 ; xmm1 = |g25*max+alpha*sumargb25*g25|..|g22*max+alpha*sumargb22*g22|
    paddd xmm2, xmm10  ; xmm2 = |r25*max+alpha*sumargb25*r25|..|r22*max+alpha*sumargb22*r22|

    cvtpi2ps xmm0, mm0 ; Cambiado, necesitaba dos operandos, y el source debia ser mmx. Creo que no cambie el resultado pero atenti
    cvtpi2ps xmm1, mm1 
    cvtpi2ps xmm2, mm2

    divps xmm0, xmm13 ; xmm0 = |b25'|..|b22'|
    divps xmm1, xmm13 ; xmm1 = |g25'|..|g22'|
    divps xmm2, xmm13 ; xmm2 = |r25'|..|r22'|

    cvtps2dq xmm0, xmm0 ; lo mismo que en linea 212
    cvtps2dq xmm1, xmm1
    cvtps2dq xmm2, xmm2

    packusdw xmm0, xmm0 ; xmm0 = |b25'|b24'|b23'|b22'|b25'|b24'|b23'|b22'|
    movdqa xmm3, xmm0
    packusdw xmm1, xmm1 ; xmm1 = |g25'|g24'|g23'|g22'|g25'|g24'|g23'|g22'|
    pshufhw xmm0, xmm0, 11111010b ; xmm0 = |b25'|b25'|b24'|b24'|b25'|b24'|b23'|b22'|
    pshufhw xmm0, xmm0, 01010000b ; xmm0 = |b25'|b25'|b24'|b24'|b23'|b23'|b22'|b22'|
    pshufhw xmm1, xmm1, 11111010b ; xmm1 = |g25'|g25'|g24'|g24'|g25'|g24'|g23'|g22'|
    pshufhw xmm1, xmm1, 01010000b ; xmm1 = |g25'|g25'|g24'|g24'|g23'|g23'|g22'|g22'|
    psrld xmm0, bs_word ; xmm0 = |0|b25'|0|b24'|0|b23'|0|b22'|
    pslld xmm1, bs_word ; xmm0 = |g25'|0|g24'|0|g23'|0|g22'|0|
    paddw xmm0, xmm1 ; xmm0 = |g25'|b25'|g24'|b24'|g23'|b23'|g22'|b22'|
    packuswb xmm0, xmm0 ; xmm0 = |g25'|b25'|g24'|b24'|g23'|b23'|g22'|b22'|g25'|b25'|g24'|b24'|g23'|b23'|g22'|b22'|
    pshufhw xmm0, xmm0, 11111010b ; xmm0 = |g25'|b25'|g25'|b25'|g24'|b24'|g24'|b24'|g25'|b25'|g24'|b24'|g23'|b23'|g22'|b22'|
    pshufhw xmm0, xmm0, 01010000b ; xmm0 = |g25'|b25'|g25'|b25'|g24'|b24'|g24'|b24'|g23'|b23'|g23'|b23'|g22'|b22'|g22'|b22'|
    psrld xmm0, bs_word ; xmm0 = |0|g25'|b25'|0|g24'|b24'|0|g23'|b23'|0|g22'|b22'|   
    packuswb xmm2, xmm2 ; xmm2 = |r25'|r24'|r23'|r22'|r25'|r24'|r23'|r22'|
    pshufhw xmm2, xmm2, 11111010b ; xmm2 = |r25'|r25'|r24'|r24'|r25'|r24'|r23'|r22'|
    pshufhw xmm2, xmm2, 01010000b ; xmm2 = |r25'|r25'|r24'|r24'|r23'|r23'|r22'|r22'|
    psrld xmm2, bs_word ; xmm2 = |0|r25'|0|r24'|0|r23'|0|r22'|
    packuswb xmm2, xmm2 ; xmm2 = |0|r25'|0|r24'|0|r23'|0|r22'|0|r25'|0|r24'|0|r23'|0|r22'|
    pshufhw xmm2, xmm2, 11111010b ; xmm2 = |0|r25'|0|r25'|0|r24'|0|r24'|0|r25'|0|r24'|0|r23'|0|r22'|
    pshufhw xmm2, xmm2, 01010000b ; xmm2 = |0|r25'|0|r25'|0|r24'|0|r24'|0|r23'|0|r23'|0|r22'|0|r22'|
    pslld xmm2, bs_word ; xmm2 = |0|r25'|0|0|0|r24'|0|0|0|r23'|0|0|0|r22'|0|0|
    paddd xmm0, xmm2 ;Queda  xmm0 = |0|r25'|g25'|b25'|0|r24'|g24'|b24'|0|r23'|g23'|b23'|0|r22'|g22'|b22'|   
    psrld xmm15, 3*bs_byte ; xmm15 = |0|0|0|a25|0|0|0|a24|0|0|0|a23|0|0|0|a22|
    pslld xmm15, 3*bs_byte ; xmm15 = |a25|0|0|0|a24|0|0|0|a23|0|0|0|a22|0|0|0|
    paddd xmm0, xmm15 ; xmm15 = |a25|r25'|g25'|b25'|a24|r24'|g24'|b24'|a23|r23'|g23'|b23'|a22|r22'|g22'|b22'|
    movdqu [rsi + 2*r9 + 2*s_pixel], xmm0 ; r9 = r9d

    ;Veamos como hacer el ciclo
    ;r12 =columnas r11= filas. r9= dst_row_size, r8d = src_row_size rdi = *source r14= dst_row_size - 2

     
    inc r12 ; r12 avanza a la siguiente columna
    cmp r14, r12
    jz  .cambio_fila
    inc  rdi; Deberia ser  s_pixel ;rdi = rdi +4. Osea, apunta a proximo pixel.pero da core si hago esto.(incluso si no le hago nada mas a rdi, rsi)
    inc  rsi; Deberia ser s_pixel ; rsi = rsi +4. Osea, apunta a proximo pixel.
    jmp .empiezo


.terminar:
    pop r15
    pop r14 
    pop r13
    pop rbx
    pop r12
    pop rbp
    ret

.cargar:
; Se encarga de mover los pixeles de memoria a los registros.
    mov rbx, rdi
    movdqu xmm0, [rbx] ; xmm0 = |a03|r03|g03|b03|a02|r02|g02|b02|a01|r01|g01|b01|a00|r00|g00|b00|
    movdqu xmm5, [rbx+s_xmm] ; xmm5 = |a07|r07|g07|b07|a06|r06|g06|b06|a05|r05|g05|b05|a04|r04|g04|b04|

    add rbx, r8
    movdqu xmm1, [rbx] ; xmm1 = |a13|r13|g13|b13|a12|r12|g12|b12|a11|r11|g11|b11|a10|r10|g10|b10|
    movdqu xmm6, [rbx+s_xmm] ; xmm6 = |a17|r17|g17|b17|a16|r16|g16|b16|a15|r15|g15|b15|a14|r14|g14|b14|

    add rbx, r8
    movdqu xmm2, [rbx] ; xmm2 = |a23|r23|g23|b23|a22|r22|g22|b22|a21|r21|g21|b21|a20|r20|g20|b20|
    movdqu xmm7, [rbx+s_xmm] ; xmm7 = |a27|r27|g27|b27|a26|r26|g26|b26|a25|r25|g25|b25|a24|r24|g24|b24|

    movdqa xmm8, xmm2 
    movdqa xmm15, xmm7

    psrldq xmm8, s_qword ; xmm14 = |0|a23|r23|g23|b23|a22|r22|g22|b22|
    pslldq xmm15, s_qword ; xmm15 = |a25|r25|g25|b25|a24|r24|g24|b24|0|

    ADDPS xmm15, xmm8 ; xmm15 = |a25|r25|g25|b25|a24|r24|g24|b24|a23|r23|g23|b23|a22|r22|g22|b22| ; Antes decia, paddub, creo que PADDQ podria funcar tambien. 
    ;estos de aqui arriba son los pixeles que nos interesan

    add rbx, r8
    movdqu xmm3, [rbx] ; xmm3 = |a33|r33|g33|b33|a32|r32|g32|b32|a31|r31|g31|b31|a30|r30|g30|b30|
    movdqu xmm8, [rbx+s_xmm] ; xmm8 = |a37|r37|g37|b37|a36|r36|g36|b36|a35|r35|g35|b35|a34|r34|g34|b34|

    add rbx, r8
    movdqu xmm4, [rbx] ; xmm4 = |a43|r43|g43|b43|a42|r42|g42|b42|a41|r41|g41|b41|a40|r40|g40|b40|
    movdqu xmm9, [rbx+s_xmm] ; xmm9 = |a47|r47|g47|b47|a46|r46|g46|b46|a45|r45|g45|b45|a44|r44|g44|b44|

    add rbx, r8
    jmp .cargado

.cargar_precarga:
; Igual que cargar pero aprovechamos que en la iteracion anterior usamos los pixeles de las columnas i+2 hasta i+6.
    movdqa xmm0, xmm5
    movdqa xmm1, xmm6
    movdqa xmm2, xmm7
    movdqa xmm3, xmm8
    movdqa xmm4, xmm9

    ;No se si esto es buena idea despues de lo destrozados que quedaron los registros

    lea rbx, [rdi+s_xmm]
    movdqu xmm5, [rbx] ; xmm1 = |a07|r07|g07|b07|a06|r06|g06|b06|a05|r05|g05|b05|a04|r04|g04|b04|

    add rbx, r8
    movdqu xmm6, [rbx] ; xmm3 = |a17|r17|g17|b17|a16|r16|g16|b16|a15|r15|g15|b15|a14|r14|g14|b14|

    add rbx, r8
    movdqu xmm7, [rbx] ; xmm5 = |a27|r27|g27|b27|a26|r26|g26|b26|a25|r25|g25|b25|a24|r24|g24|b24|

    movdqa xmm8, xmm2 
    movdqa xmm15, xmm7

    psrldq xmm8, s_qword ; xmm8 = |0|a23|r23|g23|b23|a22|r22|g22|b22|
    pslldq xmm15, s_qword ; xmm15 = |a25|r25|g25|b25|a24|r24|g24|b24|0|

    paddb xmm15, xmm8 ; xmm15 = |a25|r25|g25|b25|a24|r24|g24|b24|a23|r23|g23|b23|a22|r22|g22|b22|

    add rbx, r8
    movdqu xmm8, [rbx] ; xmm7 = |a37|r37|g37|b37|a36|r36|g36|b36|a35|r35|g35|b35|a34|r34|g34|b34|

    add rbx, r8
    movdqu xmm9, [rbx] ; xmm9 = |a47|r47|g47|b47|a46|r46|g46|b46|a45|r45|g45|b45|a44|r44|g44|b44|
    jmp .cargado

; el resultado de suma rgb,  tiene que estar en 32 bits



.cambio_fila:
;Aca solo venimos si r14 - r12 = 0;
cmp ecx, r11d ; Vemos si estamos en la ultima fila viable
jz .terminar  ;si lo estamos, acabamos (porque si llegamos aqui la fila esta completa)
inc r11 ; r11 =r11d
;Aqui nos falta que rdi apunte a la primera posicion de la fila (porque estuve moviendo su valor)
sub rdi, r15 ; aqui pongo a rdi apuntando al principio de la fila
sub rsi, r15 ;Idem
add rdi, r9 ;pasamos a la fila siguiente
add rsi, r9 ;pasamos a la fila siguiente
xor r12, r12 ; reseteo r12.
jmp .empiezo