	.file	"add.c"
	.option nopic
	.attribute arch, "rv64i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	li	a5,2
	sd	a5,8(sp)
	li	a5,3
	sd	a5,16(sp)
	ld	a5,8(sp)
	ld	a4,16(sp)
	add	a5,a5,a4
	sd	a5,24(sp)
	ld	a0,24(sp)
	addi	sp,sp,32
	sext.w	a0,a0
	jr	ra
	.size	main, .-main
	.ident	"GCC: () 9.3.0"
