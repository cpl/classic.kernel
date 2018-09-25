.include "board/base.s"
.include "board/irq.s"
.include "psr.s"


.section .text


@ irq_psr_enable
@ Enable IRQ in current PSR mode.
.globl irq_psr_enable
irq_psr_enable:
	MRS	R0, CPSR			@ Read  CPSR
	BIC	R0, #(PSR_IRQ)			@ Clear IRQ bit to enable IRQ
	MSR	CPSR_c, R0			@ Write CPSR
	MOV	PC, LR				@ Return

@ irq
@ IRQ signal.
.globl _irq
_irq:
	PUSH	{R0-R12, LR}			@ Save registers
	BL	irq_handler			@ IRQ Handler
	POP	{R0-R12, LR}			@ Load registers
	SUBS	PC, LR, #4			@ Resume


@ irq_handler
@ The interrupts handler checks which interrupt bits are active and runs the
@ assigned service routine.
irq_handler:
	PUSH	{LR}

	@ DEBUG

	@ LOAD PENDING IRQ
	@ TST  IRQ
	@ GOTO ISR
	@ TST  IRQ
	@ GOTO ISR
	@ ...
	@ Exit

	@ TST CLK IRQ
	BL	clk_arm_isr

	POP	{PC}				@ Return
