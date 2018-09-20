.include "gpio.s"


.section .init


.globl sys_init
sys_init:

	LDR	R0, =GPIO_ACT		@ Enable LED
	MOV	R1, #01			@
	BL	gpio_fsel		@
	LDR	R0, =GPIO_ACT		@ Turn on LED
	MOV	R1, #01			@
	BL	gpio_set		@

	B	_main
