master.img:	boot.bin
	dd if=boot.bin of=master.img bs=512 count=1 conv=notrunc

boot.bin:	boot.asm
	nasm boot.asm -o boot.bin

master.vdi: master.img
	qemu-img convert -f raw -O vdi master.img master.vdi

.PHONY: bochs
bochs: master.img
	bochs -q

.PHONY: clean
clean:	
	rm *.bin *.vdi *.lock 2> /dev/null || true