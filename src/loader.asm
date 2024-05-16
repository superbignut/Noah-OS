    [org 0x1000]

    

check_memory:

    mov ax, 0
    mov es, ax

    xor ebx, ebx

    mov edx, 0x534d4150

    mov di, ards_buffer 
.next:
    mov eax, 0xe820
    mov ecx, 20
    int 0x15

    jc .error

    add di, cx
    inc word [ards_num]
    cmp ebx, 0
    jnz .next
 
    mov cx, [ards_num]
    mov si, 0
.show:
    mov eax, [si + ards_buffer]
    mov ebx, [si + ards_buffer + 8]
    mov edx, [si + ards_buffer + 16]
    add si, 20
    loop .show

    xchg bx, bx
    mov eax, 0x1f000
    mov es, eax
    mov ebx, 0x1ffff
    mov al, [es:ebx]
    xchg bx, bx

.error:
    jmp $



ards_num:
    dw 0
ards_buffer:
