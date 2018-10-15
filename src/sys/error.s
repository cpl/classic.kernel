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


.section .rodata


_str_undef:		.asciz "ERR: UNDEF INS\n\r"
_str_abort_ins:		.asciz "ERR: ABORT INS\n\r"
_str_abort_dat:		.asciz "ERR: ABORT DAT\n\r"


.section .text


@ _undef
.globl _undef
_undef:
	LDR	R0, =_str_undef
	BL	uart_send_string

	B	_hang
	@ MOVS	PC, LR			@ Return


@ _abort_ins
.globl _abort_ins
_abort_ins:
	LDR	R0, =_str_abort_ins
	BL	uart_send_string

	B	_hang
	@ MOVS	PC, LR			@ Return


@ _abort_dat
.globl _abort_dat
_abort_dat:
	LDR	R0, =_str_abort_dat
	BL	uart_send_string

	B	_hang
	@ SUBS	PC, LR, #4		@ Return
