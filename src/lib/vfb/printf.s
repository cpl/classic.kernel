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
@ void printf (const char* fmt, ...)
@ Takes a format string pointer (R0) and a set of variable arguments which
@ are stored on the stack, starting from SP and going UP.
@ Table of format flags:
.globl vfb_printf
vfb_printf:
	TEQ	R0, #0			@ Ignore NULL string
	BXEQ	LR			@

	char	.req R0			@ Alias registers to make
	fmts	.req R4			@ the function a little bit
	args	.req R5			@ more readable.
	grid_x	.req R6			@
	grid_y	.req R7			@
	curs_x	.req R8			@
	curs_y	.req R9			@
	vfbdat	.req R10		@
	cvbufr	.req R11		@

	PUSH	{R1-R3}			@ Push all variable arguments
					@ R0 (const char* fmt) is ignored

	PUSH	{R4-R12, LR}		@ Normal context save

	MOV	fmts, R0		@ Save format string pointer
	ADD	args, SP, #(10*4)	@ Save varg stack pointer

	LDR	vfbdat, =vfb_data	@ Get vfb data address
	LDR	R1, [vfbdat]		@ Get vfb data

	LSR	grid_y, R1, #24		@ Get grid X and Y
	LSR	grid_x, R1, #16		@
	AND	grid_x, grid_x, #0xFF	@

	LSR	curs_y, R1, #8		@ Get curs X and Y
	AND	curs_y, curs_y, #0xFF	@
	AND	curs_x, R1, #0xFF	@

	MOV	R0, #0x40		@ Allocate conversion buffer
	BL	syscall_kmalloc		@
	MOV	cvbufr, R0		@ Save pointer

 _vfb_printf_loop:
	CMP	curs_x, grid_x		@ Check X out of bounds
	MOVHS	curs_x, #0		@ Wrap to new line
	ADDHS	curs_y, #1		@
	CMP	curs_y, grid_y		@ Check Y out of bounds
	MOVHS	curs_x, #0		@ Wrap to new line
	SUBHS	curs_y, #1		@ Keep line
	BLHS	vfb_scroll		@ Scroll vfb

	LDRB	char, [fmts], #1	@ Load char from format string

	TEQ	char, #'%'		@ Check for arg flag
	BEQ	_vfb_printf_fmt		@ Parse arg

	TEQ	char, #'\\'		@ Check for escape flag
	BEQ	_vfb_printf_esc		@ Parse escape

	TEQ	char, #ASCII_LF		@ Check for new line
	MOVEQ	curs_x, #0		@
	ADDEQ	curs_y, #1		@
	BEQ	_vfb_printf_loop	@

	TEQ	char, #ASCII_HT		@ Check for horizontal tab
	ADDEQ	curs_x, #FONT_TAB_SIZE	@
	BEQ	_vfb_printf_loop	@

	TEQ	char, #ASCII_NUL	@ Check for NULL TERMINATOR
	BEQ	_vfb_printf_end		@

					@ If none, print as char

 _vfb_printf_char:
	LSL	R1, curs_x, #3		@ Transform grid space X to pixel space
	LSL	R2, curs_y, #4		@ Transform grid space Y to pixel space
	BL	draw_char		@ Draw char

	ADD	curs_x, #1		@ Next position

	B	_vfb_printf_loop	@ Next char

 _vfb_printf_end:

	STRB	curs_x, [vfbdat, #0]	@ Save new curs x
	STRB	curs_y, [vfbdat, #1]	@ Save new curs y

	MOV	R0, cvbufr		@ Free conversion buffer
	BL	syscall_kfree		@

	POP	{R4-R12, LR}		@ Restore context
	ADD	SP, #(3*4)		@
	BX	LR			@ Return

 _vfb_printf_fmt:
	LDRB	char, [fmts], #1	@ Load arg type char

	TEQ	char, #'c'		@ Case '%c'
	LDREQB	char, [args], #4	@
	BEQ	_vfb_printf_char	@

	TEQ	char, #'x'		@ Case '%x'
	LDREQ	R1, [args], #4		@
	LDREQ	R2, =conv_hex_str	@
	BEQ	_vfb_printf_cnv		@

	TEQ	char, #'i'		@ Case '%i'
	LDREQ	R1, [args], #4		@
	LDREQ	R2, =conv_s32_str	@
	BEQ	_vfb_printf_cnv		@

	TEQ	char, #'u'		@ Case '%u'
	LDREQ	R1, [args], #4		@
	LDREQ	R2, =conv_u32_str	@
	BEQ	_vfb_printf_cnv		@

	TEQ	char, #'%'		@ Case '%%'
	BEQ	_vfb_printf_char	@

	TEQ	char, #'s'		@ Case '%s'
	LDREQ	R0, [args], #4		@
	STRB	curs_x, [vfbdat, #0]	@ Save new curs x
	STRB	curs_y, [vfbdat, #1]	@ Save new curs y
	BLEQ	vfb_print		@ Print string
	LDRB	curs_x, [vfbdat, #0]	@ Load new curs x
	LDRB	curs_y,	[vfbdat, #1]	@ Load new curs y

	B	_vfb_printf_loop	@ Next

 _vfb_printf_cnv:

	MOV	R0, cvbufr		@ Load conversion buffer

	MOV	LR, PC			@ Return to print conversion string
	MOV	PC, R2			@ Go to conversion function

	MOV	R12, cvbufr

 _vfb_printf_cnv_p:			@ Print generated converted string

	CMP	curs_x, grid_x		@ Check X out of bounds
	MOVHS	curs_x, #0		@ Wrap to new line
	ADDHS	curs_y, #1		@
	CMP	curs_y, grid_y		@ Check Y out of bounds
	MOVHS	curs_x, #0		@ Wrap to new line
	SUBHS	curs_y, #1		@ Keep line
	BLHS	vfb_scroll		@ Scroll vfb

	LDRB	char, [R12], #1		@ Get char
	TEQ	char, #ASCII_NUL	@ Check for NULL TERMINATOR
	BEQ	_vfb_printf_loop	@

	LSL	R1, curs_x, #3		@ Print char
	LSL	R2, curs_y, #4		@
	BL	draw_char		@

	ADD	curs_x, #1		@ Next
	B	_vfb_printf_cnv_p	@


_vfb_printf_esc:
	LDRB	char, [fmts], #1	@ Load char from format string

	TEQ	char, #'\'		@ Escapable chars, print as char
	TEQNE	char, #'%'		@
	BEQ	_vfb_printf_char	@

	TEQ	char, #'n'		@ Case '\n'
	ADDEQ	curs_y, #1		@
	BEQ	_vfb_printf_loop	@

	TEQ	char, #'r'		@ Case '\r'
	MOVEQ	curs_x, #0		@
	BEQ	_vfb_printf_loop	@

	TEQ	char, #'t'		@ Case '\t'
	ADDEQ	curs_x, #FONT_TAB_SIZE	@
	BEQ	_vfb_printf_loop	@

	TEQ	char, #'0'		@ Case '\0'
	BEQ	_vfb_printf_end		@ Instant NULL TERMINATOR

	B	_vfb_printf_char	@ Print anything else as char

	.unreq char
	.unreq fmts
	.unreq args
	.unreq grid_x
	.unreq grid_y
	.unreq curs_x
	.unreq curs_y
	.unreq vfbdat
	.unreq cvbufr
