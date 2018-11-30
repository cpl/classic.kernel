/*
   Copyright 2018 Alexandru-Paul Copil

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http:@www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/


.globl SWI_MAX_VAL
.set   SWI_MAX_VAL, -1


.macro MACRO_SWI_ENTRY			OP_NAME, CALL_FUNC

	.set	SWI_MAX_VAL, SWI_MAX_VAL+1
	.set	sys_\OP_NAME, SWI_MAX_VAL
	.globl	sys_\OP_NAME

	.section .rodata
	.word	\CALL_FUNC

	.section .text.usr
	.globl   syscall_\OP_NAME
	syscall_\OP_NAME:
		SWI	sys_\OP_NAME
		BX	LR
	.section .text
.endm


.section .rodata


_str_swi_undefined:	.ascii "SWI UNDEFINED\n\r\0"
_str_swi_unknown:	.ascii "SWI UNKOWN\n\r\0"
_str_swi_test:		.ascii "SWI WORKS!\n\r\0"


/****************************** SWI TABLE ************************************/
.align 4
_SWI_JUMP_TABLE:

	MACRO_SWI_ENTRY		exit,		_swi_undefined
	MACRO_SWI_ENTRY		kill,		_swi_undefined
	MACRO_SWI_ENTRY		spawn,		_swi_undefined
	MACRO_SWI_ENTRY		yield,		_swi_undefined

	MACRO_SWI_ENTRY		time,		clk_sys_epoch
	MACRO_SWI_ENTRY		sleep,		_swi_undefined

	MACRO_SWI_ENTRY		uputc,		uart_send
	MACRO_SWI_ENTRY		uputs,		uart_send_string
	MACRO_SWI_ENTRY		uputx,		uart_send_hex
	MACRO_SWI_ENTRY		ugetc,		uart_recv
	MACRO_SWI_ENTRY		uputnl,		uart_clrf

	MACRO_SWI_ENTRY		gpio_set,	gpio_set
	MACRO_SWI_ENTRY		gpio_sel,	gpio_fsel

	MACRO_SWI_ENTRY		print,		vfb_print
	MACRO_SWI_ENTRY		println,	vfb_println
	MACRO_SWI_ENTRY		printf,		vfb_printf

	MACRO_SWI_ENTRY		kmalloc,	kmalloc
	MACRO_SWI_ENTRY		kcalloc,	kcalloc
	MACRO_SWI_ENTRY		kfree,		kfree

	MACRO_SWI_ENTRY		cdraw,		draw_char
	MACRO_SWI_ENTRY		fdraw,		draw_fill_fb
	MACRO_SWI_ENTRY		sdraw,		draw_string

	MACRO_SWI_ENTRY		malloc,		_swi_undefined
	MACRO_SWI_ENTRY		calloc,		_swi_undefined
	MACRO_SWI_ENTRY		free,		_swi_undefined

/*****************************************************************************/


.section .text


@ _swi_handler
@ SWI handler.
.globl _swi_handler
_swi_handler:
	PUSH	{R4-R5, LR}

	MRS	R4, SPSR			@ Store SPSR
	PUSH	{R4}				@

	TST	R4, #0x20			@ Test thumb mode
	LDRNEH	R4, [LR, #-2]			@ Yes, load u16 SWI ID
	BICNE	R4, #0xFF00			@
	LDREQ	R4, [LR, #-4]			@ No,  load u32 SWI ID
	BICEQ	R4, #0xFF000000			@

						@ Handle SWI

	LDR	LR, =_swi_end			@ Prepare return to end routine

	CMP	R4, #SWI_MAX_VAL		@ Check for valid SWI OP code
	BHI	_swi_unknown			@ Invalid SWI routine

	LDR	R5, =_SWI_JUMP_TABLE		@ Load SWI routines table
	LDR	PC, [R5, R4, LSL #2]		@ Load SWI OP

 _swi_end:
	POP	{R4}				@ Restore SPSR
	MSR	SPSR, R4			@
	LDM	SP!, {R4-R5, PC}^		@ Restore registers and return


_swi_undefined:					@ DEBUG
	PUSH	{R0-R3, LR}			@ Save R0-R3

	MOV	R0, R4
	BL	strtmp_hex
	BL	uart_send_string
	BL	uart_clrf

	LDR	R0, =_str_swi_undefined		@ Display error msg over UART
	BL	uart_send_string		@ DEBUG

	POP	{R0-R3, PC}			@ Return


_swi_unknown:					@ DEBUG
	PUSH	{R0-R3, LR}			@ Save R0-R3

	MOV	R0, R4
	BL	strtmp_hex
	BL	uart_send_string
	BL	uart_clrf

	LDR	R0, =_str_swi_unknown		@ Display error msg over UART
	BL	uart_send_string		@ DEBUG

	POP	{R0-R3, PC}			@ Return
