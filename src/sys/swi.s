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


.include "swi.s"


.section .rodata
_str_swi_unknown:	.ascii "SWI UNKOWN\n\r\0"
_str_swi_test:		.ascii "SWI WORKS!\n\r\0"


.align 4
_SWI_TABLE:
.word	swi_test


.section .text


swi_test:
	PUSH	{LR}				@ DEBUG
	LDR	R0, =_str_swi_test		@
	BL	uart_send_string		@
	POP	{PC}				@


@ _swi
@ SWI signal.
.globl _swi
_swi:
	PUSH	{R4-R5, LR}

	MRS	R5, SPSR			@ Save current mode
	PUSH	{R5}				@

	LDR	R4, [LR, #-4]			@ Extract SWI OP code
	BIC	R4, #0xFF000000			@

	LDR	LR, =_swi_end			@ Prepare return to end routine

	CMP	R4, #SWI_MAX			@ Check for valid SWI OP code
	BHI	_swi_unknown			@ Invalid SWI routine

	LDR	R5, =_SWI_TABLE			@ Load SWI routines table
	LDR	PC, [R5, R4, LSL #2]		@ Load SWI OP

 _swi_end:
	POP	{R5}				@ Return initial mode
	MSR	SPSR_c, R5			@ Set mode to initial mode

	POP	{R4-R5, LR}			@ Return registers
	MOVS	PC, LR				@ Exit SWI

_swi_unknown:
	PUSH	{R0-R3, LR}			@ Save R0-R3

	LDR	R0, =_str_swi_unknown		@ Display error msg over UART
	BL	uart_send_string		@ DEBUG

	POP	{R0-R3, PC}			@ Return
