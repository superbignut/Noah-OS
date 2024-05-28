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

    jmp prepare_protect_mode ; 跳到保护模式准备阶段

.error:
    mov ax, 0xb800
    mov ax, es
    mov byte [es:0], 'E'  
    jmp $



prepare_protect_mode:

    cli             ; 关闭中断

    in al, 0x92     ; 打开A20
    or al, 0b10
    out 0x92, al    ; 写回

    lgdt [gdt_ptr]  ; 指定 gdt表 的起始地址

    mov eax, cr0
    or eax, 1
    mov cr0, eax    ; 进入保护模式

    ;jmp dword code_selector : protect_enable  ; 这里会跳到哪里去？  
    xchg bx, bx
    jmp dword code_selector : protect_enable
    ud2             ; 出错

[SECTION .s32]
[bits 32]
protect_enable:

    mov ax, data_selector           
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov esp, 0x10000

    mov byte [0xb8000], 'P'     ;这时候虽然bochs写着 ds:[0xb8000] 但其实应该没有用 ds

    mov byte [0x200000], 'P'    ; 不显示

    xchg bx, bx

    jmp $

base equ 0                  ; 这里的base一直是0， 所以是怎么找到0：protect_enable的阿
limit equ 0xfffff           ;20bit

code_selector equ (0x0001 << 3)  ; index = 1 选择gdt中的第一个 GFT = 0 Level=00
data_selector equ (0x0002 << 3)  ; index = 2 选择gdt中的第二个

;gdt 描述地址
gdt_ptr:                       ; 6B at all
    dw (gdt_end - gdt_base -1) ; 2B limit limit = len - 1
    dd gdt_base                ; 4B base GDT基地址

gdt_base:
    dd 0, 0                     ; 8B 第一个Segment Descriptor是空的
gdt_code:
    dw limit & 0xffff           ;limit[0:15]
    dw base & 0xffff            ;base[0:15]
    db (base >> 16) & 0xff      ;base[16:23]
    ;type
    db 0b1110 | 0b1001_0000     ;D_7/DPL_5_6/S_4/Type_0_3
    db 0b1100_0000 | ( (limit >> 16) & 0xf )   ;G_7/DB_6/L_5/AVL_4/limit[16:19]_3_0
    db (base >> 24) & 0xff      ;base[24:31]

gdt_data:
    dw limit & 0xffff
    dw base & 0xffff
    db (base >> 16) & 0xff
    ;type
    db 0b0010 | 0b1001_0000
    db 0b1100_0000 | (limit >> 16)
    db (base >> 24) & 0xff    

gdt_end:

ards_num:
    dw 0
ards_buffer:
