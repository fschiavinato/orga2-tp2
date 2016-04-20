%define pXi 4
%define 
global ldr_asm



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
	xor r12, r12
	mov r12d, ecx
	sub r12, 4

	xor rax, rax;fila
	xor r11, r11;columna
	.loopnotocararab:
		movdqu xmm0, [rdi+r11*16]
		movdqu [rsi+r11*16], xmm0
		add r11, pXi
		cmp r11, edx
		jl .loopnotocararab
		xor r11,r11
		add edi, r8d
		add esi, r9d
		inc rax
		cmp rax, 2
		jl .loopnotocararab
		je .loopcambios
		cmp eax, ecx
		jl .loopnotocararab
		je .fin
	.loopcambios:
		cmp r11, 0
		je .cambioizq
		cmp r11d, r12d
		je .cambioder
		movdqu xmm0, [rdi+r11*16]; xmm0 = | a0 | r0 | g0 | b0 | a1 | r1 | g1 | b1 | a2 | r2 | g2 | b2 | a3 | r3 | g3 | b3 |
		movdqu xmm1, [rdi+r11*16-8]
		movdqu xmm2, [rdi+r11*16-4]
		movdqu xmm3, [rdi+r11*16+4]
		movdqu xmm4, [rdi+r11*16+8]
		paddb xmm0, xmm1
		paddb xmm0, xmm2
		paddb xmm0, xmm3
		paddb xmm0, xmm4
		movdqu xmm1, [rdi+r11*16-8]
		movdqu xmm2, [rdi+r11*16-4]
		movdqu xmm3, [rdi+r11*16+4]
		movdqu xmm4, [rdi+r11*16+8]
		paddb xmm0, xmm1
		paddb xmm0, xmm2
		paddb xmm0, xmm3
		paddb xmm0, xmm4
		movdqu xmm1, [rdi+r11*16-8]
		movdqu xmm2, [rdi+r11*16-4]
		movdqu xmm3, [rdi+r11*16+4]
		movdqu xmm4, [rdi+r11*16+8]
		paddb xmm0, xmm1
		paddb xmm0, xmm2
		paddb xmm0, xmm3
		paddb xmm0, xmm4
		movdqu xmm1, [rdi+r11*16-8]
		movdqu xmm2, [rdi+r11*16-4]
		movdqu xmm3, [rdi+r11*16+4]
		movdqu xmm4, [rdi+r11*16+8]
		paddb xmm0, xmm1
		paddb xmm0, xmm2
		paddb xmm0, xmm3
		paddb xmm0, xmm4
		movdqu xmm1, [rdi+r11*16-8]
		movdqu xmm2, [rdi+r11*16-4]
		movdqu xmm3, [rdi+r11*16+4]
		movdqu xmm4, [rdi+r11*16+8]
		paddb xmm0, xmm1
		paddb xmm0, xmm2
		paddb xmm0, xmm3
		paddb xmm0, xmm4



	.fin:
		pop r12
		pop rbp
		ret
 
