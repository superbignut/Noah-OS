1. int 0x10

	[0x10中断参考](https://stanislavs.org/helppc/int_10-0.html)

+ int 0x10 整体是设置显示的模式，我们使用的是 ax = 0x03, 具体暂不深入了解
    AH = 00
	AL = 00  40x25 B/W text (CGA,EGA,MCGA,VGA)
	   = 01  40x25 16 color text (CGA,EGA,MCGA,VGA)
	   = 02  80x25 16 shades of gray text (CGA,EGA,MCGA,VGA)
	   = 03  80x25 16 color text (CGA,EGA,MCGA,VGA)

2. 0xb8000 显示

	[0xb8000 参考](https://wiki.osdev.org/Printing_To_Screen)


3. \n \r 

	一个是回到这一行的开头，一个是移动到下一行，所以 \n\r结合可以移动到下一行的开头，但是似乎不同OS的还是CPU的理解还不一样。


4. 保护模式print 和 read-disk

	+ 使用int 的方式似乎不能够在保护模式下进行字符的打印，
	+ 当把实模式的read-disk 放到保护模式下的时候，无法读取，发现是使用了 es:edi的偏移方式，并且add di, 2,这些问题在实模式下都没有出现，但是无法在保护模式下执行
	+ 然后就是在 BITS32 下执行 BITS16 的代码 似乎也是可以的，也就是 read-disk放在 32和16 都能在 bit32下调用，但为啥int就用不了了呢
	+ kernel的asm文件是先被编译成 elf文件，之后才又被链接成.bin文件的， 因此里面的类似于GLOBAL的字样是有作用的
