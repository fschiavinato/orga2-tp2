%define pXi 4
%define max 4876875
global ldr_asm
%define bs_word 16


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
;	r10 = alpha

ldr_asm:
	push rbp
	mov rbp, rsp
	mov r10, [rbp+16]
	push r12
	push r13
	xor r12, r12
	mov r12d, ecx
	xor rax, rax;fila
	xor r11, r11;columna
	xor r13, r13 
	mov r13d, edx
	sub r13d, 4 ; le resto a r13d los 4 finales de cols a los que no accedo
	sub r12d, 4; le resto a r12d los 4 finales de fils a los que no accedo
	pxor xmm8, xmm8
	; Avazamos el contador de filas, hasta tener  src_row_size - 4. Reiniciamos el contador
	; xmm0 es el regisro donde se guardan los pixelesa procesar actualmente.	
	.ciclodefilas:
	cmp eax, r12d
	JE .nuevafila:
	movdqu xmm0, [rdi + r8d*2 + 16] ; me muevo a la posicion del medio de dos filas más abajo
	movdqa xmm1, xmm0 ; xmm1 = xmm0
	JMP .suma
	inc eax
	JMP .ciclodefilas 

	.nuevafila
	xor eax, eax ; vuelvo a la primera fila
	cmp r11, r13d
	JE .fin; 


	.suma:	
    ; movdqu xmm8, mascara, con mascara = aun no lo he hecho. mascara = | a0 | 0 | 0 | 0 | a1 | 0 | 0 | 0 | a2 | 0 | 0 | 0 | a3 | 0 | 0 | 0 |
	psrld xmm0, bs_byte ; xmm0 = | 0 | r0 | g0 | b0 | 0 | r1 | g1 | b1 | 0 | r2 | g2 | b2 | 0 | r3 | g3 | b3 | 
    






	

	.fin:

	 	pop r13
		pop r12
		pop rbp
		ret
 



; el resultado de suma rgb,  tiene que estar en 32 bits
