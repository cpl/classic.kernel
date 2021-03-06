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
.include "board/irq.s"
.include "asm/psr.s"


.section .rodata


_str_irq_enter:		.asciz	"IRQ: ENTER\n\r"
_str_irq_exit:		.asciz	"IRQ: EXIT\n\r"


.section .text


@ irq_cpsr_enable
@ Enable IRQ in current PSR mode.
.globl irq_cpsr_enable
irq_cpsr_enable:
	MRS	R0, CPSR			@ Read  CPSR
	BIC	R0, #(PSR_IRQ)			@ Clear IRQ bit to enable IRQ
	MSR	CPSR_c, R0			@ Write CPSR
	BX	LR				@ Return


@ irq_cpsr_disable
@ Enable IRQ in current PSR mode.
.globl irq_cpsr_disable
irq_cpsr_disable:
	MRS	R0, CPSR			@ Read  CPSR
	ORR	R0, #(PSR_IRQ)			@ Set IRQ bit to disable IRQ
	MSR	CPSR_c, R0			@ Write CPSR
	BX	LR				@ Return


@ irq
@ IRQ signal.
.globl _irq
_irq:
	SUB	SP, #0x40			@ "Allocate" space on stack
						@ for context struct, 17 words


	STR	LR, [SP, #0x3C]			@ Save PC+4
	STMIA	SP, {R0-R12}			@ Save general registers

	MRS	R0, SPSR			@
	STR	R0, [SP, #0x40]			@ Save status register

	BL	irq_handler			@ Handle interrupts

	LDR	R0, [SP, #0x40]			@ Load and set SPSR
	MSR	SPSR, R0			@

	LDR	LR, [SP, #0x3C]			@ Load PC+4
	LDMIA	SP, {R0-R12}			@ Load general registers

	ADD	SP, #0x40			@ Reset stack space from
						@ context struct

	SUBS	PC, LR, #4			@ Return from exception


@ irq_handler
@ The interrupts handler checks which interrupt bits are active and runs the
@ assigned service routine.
irq_handler:
	PUSH	{R0, R4, R5, LR}

	LDR	R5, =INTERRUPTS_BASE		@ Load IRQ base

	LDR	R4, [R5, #IRQ_BASIC_PENDING]	@ Load IRQ pending (ARM CLK)

	TST	R4, #IRQ_CLK_ARM		@ Check for timer interrupt
	BLNE	clk_arm_isr			@ Handle    timer interrupt

	LDR	R4, [R5, #IRQ_PENDING_1]	@ Load IRQ PENDING (SYS CLK)

	TST	R4, #2				@ Tick the scheduler
	BLNE	sched_tick			@

	@ TST	R4, #2				@ Handle timer interrupt
	@ LDRNE	R0, =200000
	@ BLNE	clk_sys_isr			@


	POP	{R0, R4, R5, PC}		@ Return
