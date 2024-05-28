#### 用于记录进入保护模式之后的学习过程

1. 内存映射

    > On the x86-64 architecture, page-level protection now completely supersedes Segmentation as the memory protection mechanism. On the IA-32 architecture, both paging and segmentation exist, but segmentation is now considered 'legacy'.
    
    所以说我一直使用的是I-32不是x86-64，查看[osdev](https://wiki.osdev.org/Bochs):

    > The default compile does not support x86-64, --enable-x86-64 will turn it on.

    所以如果配置的时候没有加这个修饰的话，应该就是32位的了，在配置文件里应该能看出来，但是没找到具体在哪。


    还是要总结一下 segment-selector 和 segment-descriptor的结构和内容说明:

    ```cpp
    typedef struct segment_selector{
        RPL_2,
        TI_1,
        Index_13
    } segment_selector;
    ```
    

    ```cpp
    typedef struct segment_descriptor
    {
        Segment_Limit_16[0 : 15],
        Base_Address_24[0 : 23],
        Type_4,
        S_1,
        DPL_2,
        P_1,
        Segment_Limit_4[16 : 19],
        AVL_1,
        L_1,
        DB_1,
        G_1,
        Base_Address_8[24 : 31]
    } segment_descriptor;
    ```
    

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
