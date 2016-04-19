%define PIXELXITERACION 4
%define BYTESXPIXEL 4
%define bs_word 16
%define bs_byte 16
section .data
DEFAULT REL

coef: dd 0.3, 0.3, 0.2, 0.2
reordenar: db 0xff, 0x00, 0x02, 0x08, 0xff, 0x06, 0x04, 0x0c, 0xff, 0x03, 0x01, 0x0b, 0xff, 0x07, 0x05, 0x0f

; |  f  |  e  |  d  |  c  |  b  |  a  |  9  |  8  |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
; | r3' | r1' | r3' | r1' | r2' | r0' | r2' | r0' | b3' | b1' | g3' | g1' | b2' | b0' | g2' | g0' |

; | r3' | g3' | b3' |  0  | r2' | g2' | b2' |  0  | r1' | g1' | b1' |  0  | r0' | b0' | g0' |  0  |

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
    shr rcx, 2 ; Transformamos pixeles a bytes

    ; rax = indice fila.
    ; rbx = indice columna.
    xor rax, rax
    xor rbx, rbx
    
    and r8, 00000000ffffffffh
    and r9, 00000000ffffffffh

    movdqu xmm5, [coef]
    movdqu xmm6, [reordenar]
.loop:
    movdqu xmm0, [rdi + rbx] ; xmm0 = | r3 | g3 | b3 | a3 | r2 | g2 | b2 | a2 | r1 | g1 | b1 | a1 | r0 | g0 | b0 | a0 |
    pxor xmm7, xmm7
    movdqa xmm1, xmm0 ; xmm1 = xmm0
    punpckhbw xmm0, xmm7 ; xmm0 = | r3 | g3 | b3 | a3 | r2 | g2 | b2 | a2 |
    punpcklbw xmm1, xmm7 ; xmm1 = | r1 | g1 | b1 | a1 | r0 | g0 | b0 | a0 |
    movdqa xmm2, xmm0
    movdqa xmm3, xmm1
    psrlq xmm2, bs_word ; xmm2 = | 0 | r3 | g3 | b3 | 0 | r2 | g2 | b2 | 
    psrlq xmm3, bs_word ; xmm3 = | 0 | r1 | g1 | b1 | 0 | r0 | g0 | b0 | 
    phaddw xmm2, xmm3 ; xmm2 = | r3 | g3 + b3 | r1 | g1 + b1 | r2 | g2 + b2 | r0 | g0 + b0 |
    phaddw xmm2, xmm2 ; xmm2 = | r3+g3+b3 | r1+g1+b1 | r3+g3+b3 | r1+g1+b1 | r2+g2+b2 | r0+g0+b0 | r2+g2+b2 | r0+g0+b0 |
    movdqa xmm4, xmm2 
    psrlw xmm4, 1 ; xmm4 = | s3/2 | s1/2 | s3/2 | s1/2 | s2/2 | s0/2 | s2/2 | s0/2 | = | r3' | r1' | r3' | r1' | r2' | r0' | r2' | r0' |

    punpcklwd xmm3, xmm2 ; xmm3 = | s2 | s0 | s2 | s0 |
    punpckhwd xmm2, xmm2 ; xmm2 = | s3 | s1 | s3 | s1 |
    cvtdq2ps xmm2, xmm2 ; xmm2 = | s3 | s1 | s3 | s1 |
    cvtdq2ps xmm3, xmm3 ; xmm3 = | s2 | s0 | s2 | s0 |

    mulps xmm2, xmm5 ; xmm2 = | 0.2*s3 | 0.2*s1 | 0.3*s3 | 0.3*s1 |
    mulps xmm3, xmm5 ; xmm3 = | 0.2*s2 | 0.2*s0 | 0.3*s2 | 0.3*s0 |

    cvttps2dq xmm2, xmm2 ; xmm2 = | b3' | b1' | g3' | g1' |
    cvttps2dq xmm3, xmm3 ; xmm3 = | b2' | b0' | g2' | g0' |

    packusdw xmm3, xmm2 ; xmm3 = | b3' | b1' | g3' | g1' | b2' | b0' | g2' | g0' |
    packuswb xmm2, xmm4 ; xmm2 = | r3' | r1' | r3' | r1' | r2' | r0' | r2' | r0' | b3' | b1' | g3' | g1' | b2' | b0' | g2' | g0' |
    pshufb xmm2, xmm6 ; xmm2 = | r3' | g3' | b3' |  0  | r2' | g2' | b2' |  0  | r1' | g1' | b1' |  0  | r0' | b0' | g0' |  0  |

    pslld xmm0, bs_byte*3 ; xmm0 = | a3 | 0 | 0 | 0 | a2 | 0 | 0 | 0 | a1 | 0 | 0 | 0 | a0 | 0 | 0 | 0 |
    psrld xmm0, bs_byte*3 ; xmm0 = | 0 | 0 | 0 | a3 | 0 | 0 | 0 | a2 | 0 | 0 | 0 | a1 | 0 | 0 | 0 | a0 |

    paddb xmm0, xmm2 ; xmm0 = | r3' | g3' | b3' |  a3  | r2' | g2' | b2' |  a2  | r1' | g1' | b1' |  a1  | r0' | b0' | g0' |  a0  |
    movdqu [rdi + rbx], xmm0
    
    add rbx, BYTESXPIXEL * PIXELXITERACION
    cmp ebx, r8d
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
