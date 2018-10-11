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


_str_memdump_t: .ascii	" +-------------------------+\n\r"
		.ascii	" | [ MEMDUMP ]             |\n\r"
		.asciz	" +-[ ADDR ]---+-[ VALUE ]--+\n\r"
_str_memdump_b:	.asciz	" +------------+------------+\n\r"
_str_memdump_f:	.asciz	" | "


.section .text


@ memdump (void* addr, u32 len)
@ Dump `len` words, starting from the given address, to the uart interface
@ +-------------------------+
@ | [ MEMDUMP ]             |
@ +-[ ADDR ]---+-[ VALUE ]--+
@ | 0xFFFFDD00 | 0x00A01BDB |
@ | 0xFFFFDD04 | 0xA0A20BF0 |
@ | 0xFFFFDD08 | 0x0BA03BFF |
@ | 0xFFFFDD0C | 0x0CA40BCF |
@ | 0xFFFFDD10 | 0xD0A05BCF |
@ | 0xFFFFDD14 | 0xE0A60BCF |
@ | 0xFFFFDD18 | 0x0FA07BCB |
@ +------------+------------+
.globl memdump
memdump:
	TEQ	R0, #0				@ Check for invalid args
	TEQNE	R1, #0				@ and exit
	BXEQ	LR				@

	PUSH	{R4-R6, LR}

	MOV	R4, R0				@ Save args
	ADD	R5, R4, R1, LSL #2		@

	MOV	R0, #0x40			@ Allocate conversion buffer
	BL	cls_knl_malloc			@
	MOV	R6, R0				@ Save buffer pointer

	LDR	R0, =_str_memdump_t		@ Print table top
	BL	uart_send_string		@

 _memdump:
	LDR	R0, =_str_memdump_f		@ Print |
	BL	uart_send_string		@

	MOV	R0, R6				@ Buffer pointer
	MOV	R1, R4				@ Address value
	BL	conv_hex_str			@ Convert address to hex str
	MOV	R0, R6				@ Buffer pointer
	BL	uart_send_string		@ Print converted string

	LDR	R0, =_str_memdump_f		@ Print |
	BL	uart_send_string		@

	MOV	R0, R6				@ Buffer pointer
	LDR	R1, [R4], #4			@ Value at address, increment
	BL	conv_hex_str			@ Convert value to hex str
	MOV	R0, R6				@ Buffer pointer
	BL	uart_send_string		@ Print converted string

	LDR	R0, =_str_memdump_f		@ Print |
	BL	uart_send_string		@
	BL	uart_clrf			@ New line

	CMP	R4, R5				@ Check  if end
	BNE	_memdump			@ Repeat if not

	LDR	R0, =_str_memdump_b		@ Print table bottom
	BL	uart_send_string		@

	MOV	R0, R6				@ Free conversion buffer
	BL	cls_knl_free			@

	POP	{R4-R6, PC}			@ Return
