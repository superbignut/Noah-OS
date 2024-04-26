    [org 0x1000]

    xchg bx, bx

    mov ax, 0xb800
    mov es, ax
    mov byte [es:0], "L"

    jmp $

    times 2046 - ($ - $$) db 0   

    db 0x55, 0xaa 