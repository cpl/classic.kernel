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

	MOV	R0, #1280		@ Initialize framebuffer
	MOV	R1, #1024		@ 1280x1024, 16bit depth
	MOV	R2, #16			@
	BL	fb_init			@

	TEQ	R0, #0			@ Check for errors
	BEQ	_hang			@

	BL	vfb_init		@ Initialize virtual-framebuffer

	BL	clk_arm_init		@ Initialize ARM CLK
	BL	irq_cpsr_enable		@ Initialize Interrupts

	BL	mmu_setup		@ Define MMU sections
	BL	mmu_init		@ Configure and enable MMU

	BL	rand_init		@ Initialize RNG

	B	_main
