hello.s: hello.c
	gcc -m32 -S -fno-asynchronous-unwind-tables -fno-pic -mpreferred-stack-boundary=2  -masm=intel $< -o $@
CFI: hello.c
	gcc -m32 -S $< -o hello.s
.PHONY:  hello.s

