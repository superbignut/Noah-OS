.PHONY: bochs
bochs: build/master.img
	cd build && bochs -q

build/master.img: build/boot.bin build/loader.bin
ifeq ("$(wildcard build/master.img)", "")
	bximage -func=create -hd=16M -imgmode=flat -sectsize=512 $@ -q
endif
	dd if=build/boot.bin of=$@ bs=512 count=1 conv=notrunc
# MBR 主引导扇区
	dd if=build/loader.bin of=$@ bs=512 count=4 seek=2 conv=notrunc	
# 跳过前两个扇区 从0x400 * 16 bytes 开始写4 * 512 = 2048个字节进入磁盘

build/%.bin: src/%.asm
	nasm $< -o $@ 

master.vdi: build/master.img
	qemu-img convert -f raw -O vdi build/master.img build/master.vdi

.PHONY: clean
clean:
ifeq ("$(wildcard build/*.bin)$(wildcard build/*.img)$(wildcard build/*.vdi)", "")
	@echo "Nothing be removed."
else
	@echo "$(wildcard build/*.bin) $(wildcard build/*.img) $(wildcard build/*.vdi) have been removed."
	rm build/*.bin build/*.vdi build/*.lock build/*.img 2> /dev/null || true
endif
	
	
