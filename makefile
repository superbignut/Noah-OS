ENTRYPOINT := 0x10000


.PHONY: bochs
bochs: build/master.img
	@echo "$(dir $<)"
	bochs -q  

build/master.img: build/boot.bin \
			build/loader.bin \
			build/system.bin \
			build/system.map 
ifeq ("$(wildcard build/master.img)", "")
	bximage -func=create -hd=16M -imgmode=flat -sectsize=512 $@ -q
# 创建硬盘镜像
endif
	dd if=build/boot.bin of=$@ bs=512 count=1 conv=notrunc
# MBR 主引导扇区
	dd if=build/loader.bin of=$@ bs=512 count=4 seek=2 conv=notrunc	
# 跳过前两个扇区 从0x400 * 16 bytes 开始写4 * 512 = 2048个字节进入磁盘
	dd if=build/system.bin of=$@ bs=512 count=200 seek=10 conv=notrunc
# 跳过前10个扇区，写200个扇区

build/kernel/%.o: src/kernel/%.asm
	$(shell mkdir -p $(dir $@))
	@echo "$(dir $@)"
	nasm -f elf32 $< -o $@

# 暂不理解
build/kernel.bin: build/kernel/start.o
	$(shell mkdir -p $(dir $@))
	ld -m elf_i386 -static $^ -o $@ -Ttext $(ENTRYPOINT)

# 暂不理解
build/system.bin: build/kernel.bin
	objcopy -O binary $< $@
# 暂不理解
build/system.map: build/kernel.bin
	nm $< | sort > $@

test: build/kernel.bin

build/%.bin: src/%.asm
	$(shell mkdir -p $(dir $@))
	nasm $< -o $@ 

.PHONY: clean
clean:

	rm ./build/ -rf
