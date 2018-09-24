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

	BL	uart_init		@ Initialize mini-UART interface

	MOV	R0, #1280		@ Initialize framebuffer
	MOV	R1, #1024		@
	MOV	R2, #16			@
	BL	fb_init			@
	TEQ	R0, #0			@ Check for errors
	BEQ	_hang			@
	BL	fb_set_addr		@ Save framebuffer address

	B	_main
