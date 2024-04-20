    [org 0x7c00] ;

    mov ax, 3   ; clear screen
  
    int 0x10    ; clear screen

    ;call [ds:test] 

    xchg bx, bx
    ;mov word [0x80 * 4], print
    ;mov word [0x80 * 4 + 2], 0

    
    call far [ds:test]

    int 0x80
    
    mov word [0x00 * 4], err ; register
    mov word [0x00 * 4 + 2], 0 

    mov ax, 1
    mov dx, 0
    mov bx, 0
    div bx

halt:                   
    jmp halt            

err:
    push ax
    push ds
    push bx

    mov ax, 0xb800
    mov ds, ax
    mov bx, 0

    mov byte [ds:bx], 'L'

    pop bx
    pop ds
    pop ax

    hlt
    iret

print:
    
    push cx
    push ax 
    push es
    push ds
    push si
    push di


    mov cx, message_end - message ; loop_i

    mov ax, 0xb800              
    mov es, ax  ; es = 0xb800

    mov ax, 0
    mov ds, ax  ; ds = 0

    mov si, message ;

    mov di, 0   ; di = 0
    mov al, [ds:si] ; 把内容h放到al

    mov [es:di], al ; 把al放到0xb8000

    add si, 1
    add di, 2

    pop di
    pop si
    pop ds
    pop es
    pop ax
    pop cx

    ; ret retf iret
    iret
message:
    db "hello, world", 0x00
test:
    dw print, 0
message_end: 

    times 510 - ($ - $$) db 0   

    db 0x55, 0xaa 