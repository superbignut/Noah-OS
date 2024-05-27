#### 用于记录进入保护模式之后的学习过程

1. 内存映射

    > On the x86-64 architecture, page-level protection now completely supersedes Segmentation as the memory protection mechanism. On the IA-32 architecture, both paging and segmentation exist, but segmentation is now considered 'legacy'.
    
    所以说我一直使用的是I-32不是x86-64，查看[osdev](https://wiki.osdev.org/Bochs):

    > The default compile does not support x86-64, --enable-x86-64 will turn it on.

    所以如果配置的时候没有加这个修饰的话，应该就是32位的了，在配置文件里应该能看出来，但是没找到具体在哪。

    - 虚拟内存
    - 多进程访问同一地址
    - 内存分页 4kB  4G / 4k = 2 ^20
    
    ```cpp
        unsigned int page_table[1 << 20]; // 每一个进程都要有一个页表
    ```

    int 是 4个字节 所以需要4MB的内存来存储一个页表， 但是4MB太多了 

    4MB占了1024个页

    页目录
    ```cpp
        unsigned int pde[1024]; // 页目录
    ```

    一页页目录， 一页 页表 总共8KB

    页表的信息

    ```cpp
        struct page_entry{
            
        }
    ```
