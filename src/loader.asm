    [org 0x1000]

loader_begin:
    mov si, print_real_loader
    call real_printf    ; loader加载成功

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

    ; 下面的代码用于显示那些内存布局可用，进入保护模式则跳过
    mov word cx, [ards_num]
    mov si, 0
    mov ax, 0
    mov es, ax

.show:
    mov eax, [ards_buffer + si]
    mov ebx, [ards_buffer + si + 8]
    mov edx, [ards_buffer + si + 16]
    add si, 20
    xchg bx, bx
    loop .show
    ; 0x0_0000 - 0x9_f000 type=1
    ; 0x10_0000 - 0x1ff_0000 type=1 不到32MB的内存
    ; 所以bochs虚拟机里总共有两块内存可以使用
.error:
    mov ax, 0xb800
    mov ax, es
    mov byte [es:0], 'E'  
    jmp $



print_real_loader:
    db "Loader init successfully...", 10, 13, 0
print_real_memory_check:
    db "Memory check successfully...", 10, 13, 0
print_proc_protect_mode:
    db "Protected mode already...", 0
prepare_protect_mode:
    
    mov si, print_real_memory_check
    call real_printf    ; 内存检测成功

    cli             ; 关闭中断

    in al, 0x92     ; 打开A20
    or al, 0b10
    out 0x92, al    ; 写回

    lgdt [gdt_ptr]  ; 指定 gdt表 的起始地址

    mov eax, cr0
    or eax, 1
    mov cr0, eax    ; 进入保护模式
    ; gdt_ptr 起始地址 +  code_selector 即可选中对应的 segment_descriptor
    ; 进而进入到保护模式
    jmp dword code_selector : protect_enable    
    ud2             ; 如果出错，执行ud2





real_printf:
    ; si用于存放字符串首地址，
    mov cx, 0
    mov ds, cx
    mov ah, 0x0e
    
.next:
    mov byte al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;下面为32为代码;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


[SECTION .s32]
[bits 32]
; 正式进入保护模式

proc_printf:
    ; 保护模式下的打印字符串
    ; eax 保存显示起始地址
    ; edi 存字符串起始地址
    push cx
.inner_print:
    mov byte cl, [edi]
    mov byte [eax], cl; 把edi寄存器指向的内存的内容，放到eax执行的内存中
    add edi, 1
    add eax, 2
    cmp byte [edi], 0x0
    jnz .inner_print
    pop cx
    ret

protect_enable:

    mov ax, data_selector       ; 切换到数据段
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov esp, 0x10000

    ; 这里的 CR4.PAE = 0 所以是 32-bits 模式
    call setup_page ; 现在开始可以使用 0xC000_0000 到 0xc010_0000的逻辑地址 

    mov eax, 0xb8000
    mov edi, print_proc_protect_mode

    ;call real_printf
    xchg bx, bx

    jmp $           ; 这个jump $ 我不确定是不是能jump到合适的位置

; 页目录放在的位置，最后12位全部是0
PDE equ 0x2000

; 页表的位置
PTE equ 0x3000
ATTR equ 0b11 ; 只有P和R/W置1,其余是0, 暂时只写最低的两位


setup_page:
    ; 设置页表配置
    mov eax, PDE
    call .clear_page    ; 清空页目录
    mov eax, PTE
    call .clear_page    ; 清空页表
    
    ; 将物理地址的 0-1M 映射为逻辑地址的 0-1M
    ; 将物理地址的 0-1M 映射为逻辑地址的 0xC000_0000 ~ 0xC010_0000
    mov eax, PTE        ; 把PTE的地址放入eax
    or eax, ATTR

    
    mov [PDE], eax 
    ; 第0个页目录， 每个页目录占4个字节
    ; 0x0000_0000 = 0b_0000_0000_0000_0000_0000_0000_0000_0000
    ; 前10位是0x000,所以映射到了页目录的第0个页表项

    
    mov [PDE + 0x300 * 4], eax
    ; 第0x300个页目录， 每个页目录占4个字节
    ; 0xc000_0000 = 0b_1100_0000_0000_0000_0000_0000_0000_0000 
    ; 前10位是0x300, 所以也就映射到了页目录中的第0x300个页表项

    ;现在，页目录中的这两个页表项都指向的PTE的这个页表

    mov eax, PDE
    or eax, ATTR
    ; 0x400 = 1024 = 2^10 也就是最后一个页
    mov [PDE + 0x3ff * 4], eax ; 把最后一个页表指向页目录,指向自己  
    ; 其实0x3ff也就是 逻辑地址的前10位全是1：0b11_1111_1111

    mov ebx, PTE
    mov ecx, (0x100000 / 0x1000)    ; 2^20=1MB的地址总共有 2^8 = 256个页，每页2^12=4KB     
    mov esi, 0                      ; 1后面有5个0 除以 1后面3个0, 别写错了

.next_page:     ; 把256个页都写到PTE里面
    mov eax, esi    
    shl eax, 12     ; eax 左移12位作为那个页的物理页首地址，低12位是控制位 
    or eax, ATTR    ; 这里就把 0x0000_0000 到0x0010_0000 这1MB的物理地址按顺序写进PTE
    
    mov [PTE + esi * 4], eax    
    inc esi
    loop .next_page

    
    mov eax, PDE    ; 启用内存映射
    mov cr3, eax    ; 将页目录加载进cr3寄存器
    mov eax, cr0    ; 打开分页机制
    or eax, 0b1000_0000_0000_0000_0000_0000_0000_0000 ; CR0_PG = 1
    mov cr0, eax
    ret


.clear_page:
    push ecx
    ; 清空一个内存页地址 地址参数存在eax中
    mov ecx, 0x1000     ; 2^12 = 4KB
    mov esi, 0
.set:
    mov byte [eax + esi], 0
    inc esi
    loop .set
    pop ecx
    ret




base equ 0                  ; 这里的base一直是0， 所以是怎么找到0：protect_enable的阿
limit equ 0xfffff           ;20bit

; 数据段的 segment_selector
code_selector equ (0x0001 << 3)  ; index = 1 选择gdt中的第一个 GFT = 0 Level=00
; 代阿段的 segment_selector
data_selector equ (0x0002 << 3)  ; index = 2 选择gdt中的第二个

;gdt 描述地址 用来表示GDT表的起始地址和长度， 使用lgdt 加载到gdtr寄存器中，
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
    db 0b1100_0000 | ( (limit >> 16) & 0xf )
    db (base >> 24) & 0xff    

gdt_end:

; ards 数量
ards_num:
    dw 0
; ards 位置， 放到最后防止不同虚拟机配置不同
ards_buffer:
