%define pXi 4
%define max 4876875
global ldr_asm
%define bs_word 16
%define bs_dword 32
%define s_xmm 16
%define s_dqword 16
%define s_qword 8


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

    and r8, 00000000FFFFFFFFh
    and r9, 00000000FFFFFFFFh

    xor r11, r11 ; indice fila
    xor r12, r12 ; indice columna
    
    

    ; estamos afuera del marco
    and r12, r12 ; Nos fijamos si es cero
    jz .cargar
    jmp .cargar_precarga

.cargado:
    punpcklbw xmm10, xmm0 ; xmm10 = |a01|r01|g01|b01|a00|r00|g00|b00|
    punpckhbw xmm11, xmm0 ; xmm11 = |a03|r03|g03|b03|a02|r02|g02|b02|

    punpcklbw xmm12, xmm1 ; xmm12 = |a11|r11|g11|b11|a10|r10|g10|b10|
    punpckhbw xmm13, xmm1 ; xmm13 = |a13|r13|g13|b13|a12|r12|g12|b12|
    paddw xmm10, xmm12 ; xmm10 = |p11+p01|p10+p00|
    paddw xmm11, xmm13 ; xmm11 = |p13+p03|p12+p02|

    punpcklbw xmm12, xmm2 ; xmm12 = |a21|r21|g21|b21|a20|r20|g20|b20|
    punpckhbw xmm13, xmm2 ; xmm13 = |a23|r23|g23|b23|a22|r22|g22|b22|
    paddw xmm10, xmm12 ; xmm10 = |p21+p11+p01|p20+p10+p00|
    paddw xmm11, xmm13 ; xmm11 = |p23+p13+p03|p22+p12+p02|

    punpcklbw xmm12, xmm3 ; xmm12 = |a31|r31|g31|b31|a30|r30|g30|b30|
    punpckhbw xmm13, xmm3 ; xmm13 = |a33|r33|g33|b33|a32|r32|g32|b32|
    paddw xmm10, xmm12 ; xmm10 = |p31+p21+p11+p01|p30+p20+p10+p00|
    paddw xmm11, xmm13 ; xmm11 = |p33+p23+p13+p03|p32+p22+p12+p02|

    punpcklbw xmm12, xmm4 ; xmm12 = |a41|r41|g41|b41|a40|r40|g40|b40|
    punpckhbw xmm13, xmm4 ; xmm13 = |a43|r43|g43|b43|a42|r42|g42|b42|
    paddw xmm10, xmm12 ; xmm10 = |p41+p31+p21+p11+p01|p40+p30+p20+p10+p00|
    paddw xmm11, xmm13 ; xmm11 = |p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|


    ; pij = |aij|rij|gij|bij|
    psllq xmm10, bs_word
    psllq xmm11, bs_word
    ; pij = |rij|gij|bij|0|

    phaddw xmm10, xmm11 ; xmm10 = |p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|p41+p31+p21+p11+p01|p40+p30+p20+p10+p00|
    ; pij = |rij+gij|bij|
    phaddw xmm10, xmm10 ; xmm10 = |p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|p41+p31+p21+p11+p01|p40+p30+p20+p10+p00|p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|p41+p31+p21+p11+p01|p40+p30+p20+p10+p00|
    ; pij = |rij+gij+bij|

    movdqa xmm0, xmm10
    
    ; Hacemos lo mismo con las columnas de la derecha

    punpcklbw xmm10, xmm5 ; xmm10 = |a05|r05|g05|b05|a04|r04|g04|b04|
    punpckhbw xmm11, xmm5 ; xmm11 = |a07|r07|g07|b07|a06|r06|g06|b06|

    punpcklbw xmm12, xmm6 ; xmm12 = |a15|r15|g15|b15|a14|r14|g14|b14|
    punpckhbw xmm13, xmm6 ; xmm13 = |a17|r17|g17|b17|a16|r16|g16|b16|
    paddw xmm10, xmm12 ; xmm10 = |p15+p05|p14+p04|
    paddw xmm11, xmm13 ; xmm11 = |p17+p07|p16+p06|

    punpcklbw xmm12, xmm7 ; xmm12 = |a25|r25|g25|b25|a24|r24|g24|b24|
    punpckhbw xmm13, xmm7 ; xmm13 = |a27|r27|g27|b27|a26|r26|g26|b26|
    paddw xmm10, xmm12 ; xmm10 = |p25+p15+p05|p24+p14+p04|
    paddw xmm11, xmm13 ; xmm11 = |p27+p17+p07|p26+p16+p06|

    punpcklbw xmm12, xmm8 ; xmm12 = |a35|r35|g35|b35|a34|r34|g34|b34|
    punpckhbw xmm13, xmm8 ; xmm13 = |a33|r33|g33|b33|a32|r32|g32|b32|
    paddw xmm10, xmm12 ; xmm10 = |p35+p25+p15+p05|p34+p24+p14+p04|
    paddw xmm11, xmm13 ; xmm11 = |p37+p27+p17+p07|p36+p26+p16+p06|

    punpcklbw xmm12, xmm9 ; xmm12 = |a45|r45|g45|b45|a44|r44|g44|b44|
    punpckhbw xmm13, xmm9 ; xmm13 = |a47|r47|g47|b47|a46|r46|g46|b46|
    paddw xmm10, xmm12 ; xmm10 = |p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|
    paddw xmm11, xmm13 ; xmm11 = |p47+p37+p27+p17+p07|p46+p36+p26+p16+p06|


    ; pij = |aij|rij|gij|bij|
    psllq xmm10, bs_word
    psllq xmm11, bs_word
    ; pij = |rij|gij|bij|0|

    phaddw xmm10, xmm11 ; xmm10 = |p47+p37+p27+p17+p07|p46+p36+p26+p16+p06|p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|
    ; pij = |rij+gij|bij|
    phaddw xmm10, xmm10 ; xmm10 = |p47+p37+p27+p17+p07|p46+p36+p26+p16+p06|p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|p47+p37+p27+p17+p07|p46+p36+p26+p16+p06|p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|
    ; pij = |rij+gij+bij|

    punpckhwd xmm0, xmm0 ; xmm0 = |p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|p41+p31+p21+p11+p01|p40+p30+p20+p10+p00|
    punpckhwd xmm10, xmm10 ; xmm10 = |p47+p37+p27+p17+p07|p46+p36+p26+p16+p06|p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|

    movdqa xmm1, xmm0
    psrldq xmm1, bs_dword ; xmm1 = |0|p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|p41+p31+p21+p11+p01|
    padddw xmm0, xmm1 ; xmm0 = |p43+p33+p23+p13+p03|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02|p42+p32+p22+p12+p02+p41+p31+p21+p11+p01|p41+p31+p21+p11+p01+p40+p30+p20+p10+p00|
    psrldq xmm1, bs_dword ; xmm1 = |0|p43+p33+p23+p13+p03|p42+p32+p22+p12+p02|
    padddw xmm0, xmm1 ; xmm0 = |p43+p33+p23+p13+p03|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02+p41+p31+p21+p11+p01|p42+p32+p22+p12+p02+p41+p31+p21+p11+p01+p40+p30+p20+p10+p00|

    psrldq xmm1, bs_dword ; xmm1 = |0|p43+p33+p23+p13+p03|
    padddw xmm0, xmm1 ; xmm0 = |p43+p33+p23+p13+p03|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02+p41+p31+p21+p11+p01|p43+p33+p23+p13+p03+p42+p32+p22+p12+p02+p41+p31+p21+p11+p01+p40+p30+p20+p10+p00|

    padddw xmm0, xmm10 ; xmm0 = |p47+p37+p27+p17+p07+p43+p33+p23+p13+p03|p46+p36+p26+p16+p06+p43+p33+p23+p13+p03+p42+p32+p22+p12+p02|p45+p35+p25+p15+p05+p43+p33+p23+p13+p03+p42+p32+p22+p12+p02+p41+p31+p21+p11+p01|sumargb22|
    pslldq xmm10, bs_dword ; xmm10 = |p46+p36+p26+p16+p06|p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|0|
    padddw xmm0, xmm10 ; xmm0 = |p47+p37+p27+p17+p07+p46+p36+p26+p16+p06+p43+p33+p23+p13+p03|p46+p36+p26+p16+p06+p45+p35+p25+p15+p05+p43+p33+p23+p13+p03+p42+p32+p22+p12+p02|sumargb23|sumargb22|
    pslldq xmm10, bs_dword ; xmm10 = |p45+p35+p25+p15+p05|p44+p34+p24+p14+p04|0|
    padddw xmm0, xmm10 ; xmm0 = |p47+p37+p27+p17+p07+p46+p36+p26+p16+p06+p45+p35+p25+p15+p05+p43+p33+p23+p13+p03|sumargb24|sumargb23|sumargb22|
    pslldq xmm10, bs_dword ; xmm10 = |p44+p34+p24+p14+p04|0|
    padddw xmm0, xmm10 ; xmm0 = |sumargb25|sumargb24|sumargb23|sumargb22|

    movdqa xmm1, xmm0
    movdqa xmm2, xmm0


        
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

    movdqa xmm14, xmm2 
    movdqa xmm15, xmm7

    psrldq xmm14, s_qword ; xmm14 = |0|a23|r23|g23|b23|a22|r22|g22|b22|
    pslldq xmm15, s_qword ; xmm15 = |a25|r25|g25|b25|a24|r24|g24|b24|0|

    paddub xmm15, xmm14 ; xmm15 = |a25|r25|g25|b25|a24|r24|g24|b24|a23|r23|g23|b23|a22|r22|g22|b22|

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

    lea rbx, [rdi+s_xmm]
    movdqu xmm5, [rbx] ; xmm1 = |a07|r07|g07|b07|a06|r06|g06|b06|a05|r05|g05|b05|a04|r04|g04|b04|

    add rbx, r8
    movdqu xmm6, [rbx] ; xmm3 = |a17|r17|g17|b17|a16|r16|g16|b16|a15|r15|g15|b15|a14|r14|g14|b14|

    add rbx, r8
    movdqu xmm7, [rbx] ; xmm5 = |a27|r27|g27|b27|a26|r26|g26|b26|a25|r25|g25|b25|a24|r24|g24|b24|

    movdqa xmm14, xmm2 
    movdqa xmm15, xmm7

    psrldq xmm14, s_qword ; xmm14 = |0|a23|r23|g23|b23|a22|r22|g22|b22|
    pslldq xmm15, s_qword ; xmm15 = |a25|r25|g25|b25|a24|r24|g24|b24|0|

    paddb xmm15, xmm14 ; xmm15 = |a25|r25|g25|b25|a24|r24|g24|b24|a23|r23|g23|b23|a22|r22|g22|b22|

    add rbx, r8
    movdqu xmm8, [rbx] ; xmm7 = |a37|r37|g37|b37|a36|r36|g36|b36|a35|r35|g35|b35|a34|r34|g34|b34|

    add rbx, r8
    movdqu xmm9, [rbx] ; xmm9 = |a47|r47|g47|b47|a46|r46|g46|b46|a45|r45|g45|b45|a44|r44|g44|b44|
    jmp .cargado

; el resultado de suma rgb,  tiene que estar en 32 bits
