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


.include "asm/fb.s"
.include "asm/mailbox.s"


.section .data


.align 4
.globl fb_mailbox
fb_mailbox:
		.int	DEFAULT_FB_WIDTH	@ Physical width
		.int	DEFAULT_FB_HEIGHT	@ Physical height
		.int	DEFAULT_FB_WIDTH	@ Virtual width
		.int	DEFAULT_FB_HEIGHT	@ Virtual height
		.int	0			@ GPU Pitch
		.int	DEFAULT_FB_BIT_DEPTH	@ Bit depth
		.int	0			@ X
		.int	0			@ Y
		.int	0			@ GPU pointer
		.int	0			@ GPU size


.section .text


@ fb_init (width, height, bit_depth) -> *fb
@ Takes width (R0), height (R1), bit depth (R2) and returns
@ the framebuffer address in R0 if successful, or 0 if not.
.globl fb_init
fb_init:
	CMP	R0, #MAX_FB_WIDTH	@ Check max width
	CMPLS	R1, #MAX_FB_HEIGHT	@ Check max height
	CMPLS	R2, #MAX_FB_BIT_DEPTH	@ Check max bit depth

	MOVHI	R0, #0			@ Return if invalid arguments
	MOVHI	PC, LR			@

	PUSH	{R4, LR}

	LDR	R4, =fb_mailbox		@ Load data address

	STR	R0, [R4, #0]		@ Update physical width
	STR	R1, [R4, #4]		@ Update physical height
	STR	R0, [R4, #8]		@ Update virtual  width
	STR	R1, [R4, #12]		@ Update virtual  height
	STR	R2, [R4, #20]		@ Update bit depth

	MOV	R0, #MB_FRAMEBUFFER	@ FB channel
	ADD	R1, R4, #0x40000000	@ Flush cache (check VC-MMU)
	BL	mb_write		@ Send data

	MOV	R0, #MB_FRAMEBUFFER	@ FB channel
	BL	mb_read			@ Read response

	TEQ	R0, #0			@ Check OK
	MOVNE	R0, #0			@ Not   OK
	POPNE	{R4, PC}		@ Return 0

	MOV	R0, R4			@ OK
	POP	{R4, PC}		@ Return framebuffer*


@ fb_set_addr (*fb)
@ Takes a framebuffer address in R0 and stores it at fb_mailbox, #32.
.globl fb_set_addr
fb_set_addr:
	LDR	R1, =fb_mailbox		@ Update framebuffer address
	STR	R0, [R1, #32]		@
	MOV	PC, LR			@ Return


@ fb_get_addr -> *fb
@ Loads from #32 fb_mailbox in R0.
.globl fb_get_addr
fb_get_addr:
	LDR	R0, =fb_mailbox		@
	LDR	R0, [R0, #32]		@
	MOV	PC, LR			@ Return
