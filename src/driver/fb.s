.include "mailbox.s"


.set	MAX_FB_WIDTH,		4096
.set	MAX_FB_HEIGHT,		4096
.set	MAX_FB_BIT_DEPTH,	32

.set	DEFAULT_FB_WIDTH,	800
.set	DEFAULT_FB_HEIGHT,	480
.set	DEFAULT_FB_BIT_DEPTH,	16


.section .data


@ DEBUG, TEMPORARY MAILBOX STYLE BUFFER FOR FB MAILBOX!
.align 4
.globl fbInfo
fbInfo:
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


.align 2
fbAddr:		.int 0


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

	LDR	R4, =fbInfo		@ Load data address

	STR	R0, [R4, #0]		@ Update physical width
	STR	R1, [R4, #4]		@ Update physical height
	STR	R0, [R4, #8]		@ Update virtual  width
	STR	R1, [R4, #12]		@ Update virtual  height
	STR	R2, [R4, #20]		@ Update bit depth

	ADD	R0, R4, #0x40000000	@ Flush cache (check VC-MMU)
	MOV	R1, #MB_FRAMEBUFFER	@ GPU channel
	BL	mb_write		@ Write data address

	MOV	R0, #MB_FRAMEBUFFER	@ GPU channel
	BL	mb_read			@ Read response

	TEQ	R0, #0			@ Check OK
	MOVNE	R0, #0			@ Not   OK
	POPNE	{R4, PC}		@ Return 0

	MOV	R0, R4			@ OK
	POP	{R4, PC}		@ Return framebuffer info address


@ fb_set_addr (*fb)
@ Takes a framebuffer address in R0 and stores it at fbAddr label.
.globl fb_set_addr
fb_set_addr:
	PUSH	{R4}

	LDR	R4, =fbAddr		@ Update framebuffer address
	STR	R0, [R4]		@

	POP	{R4}			@ Return
	MOV	PC, LR			@


@ fb_get_addr -> *fb
@ Loads the fbAddr in R0
.globl fb_get_addr
fb_get_addr:
	LDR	R0, =fbAddr
	LDR	R0, [R0]
	MOV	PC, LR			@ Return
