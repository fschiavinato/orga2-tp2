%define PIXELXITERACION 4
%define BYTESXPIXEL 4
%define bs_word 16
%define bs_byte 8
section .data
DEFAULT REL

coefb: dd 0.2, 0.2, 0.2, 0.2
coefg: dd 0.3, 0.3, 0.3, 0.3
reordenar: db 0x02, 0x06, 0x0a, 0xff, 0x03, 0x07, 0x0b, 0xff, 0x00, 0x04, 0x08, 0xff, 0x01, 0x05, 0x09, 0xff


; Lo que quiero
; |  f  |  e  |  d  |  c  |  b  |  a  |  9  |  8  |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
; |  0  | r0' | g0' | b0' |  0  | r1' | g1' | b1' |  0  | r2' | g2' | b2' |  0  | r3' | g3' | b3' |
; Lo que tengo
; |  f  |  e  |  d  |  c  |  b  |  a  |  9  |  8  |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
; | r2' | r3' | r0' | r1' | r2' | r3' | r0' | r1' | g2' | g3' | g0' | g1' | b2' | b3' | b0' | b1' |

; 

section .text
global sepia_asm
sepia_asm:
; void sepia_asm    (
;                       unsigned char *src, 
;                       unsigned char *dst, 
;                       int cols, 
;                       int filas,
;                       int src_row_size, 
;                       int dst_row_size);
;   rdi = src
;   rsi = dst
;   edx = cols
;   ecx = filas
;   r8d = src_row_size
;   r9d = dst_row_size
    push rbp
    mov rbp, rsp
    push rbx
    shl rdx, 2 ; Transformamos pixeles a bytes

    ; rax = indice fila.
    ; rbx = indice columna.
    xor rax, rax
    xor rbx, rbx
    
    and r8, 00000000ffffffffh
    and r9, 00000000ffffffffh

    movdqu xmm5, [coefb]
    movdqu xmm6, [coefg]
    movdqu xmm7, [reordenar]
    pxor xmm8, xmm8

.loop:
    movdqu xmm0, [rdi + rbx] ; xmm0 = | a0 | r0 | g0 | b0 | a1 | r1 | g1 | b1 | a2 | r2 | g2 | b2 | a3 | r3 | g3 | b3 |
    movdqa xmm1, xmm0 ; xmm1 = xmm0
    punpckhbw xmm0, xmm8 ; xmm0 = | a0 | r0 | g0 | b0 | a1 | r1 | g1 | b1 |
    punpcklbw xmm1, xmm8 ; xmm1 = | a2 | r2 | g2 | b2 | a3 | r3 | g3 | b3 |
    movdqa xmm2, xmm0
    movdqa xmm3, xmm1
    psllq xmm2, bs_word ; xmm2 = | r0 | g0 | b0 | 0 | r1 | g1 | b1 | 0 | 
    psllq xmm3, bs_word ; xmm3 = | r2 | g2 | b2 | 0 | r3 | g3 | b3 | 0 | 
    phaddw xmm2, xmm3 ; xmm2 = | r2+g2 | b2 | r3+g3 | b3 | r0+g0 | b0 | r1+g1 | b1 |
    phaddw xmm2, xmm2 ; xmm2 = | r2+g2+b2 | r3+g3+b3 | r0+g0+b0 | r1+g1+b1 | r2+g2+b2 | r3+g3+b3 | r0+g0+b0 | r1+g1+b1 |
    movdqa xmm4, xmm2 
    psrlw xmm4, 1 ; xmm4 = | s2/2 | s3/2 | s0/2 | s1/2 | s2/2 | s3/2 | s0/2 | s1/2 | = | r2' | r3' | r0' | r1' | r2' | r3' | r0' | r1' |

    punpckhwd xmm2, xmm8 ; xmm2 = | s2 | s3 | s0 | s1 |
    cvtdq2ps xmm2, xmm2

    movdqa xmm3, xmm2

    mulps xmm2, xmm5 ; xmm2 = | b2' | b3' | b0' | b1' |
    mulps xmm3, xmm6 ; xmm3 = | g2' | g3' | g0' | g1' |

    cvttps2dq xmm2, xmm2
    cvttps2dq xmm3, xmm3

    packusdw xmm2, xmm3 ; xmm3 = | g2' | g3' | g0' | g1' | b2' | b3' | b0' | b1' |
    packuswb xmm2, xmm4 ; xmm2 = | r2' | r3' | r0' | r1' | r2' | r3' | r0' | r1' | g2' | g3' | g0' | g1' | b2' | b3' | b0' | b1' |
    pshufb xmm2, xmm7 ; xmm2 = |  0  | r0' | g0' | b0' |  0  | r1' | g1' | b1' |  0  | r2' | g2' | b2' |  0  | r3' | g3' | b3' |

    psrld xmm0, bs_byte*3 ; xmm0 = | 0 | 0 | 0 | a0 | 0 | 0 | 0 | a1 | 0 | 0 | 0 | a2 | 0 | 0 | 0 | a3 |
    pslld xmm0, bs_byte*3 ; xmm0 = | a0 | 0 | 0 | 0 | a1 | 0 | 0 | 0 | a2 | 0 | 0 | 0 | a3 | 0 | 0 | 0 |

    paddb xmm0, xmm2 ; xmm0 = | a0 | r0' | g0' | b0' | a1 | r1' | g1' | b1' | a2 | r2' | g2' | b2' | a3 | r3' | g3' | b3' |
    movdqu [rsi + rbx], xmm0
    
    add rbx, BYTESXPIXEL * PIXELXITERACION
    cmp rbx, r8
    jl .loop

    xor rbx, rbx
    inc rax
    add rdi, r8
    add rsi, r9
    cmp eax, ecx
    jl .loop
    
    pop rbx
    pop rbp
    ret
