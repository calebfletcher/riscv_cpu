.section .init
 
.option norvc
 
.type _start, @function
.global _start
_start:
	.cfi_startproc
 
.option push
.option norelax
	la gp, global_pointer
.option pop
 
	/* Reset satp */
 
	/* Setup stack */
	la sp, stack_top
 
	/* Clear the BSS section */
	la t5, bss_start
	la t6, bss_end
bss_clear:
	sw zero, (t5)
	addi t5, t5, 4
	bgeu t5, t6, bss_clear
 
pre_main:
	la t0, kmain
 
	/* Jump to kernel! */
	tail kmain
 
	.cfi_endproc
.end