.include "psr.s"


.section .init


.globl _reset
_reset:

	LDR	R0, =_init_start		@ Move entry point from 0x8000
	LDR	R1, =_init_end			@ to 0x0000 where the ARM CPU
	SUB	R1, R1, R0			@ expects them to be after a
	MOV	R2, #0				@ restart. On the first run the
	BL	memcopy				@ GPU enters at 0x8000 (_start)

	LDR	R0, =_bss_start			@ Zero BSS memory zone
	LDR	R1, =_bss_end			@
	SUB	R1, R1, R0			@
	BL	memzero				@

	MOV	R1, #0x80000000			@ Stack pointers storage

	MOV	R0, #(PSR_MODE_SVC|PSR_IRQ|PSR_FIQ)	@ SVC, DISABLE:
	MSR	CPSR_c, R0				@ IRQ & FIQ
	ADD	SP, R1, #0x2400				@ Set stack to 0x2400

	MOV	R0, #(PSR_MODE_ABT|PSR_IRQ|PSR_FIQ)	@ ABT, DISABLE:
	MSR	CPSR_c, R0				@ IRQ & FIQ
	ADD	SP, R1, #0x2800				@ Set stack to 0x2800

	MOV	R0, #(PSR_MODE_IRQ|PSR_IRQ|PSR_FIQ)	@ IRQ, DISABLE:
	MSR	CPSR_c, R0				@ IRQ & FIQ
	ADD	SP, R1, #0x2C00				@ Set stack to 0x2C00

	MOV	R0, #(PSR_MODE_SYS|PSR_IRQ|PSR_FIQ)	@ SYS, DISABLE:
	MSR	CPSR_c, R0				@ IRQ & FIQ
	ADD	SP, R1, #0x3C00				@ Set stack to 0x3C00

							@ Stay in SYS MODE

	B	sys_init
