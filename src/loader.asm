    [org 0x1000]

    

check_memory:

    mov ax, 0
    mov es, ax              ;es = 0

    xor ebx, ebx            ;ebx = 0

    mov edx, 0x534d4150     ;edx = 'SMAP'

    mov di, ards_buffer     ;di指向一个地址
.next:                      ;循环标记
    mov eax, 0xe820         ;eax e820
    mov ecx, 20             ;只能写20
    int 0x15                ;中断调用

    jc .error               ;判断carry是否报错,cf是eflag的最低位

    add di, cx              ;地址移动20个
    inc word [ards_num]     ;统计数+1
    cmp ebx, 0              ;判断是不是0,是0结束,不用改
    jnz .next               ;循环
 
    mov cx, [ards_num]      ;看循环了几次
    mov si, 0               ;指针
.show:
    mov eax, [si + ards_buffer]         ;只读了低32位,也就是4个字节
    mov ebx, [si + ards_buffer + 8]     ;length
    mov edx, [si + ards_buffer + 16]    ;type
    add si, 20                          ;每次移动20个字节,读取数据
    loop .show                          ;循环读取


.error:
    jmp $



ards_num:
    dw 0
ards_buffer:
