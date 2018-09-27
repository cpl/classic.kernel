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
	MOV	PC, LR			@
