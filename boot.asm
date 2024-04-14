mov ax, 3   ; clear screen
int 0x10    ; clear screen
xchg bx, bx     ; break auto

mov ax, 0xb800              

xchg bx, bx     ; break auto
mov bl, 0x01
mov bh, 0x02    ; so bx is 0x0201
xchg bx, bx     ; break auto
mov ds, ax
mov byte [ds:0], 'H'
halt:                   
    jmp halt            

times 510 - ($ - $$) db 0   
db 0x55, 0xaa 