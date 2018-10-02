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



.section .data


.align 4
_rand_seed:	.word	0xDEADBEEF


.section .text


@ rand_init
@ Initialize and seed the random number generator library.
.globl rand_init
rand_init:
	PUSH	{R4, LR}

	BL	clk_sys_epoch		@ Get system clock timestamp
	MOV	R4, R0			@

	BL	clk_arm_epoch		@ Get arm    clock timestamp
	MUL	R0, R4, R0		@ Multiply the two timestamps

	LDR	R1, =_rand_seed		@ Update random seed
	STR	R0, [R1]		@

	POP	{R4, PC}		@ Return
