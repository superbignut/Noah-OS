    [bits 32]


    extern kernel_init         ; windows 的函数需要加 "_"
    extern ards_init         ; 内存初始化
    extern console_init
    extern gdt_init


    global _start
_start:
    
    push ecx            ; ards buffer 的首地址, 第三个参数
    push ebx            ; 可用的 ards 的数量， 第二个参数
    push eax            ; 保存魔数，第一个参数，三个参数都在 jmp 之前被保存

    call console_init

    call gdt_init

    call ards_init
    
    call kernel_init   

    jmp $
test_push_and_ret:   

    push $              ; 这种方式也可以实现 jmp $ 的效果
    ret