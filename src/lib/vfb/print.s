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


.include "font.s"
.include "ascii.s"


.section .text


@ vfb_print (*str)
@ Print the given string on the virtual framebuffer, starting from the current
@ cursor x and y, wrapping or scrolling until a null terminator is reached.
.globl vfb_print
vfb_print:
	CMP	R0, #0			@ Ignore NULL string
	MOVEQ	PC, LR			@

	PUSH	{R4-R8, LR}

	curs_x		.req R7
	curs_y		.req R8
	grid_x		.req R5
	grid_y		.req R6

	MOV	R4, R0			@ Save string ptr in R4

	LDR	R1, =vfb_data		@ Get vfb data address
	LDR	R1, [R1]		@ Get vfb data

	LSR	R6, R1, #24		@ Get grid X (R5) and Y (R6)
	LSR	R5, R1, #16		@
	AND	R5, R5, #0xFF		@

	LSR	R8, R1, #8		@ Get curs X (R7) and Y (R8)
	AND	R8, R8, #0xFF		@
	AND	R7, R1, #0xFF		@

 _vfb_print_loop:
	LDRB	R0, [R4], #1		@ Load char

	CMP	curs_x, grid_x		@ Check X out of bounds
	MOVHS	curs_x, #0		@ Wrap to new line
	ADDHS	curs_y, #1		@
	CMP	curs_y, grid_y		@ Check Y out of bounds
	MOVHS	curs_x, #0		@ Wrap to top of screen
	MOVHS	curs_y, #0		@ TODO: Scroll one line

	TEQ	R0, #ASCII_LF		@ Check for line feed
	ADDEQ	curs_y, #1		@
	BEQ	_vfb_print_loop		@

	TEQ	R0, #ASCII_CR		@ Check for carriage return
	MOVEQ	curs_x, #0		@
	BEQ	_vfb_print_loop		@

	TEQ	R0, #ASCII_HT		@ Check for horizontal tab
	ADDEQ	curs_x, #FONT_TAB_SIZE	@
	BEQ	_vfb_print_loop		@

	TEQ	R0, #ASCII_NUL		@ Check for NULL TERMINATOR
	BEQ	_vfb_print_end		@

	LSL	R1, curs_x, #3		@ Transform grid space X to pixel space
	LSL	R2, curs_y, #4		@ Transform grid space Y to pixel space
	BL	draw_char		@ Draw char

	ADD	curs_x, #1		@ Next positon
	B	_vfb_print_loop		@ Next char

 _vfb_print_end:			@ End

	LDR	R0, =vfb_data		@ Get vfb data address
	STRB	curs_x, [R0, #0]	@ Save new curs x
	STRB	curs_y, [R0, #1]	@ Save new curs y

	.unreq curs_x
	.unreq curs_y
	.unreq grid_x
	.unreq grid_y

	POP	{R4-R8, PC}		@ Return


@ vfb_println (*str)
@ Print the given string on the virtual framebuffer, starting from the current
@ cursor x and y, wrapping or scrolling until a null terminator is reached. Then
@ move the cursor on the next line.
.globl vfb_println
vfb_println:
	PUSH	{LR}

	BL	vfb_print		@ Print string

	LDR	R0, =vfb_data		@ Get vfb data address
	LDRH	R1, [R0]		@ Load cursor x and y
	ADD	R1, #(1<<8)		@ Increment cursor y by one
	AND	R1, #0xFF00		@ Set cursor x to 0
	STRH	R1, [R0]		@ Update cursor

	POP	{PC}			@ Return


@ vfb_printdump(*addr, len)
@ Prints 'len' (R1) bytes starting from a given address (R0).
.globl vfb_printdump
vfb_printdump:
	CMP	R0, #0			@ Don't print NULL string or 0 len
	CMPNE	R1, #0			@
	MOVEQ	PC, LR			@

	PUSH	{R4-R9, LR}

	curs_x		.req R7
	curs_y		.req R8
	grid_x		.req R5
	grid_y		.req R6

	ADD	R9, R0, R1		@ Save end   address
	MOV	R4, R0			@ Save start address

	LDR	R1, =vfb_data		@ Get vfb data address
	LDR	R1, [R1]		@ Get vfb data

	LSR	R6, R1, #24		@ Get grid X (R5) and Y (R6)
	LSR	R5, R1, #16		@
	AND	R5, R5, #0xFF		@

	LSR	R8, R1, #8		@ Get curs X (R7) and Y (R8)
	AND	R8, R8, #0xFF		@
	AND	R7, R1, #0xFF		@

 _vfb_printdump:

	LDRB	R0, [R4], #1		@ Load char

	CMP	curs_x, grid_x		@ Check X out of bounds
	MOVHS	curs_x, #0		@ Wrap to new line
	ADDHS	curs_y, #1		@
	CMP	curs_y, grid_y		@ Check Y out of bounds
	MOVHS	curs_x, #0		@ Wrap to top of screen
	MOVHS	curs_y, #0		@ TODO: Scroll one line

	LSL	R1, curs_x, #3		@ Transform grid space X to pixel space
	LSL	R2, curs_y, #4		@ Transform grid space Y to pixel space
	BL	draw_char		@ Draw char


	ADD	curs_x, #1		@ Next position

	CMP	R4, R9			@ Check for end
	BNE	_vfb_printdump		@ Next char

 _vfb_printdump_end:
	LDR	R0, =vfb_data		@ Get vfb data address
	STRB	curs_x, [R0, #0]	@ Save new curs x
	STRB	curs_y, [R0, #1]	@ Save new curs y

	.unreq curs_x
	.unreq curs_y
	.unreq grid_x
	.unreq grid_y

	POP	{R4-R9, PC}		@ Return
