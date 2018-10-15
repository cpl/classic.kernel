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


	MOV	R0, #0xA1
	MOV	R1, #0xB2
	MOV	R2, #0xC3
	MOV	R3, #0xD4
	PUSH	{R0-R3}

	MOV	R0, SP
	MOV	R1, #0x20
	BL	_memdump


	BL	cmain

	BL	csudUsbInitialise
	LDR	R4, =_str_char

	BL	KeyboardUpdate
	BL	KeyboardGetChar

	@ BL	mem_block_printmem

 _main_loop:

	BL	KeyboardUpdate
	BL	KeyboardGetChar

	CMP R0, #0
	STRNEB	R0, [R4]
	MOVNE	R0, R4
	BLNE	vfb_print

	BL	clk_sys_epoch
	BL	strtmp_hex
	MOV	R1, #1000
	MOV	R2, #960
	BL	draw_string

	MOV	R0, SP
	BL	strtmp_hex
	MOV	R1, #1000
	MOV	R2, #980
	BL	draw_string

	MOV	R0, PC
	BL	strtmp_hex
	MOV	R1, #1000
	MOV	R2, #1000
	BL	draw_string

	B	_main_loop


.globl _hang
_hang:

	LDR	R0, =_str_hang
	BL	uart_send_string

	B .
