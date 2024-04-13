mov ax, 3   ; clear screen
int 0x10    ; clear screen
mov ax, 0xb800              
mov ds, ax
mov byte [ds:0], 'H'
halt:                   
    jmp halt            

times 510 - ($ - $$) db 0   
db 0x55, 0xaa 