/*
   Copyright 2018 Alexandru-Paul Copil

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/


.include "asm/gpio.s"


.section .rodata

_str_init_uart:		.asciz " INIT: UART OK"
_str_init_vcfb:		.asciz " INIT: VCFB OK"
_str_init_vtfb:		.asciz " INIT: VTFB OK"
_str_init_mmu:		.asciz " INIT: MMU  OK"
_str_init_util:		.asciz " INIT: UTIL OK"
_str_init_clk:		.asciz " INIT: CLK  OK"
_str_init_irq:		.asciz " INIT: IRQ  OK"
_str_init_kernel:	.asciz "\n START KERNEL INIT ..."

.section .init


.globl sys_init
sys_init:

	LDR	R0, =GPIO_ACT		@ Enable LED
	MOV	R1, #01			@
	BL	gpio_fsel		@
	LDR	R0, =GPIO_ACT		@ Turn on LED
	MOV	R1, #01			@
	BL	gpio_set		@

	BL	uart_init		@ Initialize mini-UART interface

	LDR	R0, =_str_init_uart	@ ! DEBUG
	BL	uart_send_string	@
	BL	uart_clrf		@

	MOV	R0, #1920		@ Initialize framebuffer
	MOV	R1, #1200		@ 1280x1024, 16bit depth
	MOV	R2, #16			@
	BL	fb_init			@

	TEQ	R0, #0			@ Check for errors
	BEQ	_hang			@

	BL	vfb_init		@ Initialize virtual-framebuffer

	LDR	R0, =_str_init_vcfb	@ ! DEBUG
	BL	vfb_println		@

	LDR	R0, =_str_init_vtfb	@ ! DEBUG
	BL	vfb_println		@

	BL	clk_arm_init		@ Initialize ARM CLK

	LDR	R0, =_str_init_clk	@ ! DEBUG
	BL	vfb_println		@

	BL	irq_cpsr_enable		@ Initialize Interrupts

	LDR	R0, =_str_init_irq	@ ! DEBUG
	BL	vfb_println		@

	BL	mmu_setup		@ Define MMU sections
	BL	mmu_init		@ Configure and enable MMU

	LDR	R0, =_str_init_mmu	@ ! DEBUG
	BL	vfb_println		@

	BL	rand_init		@ Initialize RNG

	LDR	R0, =_str_init_util	@ ! DEBUG
	BL	vfb_println		@

	LDR	R0, =_str_init_kernel	@ ! DEBUG
	BL	vfb_println		@

	B	_kinit			@ Init kernel
