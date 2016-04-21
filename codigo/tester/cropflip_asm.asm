global cropflip_asm
%define PIXELXIT 4
%define BYTESXPIXEL 4

section .text
;void cropflip_asm(unsigned char *src,
;                  unsigned char *dst,
;		           int cols, int filas,
;                  int src_row_size,
;                  int dst_row_size,
;                  int tamx, int tamy,
;                  int offsetx, int offsety);

cropflip_asm:
    ; rdi = src
    ; rsi = dst
    ; edx = cols
    ; ecx = filas
    ; r8d = src_row_size
    ; r9d = dst_row_size
    ; [rsp+8] = tamx
    ; [rsp+16] = tamy
    ; [rsp+24] = offsetx
    ; [rsp+32] = offsety
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    xor r12, r12
    xor r14, r14

    mov r12d, [rbp+16] ; tamx
    mov r13d, [rbp+24] ; tamy
    mov r14d, [rbp+32] ; offsetx
    mov r15d, [rbp+40] ; offsety

    shl r12, 2 ; Convertimos el tamx de pixeles en tamx de bytes.

    ; rax = indice fila
    ; rbx = indice columna

    ; Nos movemos a la posicion de la imagen fuente.
    xor rax, rax
    mov eax, ecx
    sub eax, r15d
    mul r8d
    add rdi, rax
    lea rdi, [rdi + r14 * BYTESXPIXEL]

    xor rax, rax 
    xor rbx, rbx 
.loop:
    movdqu xmm0, [rdi + rbx]
    movdqu [rsi + rbx], xmm0

    add rbx, BYTESXPIXEL * PIXELXIT
    cmp rbx, r12
    jl .loop
    xor rbx, rbx 
    sub rdi, r8
    add rsi, r9
    inc rax
    cmp eax, r13d
    jl .loop

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
