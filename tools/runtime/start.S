	.option nopic
	.section .text.startup,"ax",@progbits
	.globl _start
_start:
	# Set up a minimal stack so compiled C prologues work.
	li   sp, 0x100
	# Call main; return value stays in a0 (x10).
	call main
1:	j 1b			# Hang after main returns
