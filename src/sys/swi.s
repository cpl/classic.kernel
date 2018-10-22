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


.set	SWI_MAX,	0xC


.section .rodata


_str_swi_undefined:	.ascii "SWI UNDEFINED\n\r\0"
_str_swi_unknown:	.ascii "SWI UNKOWN\n\r\0"
_str_swi_test:		.ascii "SWI WORKS!\n\r\0"


/****************************** SWI TABLE ************************************/
.align 4
_SWI_JUMP_TABLE:

.word	_hang
.word	_hang
.word	_hang

.word	clk_sys_epoch
.word	_hang

.word	uart_send
.word	uart_send_string
.word	uart_recv

.word	gpio_set
.word	gpio_fsel

.word	vfb_print
.word	vfb_println
.word	vfb_printf

.word	_hang
.word	_hang

/*****************************************************************************/


.section .text


@ _swi
@ SWI handler.
.globl _swi
_swi:
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

	CMP	R4, #SWI_MAX			@ Check for valid SWI OP code
	BHI	_swi_unknown			@ Invalid SWI routine

	LDR	R5, =_SWI_JUMP_TABLE		@ Load SWI routines table
	LDR	PC, [R5, R4, LSL #2]		@ Load SWI OP

 _swi_end:
	POP	{R4}				@ Restore SPSR
	MSR	SPSR_c, R4			@
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
