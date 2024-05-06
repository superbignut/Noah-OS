[bits 32]
extern printf
extern exit    
section .text
    global main
    main:

    ;push message 
    ;call printf
    ;add exp, 4
    ;push 0
    ;call exit 

    mov eax, 4  ;write

    mov ebx, 1  ; stdout

    mov ecx, message    ;buffer

    mov edx, message_end - message

    int 0x80

    mov ax, 0
    mov es, ax

    xchg bx, bx
    lea ebx, tmessage   

    mov byte [es:ebx], 1


    mov eax, 1  ;exit

    mov ebx, 0  ;code

    
    int 0x80

section .rodata
tmessage: db 7
section .data
message: db "hello world", 10, 13, 0
message_end: