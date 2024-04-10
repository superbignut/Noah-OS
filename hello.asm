mov ax, 0xb800              ; toshow
mov ds, ax
mov es, ax

mov byte [es:0x00], 'L'    ; ds + offset default
mov byte [es:0x01], 0x07   ; byte means not a word but a byte
mov byte [es:0x02], "T"
mov byte [es:0x03], 0x07
mov byte [es:0x04], 'L'
mov byte [es:0x05], 0x07

mov ax,number           ; number -> ax
mov bx,10d              ; 10 -> bx

mov cx, cs  ;           ; cx = cs = 0x7c00
mov ds, cx  ;           ; ds = cx = 0x7c00

mov dx, 0d  ;           ; DX : AX / 16 = AX ... DX    AX / 8 = AL ... AH
div bx      ;           ;
mov [0x7c00+number+0x00],dl     ; number is a logical offset address

xor dx, dx              ; dx = 0
div bx
mov [0x7c00+number+0x01],dl     

xor dx, dx              ; dx = 0
div bx
mov [0x7c00+number+0x02],dl     

xor dx, dx              ; dx = 0
div bx
mov [0x7c00+number+0x03],dl     

xor dx, dx              ; dx = 0
div bx
mov [0x7c00+number+0x04],dl     



mov al, [0x7c00+number+0x04]
add al, 0x30
mov [es:0x06], al
mov byte [es:0x07], 0x04    

mov al, [0x7c00+number+0x03]
add al, 0x30
mov [es:0x08], al
mov byte [es:0x09], 0x04    

mov al, [0x7c00+number+0x02]
add al, 0x30
mov [es:0x0A], al
mov byte [es:0x0B], 0x04    

mov al, [0x7c00+number+0x01]
add al, 0x30
mov [es:0x0C], al
mov byte [es:0x0D], 0x04   

mov al, [0x7c00+number+0x00]
add al, 0x30
mov [es:0x0E], al
mov byte [es:0x0F], 0x04   


mov byte [es:0x10], 'D'
mov byte [es:0x11], 0x07

number: db 0,0,0,0,0

halt:                   ; halt is a instr address
    jmp halt            ; loop

times 510 - ($ - $$) db 0   ; times is also a pseudo-instr
db 0x55, 0xaa 