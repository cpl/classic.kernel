/*
   Copyright 2018-2019 Alexandru-Paul Copil

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


.section .data


.globl vfb_data
.align 4
vfb_data:		@
	.byte	0	@ cursor x
	.byte	0	@ cursor y
	.byte	0	@ max grid x
	.byte	0	@ max grid y


.section .text


@ vfb_init
@ Initialize the virtual-framebuffer (must be after fb_init) by prepering .
.globl vfb_init
vfb_init:
	PUSH	{R4-R5, LR}

	LDR	R5, =vfb_data		@ Get virtual-fb data address
	LDR	R4, =fb_mailbox		@ Get fb data address

	LDR	R0, [R4, #0]		@ Get fb width
	MOV	R1, #FONT_W		@
	BL	math_div		@ Get max grid width
	STRB	R0, [R5, #2]		@ Set max grid width

	LDR	R0, [R4, #4]		@ Get fb height
	MOV	R1, #FONT_H		@
	BL	math_div		@ Get max grid height
	STRB	R0, [R5, #3]		@ Set max grid height

	MOV	R0, #0			@ Reset cursor x and y to 0
	STRH	R0, [R5, #0]		@

	MVN	R0, #0			@ Make framebuffer white
	BL	draw_fill_fb		@

	POP	{R4-R5, PC}		@ Return


@ vfb_get_data -> (grid x, grid y, curs x, curs y)
@ Return the max grid X and Y in R0 and R1, and cursor X and Y in R2 and R3.
.globl vfb_get_data
vfb_get_data:
	PUSH	{R4}

	LDR	R4, =vfb_data		@ Get vfb data address
	LDR	R4, [R4]

	LSR	R1, R4, #24		@ Get grid X (R5) and Y (R6)
	LSR	R0, R4, #16		@
	AND	R0, R0, #0xFF		@

	LSR	R3, R4, #8		@ Get curs X (R7) and Y (R8)
	AND	R3, R3, #0xFF		@
	AND	R2, R4, #0xFF		@

	POP	{R4}			@ Return
	BX	LR			@


@ vfb_scroll
.globl vfb_scroll
vfb_scroll:
	PUSH	{R4}

	LDR	R0, =fb_mailbox		@ Get fb data
	LDR	R1, [R0, #0]		@ Get fb width
	LDR	R2, [R0, #36]		@ Get fb len
	LDR	R0, [R0, #32]		@ Get fb addr

	ADD	R2, R0, R2		@ Compute fb end addr

	MOV	R3, #FONT_H		@ Compute number of bytes
	MUL	R1, R3, R1		@ in a vfb line (width*font_h*2)
	LSL	R1, #1			@

	ADD	R3, R0, R1		@ Copy start addr

 _vfb_scroll:
	LDR	R4, [R3], #4		@ Copy pixels
	STR	R4, [R0], #4		@ Move pixels

	CMP	R3, R2			@ Check for end of fb
	BNE	_vfb_scroll		@ Repeat until end


	SUB	R3, R2, R1		@ Compute end minus last line
	LDR	R0, =colorB		@ Load background color
	LDRH	R0, [R0]		@
	ORR	R0, R0, R0, LSL #16	@

 _vfb_scroll_fin:

	STR	R0, [R3], #4		@ Fill final line with background color

	CMP	R3, R2			@ Check for end of fb
	BNE	_vfb_scroll_fin		@ Repeat until end

	POP	{R4}			@ Return
	BX	LR			@


@ vfb_reset
.globl vfb_reset
vfb_reset:
	LDR	R1, =vfb_data		@ Get vfb data address
	MOV	R0, #0			@ Reset both curs_x and curs_y to 0
	STRH	R0, [R1]		@
	BX	LR			@ Return


@ vfb_clear
.globl vfb_clear
vfb_clear:
	PUSH	{LR}
	BL	draw_get_color_b	@ Fill framebuffer with background
	BL	draw_fill_fb		@ color from gfx lib
	POP	{PC}
