#### 看了github上的各个OS教程之后，会发现从零开始实现一个OS，真的是一个门槛非常高的领域：各种虚拟机软件，计算机名词，汇编等等。
#### 因此这个md文件就当作在学习各个教程时遇到的问题和解决办法的汇总，稳扎稳打，慢慢来。

1. [bochs](https://bochs.sourceforge.io/)

    bochs 是一个 x86 PC 模拟器，官网上说 bochs 可以模拟从 386 到 intel 和 amd 的 x86_64的多种 CPU ,因此和 VMware, Virtual Box, qemu 应该是同样的功能，但似乎 bochs调试上更优一些？

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

8. 先使用 bximage 制作了一块虚拟硬盘.img，然后使用 dd 命令将512字节的.bin 文件写入 .img , 为什么 bochs 就能够直接加载这个硬盘中的指令呢？同样的问题，为什么使用 qemu convert 转换为 vdi格式后，virtual_box也能直接打开呢？不需要一些对硬盘格式的说明吗？



    