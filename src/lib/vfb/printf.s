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


.include "asm/font.s"
.include "asm/ascii.s"


.section .text


@ vfb_printf
@ printf (*format, **args)
@ Takes a format string pointer (R0) and a starting pointer for args, each arg
@ has to be a pointer to the coresponding value.
@ Table of format flags:
@ c - char
@ h - base10 unsigned short 16bit
@ i - base10 signed integer 32bit
@ d - base10 signed integer 64bit
@ u - base10 unsigned integer 32bit
@ l - base10 unsigned integer 64bit
@ x - base16 unsigned integer, 0x padd
@ s - *string
.globl vfb_printf
vfb_printf:
	TEQ	R0, #0			@ Ignore NULL string
	MOVEQ	PC, LR			@

	PUSH	{R4-R10, LR}

	args		.req R4
	fmts		.req R9

	curs_x		.req R7
	curs_y		.req R8
	grid_x		.req R5
	grid_y		.req R6

	MOV	fmts, R0		@ Save start address of format string
	MOV	args, R1		@ Save start address of args

	LDR	R10, =vfb_data		@ Get vfb data address
	LDR	R1, [R10]		@ Get vfb data

	LSR	R6, R1, #24		@ Get grid X (R5) and Y (R6)
	LSR	R5, R1, #16		@
	AND	R5, R5, #0xFF		@

	LSR	R8, R1, #8		@ Get curs X (R7) and Y (R8)
	AND	R8, R8, #0xFF		@
	AND	R7, R1, #0xFF		@

 _vfb_printf_loop:
	CMP	curs_x, grid_x		@ Check X out of bounds
	MOVHS	curs_x, #0		@ Wrap to new line
	ADDHS	curs_y, #1		@
	CMP	curs_y, grid_y		@ Check Y out of bounds
	MOVHS	curs_x, #0		@ Wrap to new line
	SUBHS	curs_y, #1		@ Keep line
	BLHS	vfb_scroll		@ Scroll vfb

	LDRB	R0, [fmts], #1		@ Load char from format string

	TEQ	R0, #'%'		@ Check for arg flag
	BEQ	_vfb_printf_fmt		@ Parse arg

	TEQ	R0, #'\\'		@ Check for escape flag
	BEQ	_vfb_printf_esc		@ Parse escape

	TEQ	R0, #ASCII_LF		@ Check for new line
	MOVEQ	curs_x, #0		@
	ADDEQ	curs_y, #1		@
	BEQ	_vfb_printf_loop	@

	TEQ	R0, #ASCII_HT		@ Check for horizontal tab
	ADDEQ	curs_x, #FONT_TAB_SIZE	@
	BEQ	_vfb_printf_loop	@

	TEQ	R0, #ASCII_NUL		@ Check for NULL TERMINATOR
	BEQ	_vfb_printf_end		@

 _vfb_printf_char:
	LSL	R1, curs_x, #3		@ Transform grid space X to pixel space
	LSL	R2, curs_y, #4		@ Transform grid space Y to pixel space
	BL	draw_char		@ Draw char

	ADD	curs_x, #1		@ Next position

	B	_vfb_printf_loop	@ Next char

 _vfb_printf_end:

	STRB	curs_x, [R10, #0]	@ Save new curs x
	STRB	curs_y, [R10, #1]	@ Save new curs y

	POP	{R4-R10, PC}		@ Return

 _vfb_printf_fmt:
	LDRB	R0, [fmts], #1		@ Load arg type char

	TEQ	R0, #'%'		@ Case '%%'
	BEQ	_vfb_printf_char	@

	TEQ	R0, #'c'		@ Case '%c'
	LDREQ	R0, [args], #4		@
	LDREQB	R0, [R0]		@
	BEQ	_vfb_printf_char	@

	TEQ	R0, #'i'		@ Case '%i'
	LDREQ	R0, [args], #4		@
	LDREQ	R2, [R0]		@
	LDREQ	R3, =str_conv_s32	@
	BEQ	_vfb_printf_cnv		@

	TEQ	R0, #'h'		@ Case '%h'
	LDREQ	R0, [args], #4		@
	LDREQH	R2, [R0]		@
	LDREQ	R3, =str_conv_u16	@
	BEQ	_vfb_printf_cnv		@

	TEQ	R0, #'u'		@ Case '%u'
	LDREQ	R0, [args], #4		@
	LDREQ	R2, [R0]		@
	LDREQ	R3, =str_conv_u32	@
	BEQ	_vfb_printf_cnv		@

	TEQ	R0, #'x'		@ Case '%x'
	LDREQ	R0, [args], #4		@
	LDREQ	R2, [R0]		@
	LDREQ	R3, =str_conv_hex	@
	BEQ	_vfb_printf_cnv		@

	TEQ	R0, #'s'		@ Case '%s'
	LDREQ	R0, [args], #4		@
	BLEQ	vfb_print		@

	B	_vfb_printf_loop	@ Next

 _vfb_printf_cnv:
	STRB	curs_x, [R10, #0]	@ Save new curs x
	STRB	curs_y, [R10, #1]	@ Save new curs y

	MOV	R1, #0x40		@ malloc size
	BL	cls_knl_malloc		@ malloc string conversion buffer
	PUSH	{R0}			@ Store malloc pointer

	MOV	R1, R2			@ Get value
	MOV	LR, PC			@ Return to vfb_print
	MOV	PC, R3			@ BL str_conv_

	BL	vfb_print		@ Print converted string from buffer

	POP	{R0}			@ Get malloc pointer and free it
	BL	cls_knl_free		@

	LDRB	curs_x, [R10, #0]	@ Load new curs x
	LDRB	curs_y,	[R10, #1]	@ Load new curs y

	B	_vfb_printf_loop

_vfb_printf_esc:
	LDRB	R0, [fmts], #1		@ Load char from format string

	TEQ	R0, #'\'		@ Escapable chars, print as char
	TEQNE	R0, #'%'		@
	BEQ	_vfb_printf_char	@

	TEQ	R0, #'n'		@ Case '\n'
	ADDEQ	curs_y, #1		@
	BEQ	_vfb_printf_loop	@

	TEQ	R0, #'r'		@ Case '\r'
	MOVEQ	curs_x, #0		@
	BEQ	_vfb_printf_loop	@

	TEQ	R0, #'t'		@ Case '\t'
	ADDEQ	curs_x, #FONT_TAB_SIZE	@
	BEQ	_vfb_printf_loop	@

	TEQ	R0, #'0'		@ Case '\0'
	BEQ	_vfb_printf_end		@ Instant NULL TERMINATOR

	B	_vfb_printf_char	@ Print anything else as char

	.unreq curs_x
	.unreq curs_y
	.unreq grid_x
	.unreq grid_y

	.unreq fmts
	.unreq args			@ End of vfb_printf
