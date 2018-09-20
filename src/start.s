.section .init


.globl _start
_start:

	LDR	PC, sig_reset
	LDR	PC, sig_undef
	LDR	PC, sig_swi
	LDR	PC, sig_prefc
	LDR	PC, sig_datah
	LDR	PC, sig_undef
	LDR	PC, sig_irq
	LDR	PC, sig_fiq

	B	_hang

sig_reset:	.word _reset
sig_undef:	.word _hang
sig_swi:	.word _hang
sig_prefc:	.word _hang
sig_datah:	.word _hang
sig_unuse:	.word _hang
sig_irq:	.word _hang
sig_fiq:	.word _hang
