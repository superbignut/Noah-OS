    [org 0x7c00]    ; 主引导扇区放在 0x7c00的位置上
    
    mov ax, 0x03    
    int 0x10        ; 设置为文本模式，清空屏幕

    mov ax, 0
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov sp, 0x7c00  ; 初始化段寄存器和栈指针

    mov ax, 0xb800  ; 显示字母
    mov ds, ax
    mov byte [ds:0x0], 'P'
    
    
    xchg bx, bx
    jmp $




read_disk:          ; 读取内核加载器


    times 510 - ($ - $$) db 0   

    db 0x55, 0xaa