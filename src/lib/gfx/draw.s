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


.set FONT_W,	8
.set FONT_H,	16


.section .rodata


.align 4
font:		.incbin "data/font.bin"


.section .data


.align 1
colorF:		.hword 0xFFFF

.align 1
colorB:		.hword 0x1111


.section .text


@ draw_set_color_f (color)
@ Sets the foreground color to R0.
.globl draw_set_color_f
draw_set_color_f:
	LDR	R1, =colorF
	STRH	R0, [R1]
	MOV	PC, LR


@ draw_set_color_b (color)
@ Sets the background color to R0.
.globl draw_set_color_b
draw_set_color_b:
	LDR	R1, =colorB
	STRH	R0, [R1]
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
