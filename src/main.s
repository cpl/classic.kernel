.include "gpio.s"


.section .text


.globl _start
_start:

	LDR	R0, =GPIO_ACT		@ Activate ACT LED
	MOV	R1, #1			@
	BL	gpio_fsel		@

	LDR	R0, =GPIO_ACT		@ Turn on ACT LED
	MOV	R1, #1			@
	BL	gpio_set		@

	B	_hang			@ Hang execution

.globl _hang
_hang:
	B .
