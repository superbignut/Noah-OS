    [org 0x7c00] ;

    mov ax, 3   ; clear screen
  
    int 0x10    ; clear screen

    mov ax, 0xb800
    mov es, ax

    mov ax, 0x0
    mov ds, ax

    mov si, message

    mov bx, 0x01


print:

    call get_cursor ;获取初始位置的光标

    mov di, ax  ; ax: 0 1 2 3 4 5 光标显示的位置 * 2 + 0xb8000就是字符显示的位置

    shl di, 1   ; 指向下一个非样式的显示位置 di = ax * 2: 0 2 4 6 8 10

    mov bl, [ds:si]    ;获得字母h-e-l-l-o-,- -w-o-r-l-d

    cmp bl, 0       ;与空字符进行比较
    jz print_end

    mov [es:di], bl ;将字符放进 0xb8000 + di
    mov byte [es:di+1], 0x4 ;红色
    inc si
    inc ax

    call set_cursor ;设置新的光标
    jmp print
print_end:

halt:                   
    jmp halt

CRT_ADDR_REG equ 0x3d4
CRT_DATA_REG equ 0x3d5
CRT_CURSOR_HIGH equ 0x0e    
CRT_CURSOR_LOW equ 0x0f
set_cursor:
    ; ax传递参数
    push dx
    push bx
    mov bx, ax              ; bx = ax

    ;先设置地址寄存器，把光标索引地址传入
    mov dx, CRT_ADDR_REG    ;port
    mov al, CRT_CURSOR_LOW
    out dx, al              ;out 

    ;再设置数据寄存器，把数据传入
    mov dx, CRT_DATA_REG    
    mov al, bl
    out dx, al              ;set bl

    mov dx, CRT_ADDR_REG
    mov al, CRT_CURSOR_HIGH
    out dx, al

    mov dx, CRT_DATA_REG
    mov al, bh
    out dx, al              ;set bh

    pop bx
    pop dx
    ret

get_cursor:
    ; 结果存在ax
    push dx
    mov dx, CRT_ADDR_REG
    mov al, CRT_CURSOR_HIGH
    out dx, al

    mov dx, CRT_DATA_REG
    in al, dx               ; in data_port to al
    shl ax, 8

    mov dx, CRT_ADDR_REG
    mov al, CRT_CURSOR_LOW
    out dx, al

    mov dx, CRT_DATA_REG
    in al, dx
    pop dx
    ret
message:
    db "hello, world", 0x00
message_end: 

    times 510 - ($ - $$) db 0   

    db 0x55, 0xaa 