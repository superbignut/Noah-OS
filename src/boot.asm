    [org 0x7c00] ;

    mov ax, 3   ; clear screen
    int 0x10    ; clear screen

    mov ax, 0
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00

    ;xchg bx, bx

;将 0 -> 0x1000

    mov dx, 0x1f2 ; 读写扇区的数量
    mov al, 1
    out dx, al

    mov al, 0       ; 读取第0个扇区 low = 0
    mov dx, 0x1f3
    out dx, al

    mov al, 0       
    mov dx, 0x1f4   ; mid = 0
    out dx, al

    mov al, 0
    mov dx, 0x1f5   ; high = 0
    out dx, al

    mov al, 0b1110_0000
    mov dx, 0x1f6       ;master + lba
    out dx, al

    mov al, 0x20    ; read sectors command 0x20
    mov dx, 0x1f7
    out dx, al

    .check_read_state:  ; 选择扇区后要延迟一下，并不是每次读取时都要检查
        nop
        nop
        nop
        in al, dx ; 0x1f7
        and al, 0b1000_1000
        cmp al, 0b0000_1000
        jnz .check_read_state

    mov ax, 0x100   ; 把数据读到0x1000
    mov es, ax
    mov di, 0
    mov dx, 0x1f0

    read_loop:          ;读取数据
        nop
        nop
        nop
        in ax, dx
        mov [es:di], ax
        add di, 2
        cmp di, 512
        jnz read_loop
    xchg bx, bx


    mov dx, 0x1f2 ;
    mov al, 1
    out dx, al

    mov al, 2   ; 第 2 + 1个扇区 LBA 把数据写到硬盘第三个扇区 去master.img 0x400处查看，
    mov dx, 0x1f3   ; 不是在内存里，而是硬盘
    out dx, al

    mov al, 0
    mov dx, 0x1f4
    out dx, al

    mov al, 0
    mov dx, 0x1f5
    out dx, al

    mov al, 0b1110_0000
    mov dx, 0x1f6
    out dx, al

    mov al, 0x30    ; write sectors command
    mov dx, 0x1f7
    out dx, al

    mov ax, 0x100
    mov es, ax
    mov di, 0
    mov dx, 0x1f0

    write_loop:
        nop
        nop
        nop

        mov ax, [es:di]
        out dx, ax  ; 把es:di的数据写到dx端口

        add di, 2
        cmp di, 512
        jnz write_loop  ;写512个字节

    mov dx, 0x1f7
    .check_write_state:
        nop
        nop
        nop
        in al, dx ; 0x1f7
        and al, 0b1000_0000
        cmp al, 0b1000_0000
        jz .check_write_state    ;不繁忙跳转， 也就是写完了的意思
    xchg bx, bx

halt:                   
    jmp halt

    times 510 - ($ - $$) db 0   

    db 0x55, 0xaa 