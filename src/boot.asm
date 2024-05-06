    [org 0x7c00] ;

    mov ax, 3   ; clear screen
    int 0x10    ; clear screen

    mov ax, 0
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00

    ;xchg bx, bx

    mov edi, 0x1000 ; 将硬盘的第2个扇区(lba=2)开始的4个扇区，移到0x1000位置
    mov ecx, 2
    mov bl, 4

    call read_disk

    xchg bx, bx

    jmp 0:0x1000
halt:                   
    jmp halt


read_disk:
    pushad          ;eax, ecx, ebx, edx, esp, ebp, esi, edi 这里如果是16位的栈的话，32位寄存器会压两次
    push es        
    ;读取硬盘
    ; es:edi - 把读取到的数据，在内存中存放的位置 edi
    ; ecx - 读取的原始数据在硬盘中的扇区位置-lba
    ; bl 扇区数量
    mov dx, 0x1f2 
    mov al, bl      ; 读写扇区的数量
    out dx, al

    mov al, cl      ; 读取第0个扇区 low
    mov dx, 0x1f3
    out dx, al

    shr ecx, 8
    mov al, cl
    mov dx, 0x1f4   ; mid
    out dx, al

    shr ecx, 8
    mov al, 0
    mov dx, 0x1f5   ; high
    out dx, al

    shr ecx, 8
    and cl, 0b0000_1111
    mov al, 0b1110_0000
    or al, cl
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

    mov ax, 0
    mov es, ax

    xor eax, eax
    mov al, bl
    mov dx, 256
    mul dx      ;al = al * 256 字， 因为一次读取两个字节

    mov dx, 0x1f0
    mov cx, ax  ;loop

    .read_loop:          ;读取数据
        nop
        nop
        nop
        in ax, dx
        mov [es:edi], ax
        add di, 2

        loop .read_loop

    pop es
    popad

    ret

times 510 - ($ - $$) db 0   

db 0x55, 0xaa 