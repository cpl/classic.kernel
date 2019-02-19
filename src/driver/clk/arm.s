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


.include "board/base.s"
.include "board/clk.s"
.include "board/irq.s"


.section .text


@ clk_arm_epoch -> (value)
@ Return the ARM timer value in R0. Use only for debug, for the system time
@ use `clk_sys_epoch() -> (R0, R1)`
.globl clk_arm_epoch
clk_arm_epoch:
	LDR	R0, =CLK_ARM_BASE		@ Load timer base
	LDR	R0, [R0, #CLK_ARM_VAL]		@ Load timer value
	BX	LR				@ Return


@ clk_arm_init
@ Setup the ARM Local Timer.
.globl clk_arm_init
clk_arm_init:

	MOV	R1, #1				@ Disable ARM CLK basic IRQ
	LDR	R2, =INTERRUPTS_BASE		@
	STR	R1, [R2, #IRQ_DISABLE_BASIC]	@

	LDR	R0, =CLK_ARM_BASE		@ Load timer base

	@ MOV	R1, #0x003E0000			@ Set pre-scalar
	@ STR	R1, [R0, #CLK_ARM_CTL]		@

	LDR	R1, =0x400			@ Set timer load and reload
	STR	R1, [R0, #CLK_ARM_LOD]		@
	STR	R1, [R0, #CLK_ARM_RLD]		@

	MOV	R1, #0xF9			@ Set pre-divider
	STR	R1, [R0, #CLK_ARM_DIV]		@
	MOV	R1, #0				@ Clear interrupts
	STR	R1, [R0, #CLK_ARM_CLI]		@

	MOV	R1, #1				@ Enable ARM CLK basic IRQ
	LDR	R2, =INTERRUPTS_BASE		@
	STR	R1, [R2, #IRQ_ENABLE_BASIC]	@

	LDR	R1, =0x000000AA			@ Enable timer with interrupts
	STR	R1, [R0, #CLK_ARM_CTL]		@

	BX	LR				@ Return


@ clk_arm_isr
@ Handle IRQ for ARM Local Timer.
.globl clk_arm_isr
clk_arm_isr:
	PUSH	{LR}

	LDR	R0, =CLK_ARM_BASE		@ Load  IRQ Clear REG
	MOV	R1, #0				@ Clear IRQ
	STR	R1, [R0, #CLK_ARM_CLI]		@

	POP	{PC}				@ Return
