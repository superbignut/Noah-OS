    [org 0x7c00] ;

    mov ax, 3   ; clear screen

    int 0x10    ; clear screen

    mov ax, 0xb800              
    mov es, ax  ; es = 0xb800

    mov ax, 0
    mov ds, ax  ; ds = 0

    mov si, message ; si = first_address 编译时就定下来了，所以用org可以在编译时加上0x7c00

    mov di, 0   ; di = 0

    mov cx, message_end - message


loop1:

    mov al, [ds:si] ; 把内容h放到al

    mov [es:di], al ; 把al放到0xb8000

    inc si
    add di, 2

    loop loop1

    xchg bx, bx
halt:                   
    jmp halt            

message:
    db "hello, world", 0x00
message_end: 

    times 510 - ($ - $$) db 0   

    db 0x55, 0xaa 