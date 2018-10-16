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


.section .rodata


_str_hang:	.ascii "HANG\n\r\0"

.align 4
_str_char:
	.byte 0
	.byte 0
	.byte 0
	.byte 0


.section .text


.globl _main
_main:


 _main_loop:
	BL	clk_sys_epoch
	BL	strtmp_hex
	MOV	R1, #1000
	MOV	R2, #900
	BL	draw_string

	MOV	R0, SP
	BL	strtmp_hex
	MOV	R1, #1000
	MOV	R2, #920
	BL	draw_string

	MOV	R0, PC
	BL	strtmp_hex
	MOV	R1, #1000
	MOV	R2, #940
	BL	draw_string

	LDR	R0, =_KERNEL_ALOC_LAST
	LDR	R0, [R0]
	BL	strtmp_hex
	MOV	R1, #1000
	MOV	R2, #960
	BL	draw_string

	LDR	R0, =_KERNEL_ALOC_TAIL
	LDR	R0, [R0]
	BL	strtmp_hex
	MOV	R1, #1000
	MOV	R2, #980
	BL	draw_string

	B	_main_loop


.globl _hang
_hang:

	LDR	R0, =_str_hang
	BL	uart_send_string

	B .
