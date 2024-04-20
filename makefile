.PHONY: bochs
bochs: master.img
	bochs -q

master.img:	boot.bin
ifeq ("$(wildcard master.img)", "")
	bximage -func=create -hd=16M -imgmode=flat -sectsize=512 $@ -q
endif
	dd if=$< of=$@ bs=512 count=1 conv=notrunc


%.bin:	%.asm
	nasm $< -o $@ 

master.vdi: master.img
	qemu-img convert -f raw -O vdi master.img master.vdi

.PHONY: clean
clean:
ifeq ("$(wildcard *.bin)$(wildcard *.img)$(wildcard *.vdi)", "")
	@echo "Nothing be removed."
else
	@echo "$(wildcard *.bin) $(wildcard *.img) $(wildcard *.vdi) have been removed."
	rm *.bin *.vdi *.lock *.img 2> /dev/null || true
endif
	
	
