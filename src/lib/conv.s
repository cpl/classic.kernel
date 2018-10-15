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


_str_null:	.ascii "NULL\0"


.section .text


@ conv_hex_str (*str_buffer, value)
@ Takes a string buffer and writes the hexadecimal representation of the value.
.globl conv_hex_str
conv_hex_str:

	MOV	R2, #'0'		@ Pre-padd string with "0x"
	ORR	R2, R2, #('x'<<8)	@
	STR	R2, [R0], #2		@

	MOV	R2, #32			@ Shift

 _conv_hex_str:
	SUB	R2, #4			@ Move shift

	LSR	R3, R1, R2		@ Shift value
	AND	R3, R3, #0xF		@ Get 4 bits

	CMP	R3, #9			@ Check for:
	ADDHI	R3, #0x37		@ char
	ADDLS	R3, #0x30		@ digit

	STRB	R3, [R0], #1		@ Store char

	CMP	R2, #0			@ Check for end of value
	BNE	_conv_hex_str		@ Repeat if not end

	MOV	R1, #0			@ Write NULL terminator at the end
	STRB	R1, [R0]		@ of the string

	BX	LR			@ Return


@ conv_u16_str (*str_buffer, value)
.globl conv_u16_str
conv_u16_str:
	LDR	R0, =_str_null
	BX	LR


@ conv_u32_str (*str_buffer, value)
.globl conv_u32_str
conv_u32_str:
	LDR	R0, =_str_null
	BX	LR


@ conv_s32_str (*str_buffer, value)
.globl conv_s32_str
conv_s32_str:
	LDR	R0, =_str_null
	BX	LR
