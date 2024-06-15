	[bits 32]

	global _start

_start:	

	xchg bx, bx
	mov byte [0xb8000], 'K'
	jmp $
