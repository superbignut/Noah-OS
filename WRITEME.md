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

4. nasm

5. bximage_lba

6. [virtual-box](https://www.virtualbox.org/)

    同样也是一个虚拟机，相比与VMware的优点在于这个是开源的。由于我的电脑是ubuntu22.04,使用下面的命令可以成功安装：
    > sudo apt install virtualbox 
    
    > sudo apt install virtualbox-ext-pack

    最开始是从官网下载的deb包，但是发现后面在打开虚拟硬盘和安装拓展的时候总是报错。但回到 apt 进行安装就没什么问题。