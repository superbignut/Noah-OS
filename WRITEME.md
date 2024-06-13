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


