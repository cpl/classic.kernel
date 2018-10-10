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


.section .rodata


.align 4
font:		.incbin "data/font.bin"


.section .data


.align 1
colorF:		.hword 0x0000

.align 1
colorB:		.hword 0xFFFF


.section .text


@ draw_set_color_f (color 16bit)
@ Sets the foreground color to R0.
.globl draw_set_color_f
draw_set_color_f:
	LDR	R1, =colorF
	STRH	R0, [R1]
	MOV	PC, LR


@ draw_set_color_b (color 16bit)
@ Sets the background color to R0.
.globl draw_set_color_b
draw_set_color_b:
	LDR	R1, =colorB
	STRH	R0, [R1]
	MOV	PC, LR


@ draw_get_color_b -> (color 16bit)
@ Gets the background color to R0.
.globl draw_get_color_b
draw_get_color_b:
	LDR	R0, =colorB
	LDRH	R0, [R0]
	MOV	PC, LR


@ draw_pixel (color, x, y)
@ Takes color (R0), x (R1), y (R2) and sets the pixel at x, y to color.
.globl draw_pixel
draw_pixel:
	PUSH	{R4-R5}

	addr				.req R0
	pixelX				.req R1
	pixelY				.req R2
	color				.req R4

	MOV	color, R0		@ Save color
	LDR	R0, =fb_mailbox		@ Get framebuffer address

	height	.req R5
	LDR	height, [addr, #4]	@ Get framebuffer height
	SUB	height, #1
	CMP	pixelY, height		@ Make sure pixel is in range
	POPHI	{R4-R5}			@ Exit if not
	MOVHI	PC, LR

	width	.req R5
	LDR	width, [addr, #0]	@ Get framebuffer width
	SUB	width, #1
	CMP	pixelX, width		@ Make sure pixel is in range
	POPHI	{R4-R5}			@ Exit if not
	MOVHI	PC, LR			@

	LDR	addr, [addr, #32]	@ Get framebuffer write address
	ADD	width, #1		@ Get right row

					@ pos = y * width + x
	MLA	pixelX, pixelY, width, pixelX

	ADD	addr, pixelX, LSL #1	@ Set offset
	STRH	color, [addr]		@ Write pixel

	POP	{R4-R5}			@ Return
	MOV	PC, LR			@

	.unreq addr
	.unreq pixelX
	.unreq pixelY
	.unreq color
	.unreq height
	.unreq width


@ draw_fill_fb (color 16 bit)
@ Fills the framebuffer with a single color.
.globl draw_fill_fb
draw_fill_fb:
	LDR	R1, =fb_mailbox		@ Get fb data address
	LDR	R2, [R1, #36]		@ Get fb length
	LDR	R1, [R1, #32]		@ Get fb address

	ADD	R2, R2, R1		@ Compute end address

	ORR	R0, R0, R0, LSL #16	@ Fill word with same color

 _draw_fill_fb:
	STR	R0, [R1], #4		@ Color 2 pixels
	CMP	R1, R2			@ Check for end address
	BNE	_draw_fill_fb		@ Repeat if not end

	MOV	PC, LR			@ Return


@ draw_char (char, x, y)
@ Takes the ASCII value of the char in R0, and the x R1, y R2 then
@ draws the char using the "font.bin" data, colorF for the 1 bits and colorB
@ for the 0 bits.
.globl draw_char
draw_char:
	CMP	R0, #127		@ Check char is ASCII 0-127
	MOVHI	PC, LR			@ Exit if not ASCII

	PUSH	{R4-R8, LR}

	x				.req R4
	y				.req R5
	cAddr				.req R6
	bits				.req R7
	bit				.req R8

	MOV	x, R1			@ Save x
	MOV	y, R2			@ Save y

	LDR	cAddr, =font		@ Get font base address
	ADD	cAddr, R0, LSL #4	@ Go to char address

 _draw_char_row:
	LDRB	bits, [cAddr]		@ Read row (8 bits)
	MOV	bit, #8			@ Set bit counter

 _draw_char_pix:
	SUB	bit, #1			@ Decrement counter

	LSL	bits, #1		@ Shift out wanted bit
	TST	bits, #0x100		@ Check if 0 or 1
	LDRNE	R0, =colorF		@ If 1, select foreground color
	LDREQ	R0, =colorB		@ If 0, select background color

	LDRH	R0, [R0]		@ Load color
	ADD	R1, x, bit		@ Set screen X
	MOV	R2, y			@ Set screen Y
	BL	draw_pixel		@ Draw pixel

	TEQ	bit, #0			@ Check if done with row
	BNE	_draw_char_pix		@ If not, draw next pixel

 _draw_char_end:
	.unreq bits
	.unreq bit

	ADD	y, #1			@ Next row screen
	ADD	cAddr, #1		@ Next row char bin data
	TST	cAddr, #0b1111		@ Check if valid
	BNE	_draw_char_row		@ Draw next row

	.unreq x
	.unreq y
	.unreq cAddr

	POP	{R4-R8, PC}		@ Return


@ draw_string (*str, x, y)
@ Draw a given string starting from given X and Y, does not wrap or scroll
@ the framebuffer when the screen edge is reached.
.globl draw_string
draw_string:
	PUSH	{R4-R6, LR}

	MOV	R4, R0			@ Save arguments
	MOV	R5, R1			@
	MOV	R6, R2			@

 _draw_string:
	LDRB	R0, [R4], #1		@ Load char

	TEQ	R0, #0			@ Exit if NULL terminator
	POPEQ	{R4-R6, PC}		@

	MOV	R1, R5			@ Set X
	MOV	R2, R6			@ Set Y
	BL	draw_char		@ Draw char

	ADD	R5, #FONT_W		@ Increment X
	BL	_draw_string		@ Loop
