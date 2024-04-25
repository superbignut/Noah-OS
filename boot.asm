    [org 0x7c00] ;

    mov ax, 3   ; clear screen
  
    int 0x10    ; clear screen

    mov ax, 0
    mov ds, ax

pic_m_cmd equ 0x20
pic_m_data_and_mask equ 0x21


mov word [8 * 4], clock
mov word [8 * 4 + 2], 0

    mov al, 0b1111_1110
    out pic_m_data_and_mask, al

    sti;

loopa:  
    mov bx, 30
    mov al, 'A'
    call blink
    jmp loopa

clock:

    push  bx
    push ax
    ;xchg bx, bx
    mov bx, 4
    mov al, 'C'
    call blink

    ;mov al, 0x20
    ;out pic_m_cmd, al
    pop ax
    pop bx
    xchg bx, bx
    iret
blink:
        push es
        push dx

        mov dx, 0xb800
        mov es, dx

        shl bx, 1
        mov dl, [es:bx]
        cmp dl, ' '             
        jnz .set_space          ; != 0 jmp------>
            mov [es:bx], al     ; == 0 写入字母  |
            jmp .done           ;               |
                                ;               |
    .set_space:                 ;               |
        mov byte [es:bx], ' '   ; ！= 0 清空<----|
    .done:

        pop dx
        pop es
        ret


halt:                   
    jmp halt

    times 510 - ($ - $$) db 0   

    db 0x55, 0xaa 