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


.section .data


_str_arm_mem: .ascii "ARM MEM\n\r\0"


.align 16
_arm_mem_start:
		.int (_arm_mem_end-_arm_mem_start)	/* SIZE */
_rs:		.int 0					/* RESPONSE */

		.int 0x00010006				/* TAG */
		.int 8					/**/
		.int 0					/**/

		.int 0					/**/
		.int 0					/**/

		.int 0					/* END TAG */
_arm_mem_end:


.section .text


.globl arm_mem
arm_mem:

	PUSH	{R4, LR}

	LDR	R0, =_str_arm_mem
	BL	uart_send_string

	LDR	R4, =_arm_mem_start
 _mem_loop_0:

	LDR	R0, =_arm_mem_end
	CMP	R4, R0
	ADDNE	R4, #4
	BNE	_mem_loop_0

	MOV	R0, #8
	LDR	R1, =_arm_mem_start
	ADD	R1, #0x40000000
	BL	mb_write

	MOV	R0, #8
	BL	mb_read

	LDR	R0, =_str_arm_mem
	BL	uart_send_string

	LDR	R4, =_arm_mem_start
 _mem_loop_1:

	LDR	R0, =_arm_mem_end
	CMP	R4, R0
	ADDNE	R4, #4
	BNE	_mem_loop_1


	POP	{R4, PC}
