#### 看了github上的各个OS教程之后，会发现从零开始实现一个OS，真的是一个门槛非常高的领域：各种虚拟机软件，计算机名词，汇编等等。
#### 因此这个md文件就当作在学习各个教程时遇到的问题和解决办法的汇总，稳扎稳打，慢慢来。

1. [bochs](https://bochs.sourceforge.io/)

    bochs 是一个 x86 PC 模拟器，官网上说 bochs 可以模拟从 386 到 intel 和 amd 的 x86_64的多种 CPU ,因此和 VMware, Virtual Box, qemu 应该是同样的功能，但似乎 bochs调试上更优一些？

    对于bochs的安装，除了官网，OSDEV上也有详细的说明和[介绍](https://wiki.osdev.org/Bochs)。

    + bochs magic break
        
        > xchg bx, bx
    + 查看当前的10条反汇编指令
        > u/10 

    + 查看寄存器
        > sreg 或 r 

    + 查看ss:sp 堆栈
        > print-stack 

    + 产看10 * 4 bytes 的内存地址内容
        > xp/10


2. [bximage](https://bochs.sourceforge.io/doc/docbook/user/using-bximage.html)
    官网给出 bximage 是一个和 bochs 配套使用的磁盘镜像的创建、转换、解析工具。
    > Bximage is an easy to use console based tool for creating, converting and resizing disk images, particularly for use with Bochs. It also supports committing redolog files to their base images. It is completely interactive if no command line arguments are used. It can be switched to a non-interactive mode if all required parameters are given in the command line.

    在创建镜像文件的时候，会询问创建镜像的类型，flat, sparse, growing, vpc or vmware4:

    [官网指出](https://bochs.sourceforge.io/doc/docbook/user/harddisk-modes.html)：
    > In flat mode, all sectors of the harddisk are stored in one flat file, in lba order.

    在这里我们选用了flat类型，含义是可以将整个磁盘的不同存储区域当作一个逻辑上连续的空间进行访问。其余的类型则对应着不同的虚拟机。并且相对于growing，flat的特点是大小一次全部分配，而不是随着使用而增长。

3. [qemu](https://wiki.qemu.org/Main_Page)

    从功能上来看，qemu 和 bochs 类以，也是一个模拟器，下面[引用](https://people.redhat.com/pbonzini/qemu-test-doc/_build/html/topics/QEMU-compared-to-other-emulators.html)一段两者的区别，似乎在说，bochs 主打 x86 而 qemu 主打各种 CPU
    > Like bochs, QEMU emulates an x86 CPU. But QEMU is much faster than bochs as it uses dynamic compilation. Bochs is closely tied to x86 PC emulation while QEMU can emulate several processors.

4. [nasm assembler](https://www.nasm.us/)

    一个面向x86 CPU的汇编和反汇编工具，说白了就也是一个编译器，和gcc一样。
    
    + 问题4.1：使用下面的命令编译时，生成的指令的格式是什么？
  
        > nasm hello.asm -o nasm        

    首先 man手册提到，-f 参数的默认情况是 -f bin ; 
    
    其次根据[nasm手册7.1节](https://www.nasm.us/xdoc/2.16.02/html/nasmdoc0.html) 中提到的：

    >The most likely reason for using the BITS directive is to write 32-bit or 64-bit code in a flat binary file; this is because the bin output format defaults to 16-bit mode in anticipation of it being used most frequently to write DOS .COM programs, DOS .SYS device drivers and boot loader software.

    所以，bin的默认输出是16位指令，并且7.1节还对 BITS 的其他用法进行了说明，在os01的教程中也有提到。

5. [lba](https://en.wikipedia.org/wiki/Logical_block_addressing)
    
    Logical block addressing: 使用单一编号进行对不同磁盘分区进行索引，取代了传统的使用 cylinder-head-sector 方法。

6. [virtual-box](https://www.virtualbox.org/)

    同样也是一个虚拟机，相比与VMware的优点在于这个是开源的。由于我的电脑是ubuntu22.04,使用下面的命令可以成功安装：
    > sudo apt install virtualbox 
    
    > sudo apt install virtualbox-ext-pack

    最开始是从官网下载的deb包，但是发现后面在打开虚拟硬盘和安装拓展的时候总是报错。但回到 apt 进行安装就没什么问题。

7. [intel-8086](https://en.wikipedia.org/wiki/Intel_8086#cite_note-3)
    > The 8086 gave rise to the x86 architecture, which eventually became Intel's most successful line of processors.
    
    《x86汇编语言从实模式到保护模式》一书中大量引用了 8086 cpu 的各种特性，包括内存模型，初始加载地址，显存位置等等，似乎都是规定好的内容，但书中并没有给出出处，因此可能要自己探究一下。

    google 到的 [8086芯片手册](https://www.inf.pucrs.br/~calazans/undergrad/orgcomp_EC/mat_microproc/intel-8086_datasheet.pdf)给出了一些解释，但还有大篇幅的时序、引脚、模式的介绍暂时还不理解：

    > Direct Addressing Capability 1 MByte of Memory

    8086 有 1MB 也就是 2^20B 的存储空间

    > The processor provides a 20-bit address to memory which locates the byte being referenced. The memory is organized as a linear array of up to 1 millionbytes, addressed as 00000(H) to FFFFF(H). The memory is logically divided into code, data, extra data, and stack segments of up to 64K bytes each, with each segment falling on 16-byte boundaries.

    这里的 64K 和 16-byte boundary 指的就是一个 64K 的内存段需要开始在某个可以被16位整除的位置。

    > Locations from address FFFF0H through FFFFFH are reserved for operations including a jump to the initial program loading routine. Following RESET, the CPU will always begin execution at location FFFF0H where the jump must be. 

    这里解释了，复位后 8086会去执行 FFFF0H 处的指令，而这个指令是一个跳转指令。

    > After this interval the 8086 operates normally beginning with the instruction in absolute location FFFF0H. The details of this operation are specified in the Instruction Set description of the MCS-86 Family User’s Manual. 

    这里指出，有关启动的设计需要看[MCS-86 Family User’s Manual](https://edge.edx.org/c4x/BITSPilani/EEE231/asset/8086_family_Users_Manual_1_.pdf), 这里也去看一下：

    > Chapter1 describes the architecture of the 8086 family, Chapter2 describes the 8086 and 8088 CPU, Chapter3 covers Input/Output Processor.

    具体的有关CPU的内容是在第二章

    > In addition, during periods when the EU(Exection unit) is busy executing instructions, the BIU(Bus Interface Unit) looks ahead and featches more instructions from memory.

    这部分在说8086没有使用传统的流水线的执行指令的方式，而是增加了一个BIU单元， 类似一个队列的数据结构

    > The CS register points to the current code segment; The SS register points to the current stack segment; The DS register points to the current data segment; The ES register points to the current extra segemnts; The 16-bit IP(instruction pointer) is updated by the BIU so that it constans the offset of the next instruction from the beginning of the current code segment;

    介绍了一些寄存器，当然后面还介绍了FLAG和寄存器和FLAG的关系。

    > It is useful to think of every memory location as having two kinds of addresses, pyhsical and logical.Pyhsical addresses may range from 0H through FFFFFH.
    Programs deal with logical, rather than pyhsical addresses and allow code to be developed without prior knowledge of where the code is to be located in memory and facilitate dynamic management of memory resources.

    介绍了逻辑地址和物理地址。

    > Two areas in extreme low and high memory are dedicated to specific processor functions or are reserved by Intel. The locations are OH-7FH(128 bytes) and FFFF0H-FFFFFH(16 bytes) Theres areas are used for interrupt and system reset processing.

    大致的提到了8086的两块保留内存。

    > THe 8086 can access either 8 or 16 bits of memory at a time. If an instruction refers to a word variable and variable is located at an even-numbered address, 8086 accesses the complete word in one bus cycle, odd-numbered address -> one byte.

    说到了有关存储大小的内容，后面还有对齐和I/O映射的内容暂时略过。

    这个手册里可以找到好多教科书上的内容和设计，但没有看到显卡的地址说明，可能还要继续仔细的读一下....

    查了google, 0xB8000 似乎就是一个在某种模式下的显示器会读取的 80 * 25 * 2 = 4000 bytes 首地址,有待进一步学习。
    +   这里在OSDEV的[Memory map](https://wiki.osdev.org/Memory_Map_(x86))中有提到;
    + 在[BDA - BIOS Data Area - PC Memory Map](https://stanislavs.org/helppc/bios_data_area.html),也有给出详细的从0x0000到0xFFFF:E的所有地址的用途。
    + 在踌躇月光的[x86视频02](https://www.bilibili.com/video/BV1b44y1k7mT?p=2&vd_source=5ad68ece2cc478b800d0c26152ca85c7)中也给出了更详细的地址布局，但不太清除出处。
    + 在踌躇月光的[x86视频03](https://www.bilibili.com/video/BV1b44y1k7mT?p=3&spm_id_from=pageDriver&vd_source=5ad68ece2cc478b800d0c26152ca85c7)中介绍到了0x7c00=31kB地址的历史，具体好像还要追溯到IBM-PC-5150, 待扩充

8. 先使用 bximage 制作了一块虚拟硬盘.img，然后使用 dd 命令将512字节的.bin 文件写入 .img , 为什么 bochs 就能够直接加载这个硬盘中的指令呢？同样的问题，为什么使用 qemu convert 转换为 vdi格式后，virtual_box也能直接打开呢？不需要一些对硬盘格式的说明吗？
    
        dd if=hello.bin of=master.img bs=512 count=1 conv=notrunc
        
        qemu-img convert -f raw -O vdi master.img master.vdi

    这里似乎最开始都默认是16位启动，似乎还和实模式和保护模式有关，以后再看....而且好像是除了qemu之外的这几个虚拟机都是只能模拟x86的，所以也就是默认按照x86的模式进行启动和加载，但是qemu可以模拟其他的架构。

9. [nasm 编译器语法](https://www.nasm.us/xdoc/2.16.02/html/nasmdoc0.html)

    在写最简单的第一个在屏幕上显示字母的汇编程序时，用到了很多奇怪的语法: times, db, $ ,$$之类，在查找NASM官网时看到[Chapter 3: The NASM Language](https://nasm.us/doc/nasmdoc3.html)对这些语法进行了解释，比如：

    > NASM supports two special tokens in expressions, allowing calculations to involve the current assembly position: the $ and $$ tokens. $ evaluates to the assembly position at the beginning of the line containing the expression; so you can code an infinite loop using JMP $. $$ evaluates to the beginning of the current section; so you can tell how far into the section you are by using ($ - $$).

    
        label:    instruction operands        ; comment

    > NASM places no restrictions on white space within a line: labels may have white space before them, or instructions may have no space before them, or anything. The colon after a label is also optional. 

    + ORG : [Binary File Program Origin](https://www.nasm.us/xdoc/2.16.02/html/nasmdoc8.html)
    
    > The function of the ORG directive is to specify the origin address which NASM will assume the program begins at when it is loaded into memory.

    + EQU： Defining Constants
    > EQU defines a symbol to a given constant value: when EQU is used, the source line must contain a label. The action of EQU is to define the given label name to the value of its (only) operand. This definition is absolute, and cannot change later.

    也就是说这是一个编译器的假设，假设程序的首地址，因此当在程序中涉及到具体的地址的时候，这个假设的偏移量都会被加上去。
10. div 指令

    同样的，书上在计算时，用到了 div指令，在intel [手册上](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)找到了相关内容,其中写到了当div 的操作数是不同格式时的指令描述：

        DX : AX / 16 = AX ... DX    AX / 8 = AL ... AH

    >  The action of this instruction depends on the operand size (dividend/divisor). Division using 64-bit operand is available only in 64-bit mode.

    并且学到一个表示方法：r/m8, r/m16,r/m32,这种写法指的是, 一个 8 位的通用寄存器（register）或者一个 8 位的内存地址（memory location） 

11. jmp, call, ret 指令

    jmp指令：

    > Transfers program control to a different point in the instruction stream without recording return information.

    intel 手册中指出了4中jump的形式：

    + Near jump : A jump to an instruction within the current code segment (the segment currently pointed to by the CS register) which means: -2^16 <=> 2^16-1
    + Short jump : A near jump where the jump range is limited to –128 to +127 from the current EIP value.
    + Far jump : A jump to an instruction located in a different segment than the current code segment but at the same privilege level
    + Task switch : A jump to an instruction located in a different task.
    
    这里如果不使用 near, short 进行显示标明的话, 猜测编译器会进行判断, 或者当作绝对地址使用

    感觉call指令和jmp指令的区别就是，是否保留当前的环境数据。

    call指令：
    > Saves procedure linking information on the stack and branches to the called procedure specified using the target operand. 

    ret指令：
    > Transfers program control to a return address located on the top of the stack. The address is usually placed on the stack by a CALL instruction, and the return is made to the instruction that follows the CALL instruction.

    loop指令:

    loop指令会默认让 cx寄存器减1，减到0循环终止。

    > Performs a loop operation using the RCX, ECX or CX register as a counter. Each time the LOOP instruction is executed, the count register is decremented, then checked for 0. If the count is 0, the loop is terminated and program execution continues with the instruction following the LOOP instruction. If the count is not zero, a near jump is performed to the destination (target) operand, which is presumably the instruction at the beginning of the loop.

    cmp指令：

    cmp指令虽然也是执行减法，但是不会保存结果到寄存器中。

    > Compares the first source operand with the second source operand and sets the status flags in the EFLAGS register according to the results. The comparison is performed by subtracting the second operand from the first operand and then setting the status flags in the same manner as the SUB instruction. 
    
12. 实模式和保护模式

    参考intel手册, OSDEV

    > Real Mode is a simplistic 16-bit mode that is present on all x86 processors. Real Mode was the first x86 mode design and was used by many early operating systems before the birth of Protected Mode. For compatibility purposes, all x86 processors begin execution in Real Mode.

    所以x86 启动时，为了考虑兼容性，最开始都会是实模式，也就是16位。

13. x86寄存器 [参考MCS-86 Family User’s Manual](https://edge.edx.org/c4x/BITSPilani/EEE231/asset/8086_family_Users_Manual_1_.pdf)

    + 通用寄存器：DATA_GROUP : AX BX CX DX 
    + 通用寄存器：POINTER_AND_INDEX_GROUP : SP BP SI DI
    
        MCS-86 Family User’s Manual还指出，有些指令会隐式的使用特定的寄存器,比如循环的loop会用到cx;

    + 段寄存器 : CS DS SS ES
    + Instruction Pointer : IP
    + One-Bit-FLAGS : TF DF IF OF SF ZF AF PF CF 
    
14. makefile 特殊字符
    
    make的一些特殊的字符在[GNU make 10.5](https://www.gnu.org/software/make/manual/make.html#Automatic-Variables)中有细致的说明：

    + $< 
    > The name of the first prerequisite. If the target got its recipe from an implicit rule, this will be the first prerequisite added by the implicit rule
    + $@
    > The file name of the target of the rule. If the target is an archive member, then ‘$@’ is the name of the archive file.

    + %
    > A target pattern is composed of a ‘%’ between a prefix and a suffix, either or both of which may be empty. The pattern matches a file name only if the file name starts with the prefix and ends with the suffix, without overlap.

15. x86寻值方式-寄存器简介寻址
    
    参考手册2.8节 [ADDRESSING MODE](https://edge.edx.org/c4x/BITSPilani/EEE231/asset/8086_family_Users_Manual_1_.pdf)
    给出了多种寻址方式，并发现涉及寄存器做偏移的只用到了bx,bp,si,di这四个，但是bp寄存器的默认段寄存器是ss和其他默认段寄存器的说明暂时没有看到。

    > A programmer may specify that either BX or BP is to serve as a base register whose content is to be used in the EA computation. Similarly, either SI or DI may be specified as an index register.

16. x86-算术运算指令

    + add
    
    > Adds the destination operand (first operand) and the source operand (second operand) and then stores the result in the destination operand. The destination operand can be a register or a memory location; the source operand can be an immediate, a register, or a memory location. (However, two memory operands cannot be used in one instruction.) When an immediate value is used as an operand, it is sign-extended to the length of the destination operand format.

    + adc

    > Adds the destination operand (first operand), the source operand (second operand), and the carry (CF) flag and stores the result in the destination operand. The destination operand can be a register or a memory location; the source operand can be an immediate, a register, or a memory location. (However, two memory operands cannot be used in one instruction.) The state of the CF flag represents a carry from a previous addition. When an immediate value is used as an operand, it is sign-extended to the length of the destination operand format.
    
    在add和adc中都提到了[sign-extended](https://en.wikipedia.org/wiki/Sign_extension), 指的是和Zero-extended 不同的另一种拓展方式，可以保证拓展后的符号不变，最高位是0就增加0,是1就增加1，但是这里都是以补码作为前提。

    + mul 
    
    > Performs an unsigned multiplication of the first operand (destination operand) and the second operand (source operand) and stores the result in the destination operand. The destination operand is an implied operand located in register AL, AX or EAX (depending on the size of the operand); the source operand is located in a general-purpose register or a memory location. T

        Unsigned multiply (AX := AL ∗ r/m8).

        Unsigned multiply (DX:AX := AX ∗ r/m16).

    + div

    > Divides unsigned the value in the AX, DX:AX, EDX:EAX, or RDX:RAX registers (dividend) by the source operand (divisor) and stores the result in the AX (AH:AL), DX:AX, EDX:EAX, or RDX:RAX registers. The source operand can be a general-purpose register or a memory location. The action of this instruction depends on the operand size (dividend/divisor). 

        DX : AX / 16 = AX ... DX    AX / 8 = AL ... AH

    + sbb

    > Adds the source operand (second operand) and the carry (CF) flag, and subtracts the result from the destination operand (first operand). The result of the subtraction is stored in the destination operand. The destination operand can be a register or a memory location; the source operand can be an immediate, a register, or a memory location.

        DEST := (DEST – (SRC + CF));

    + clc

    > The CF flag is set to 0. The OF, ZF, SF, AF, and PF flags are unaffected.

    + EFLAGS
        
    用#表示占位的话，可以看到16位的[flag寄存器](https://edge.edx.org/c4x/BITSPilani/EEE231/asset/8086_family_Users_Manual_1_.pdf)的功能如下：

    > ####OF DF IF TF SF ZF # AF # PF # CF  

17. x86 条件转移指令

    start:
        jump short start 
    
    被编译成 EB FE , 总共占2个字节, 而FE是-2, 可以跳转-128 <=> 127

    start:
        jump near start 

    被编译成 E9 FD FF, 占3个字节, 0XFFFD是-3, 可以跳转 -2^16 <=> 2^16 -1

    start:
        jmp 0x0:0x7c00 ; far
    
    被编译成 EA 00 7C 00 00, 占5个字节

18. 堆栈和函数

    ss: sp 作为栈的地址，在函数调用的时候，sp-2 变为新的栈顶， 然后将函数调用之后的那个地址放入栈顶

        loop1:
            call print
            loop loop1

        print:

            mov al, [ds:si] ;

            mov [es:di], al ;

            add si, 1
            add di, 2
            ret
    比如这里就是在call print时， 将loop loop1的地址压入新的-2后的栈顶。而在print返回时，ret指令又会将栈顶元素拿出来交给cs: ip 


19. 内中断和异常，callf 和 retf
    
    在intel手册V1-Chapter6和INC指令处有介绍调用、异常和中断

    > The INT n instruction generates a call to the interrupt or exception handler specified with the destination operand (see the section titled “Interrupts and Exceptions” in Chapter 6 of the Intel® 64 and IA-32 Architectures Software Developer’s Manual, Volume 1). The destination operand specifies a vector from 0 to 255, encoded as an 8-bit unsigned intermediate value. Each vector provides an index to a gate descriptor in the IDT. The first 32 vectors are reserved by Intel for system use. Some of these vectors are used for internally generated exceptions.


    > The vector specifies an interrupt descriptor in the interrupt descriptor table (IDT); that is, it provides index into the IDT. The selected interrupt descriptor in turn contains a pointer to an interrupt or exception handler procedure. In protected mode, the IDT contains an array of 8-byte descriptors, each of which is an interrupt gate, trap gate, or task gate. In real-address mode, the IDT is an array of 4-byte far pointers (2-byte code segment selector and a 2-byte instruction pointer), each of which point directly to a procedure in the selected segment. (Note that in real-address mode, the IDT is called the interrupt vector table, and its pointers are called interrupt vectors.)

    在使用call 和call far 时，分别会将ip和cs、ip入栈，而在 int 的时候则是将 cs、ip、EFLAG三个入栈;对应的也就需要ret、retf和iret分别将对应数量的寄存器出栈。

    如果要注册自己的中断函数的话，如下,对第80个中断向量注册了中断处理函数print,也就是要手动处理这4个字节的内容，当然处理函数需要使用iret进行返回操作

            mov word [0x80 * 4], print  ;ip
            mov word [0x80 * 4 + 2], 0  ;cs

    然后就是，有时需要显示使用 call far 指令才是callf

        call far [ds:print] ;callf
        call 0x0:print      ;callf



