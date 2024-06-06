[bits 32]
section .text
    global main
    main:

    mov eax, 4  ;write

    mov ebx, 1  ; stdout

    mov ecx, message    ;buffer

    mov edx, message_end - message

    int 0x80

    mov ax, 0
    mov es, ax

    mov eax, 1  ;exit

    mov ebx, 0  ;code

    int 0x80

section .data
    message: db "hello world", 10, 13, 0
message_end:

section .bss
    resb 0x100 ; 预留 0X100 字节的空间