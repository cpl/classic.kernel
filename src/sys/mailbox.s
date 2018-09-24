.include "board/base.s"


.section .text


@ mb_write (data, channel)
@ Writes the input data R0, at the index of the mailbox R1.
.globl mb_write
mb_write:
	TST	R0, #0b1111		@ Validate input
	MOVNE	PC, LR			@ Exit if not valid
	CMP	R1, #0b1111		@ Validate channel
	MOVHI	PC, LR			@ Exit if out of range

	LDR	R2, =MAILBOX_BASE	@ Load mailbox base address

 _mb_write_wait:
	LDR	R3, [R2, #0x18]		@ Load mailbox status
	TST	R3, #0x80000000		@ Check if write is available
	BNE	_mb_write_wait		@ Recheck if not

	ADD	R0, R1			@ Append channel to input data
	STR	R0, [R2, #0x20]		@ Write

	MOV	PC, LR			@ Return


@ mailoxRead (channel) -> data
@ Reads the data from the mailbox specified channel.
.globl mb_read
mb_read:
	CMP	R0, #15			@ Validate channel
	MOVHI	PC, LR			@ Exit if out of range

	LDR	R1, =MAILBOX_BASE	@ Load mailbox address

 _mb_read_wait:
	LDR	R2, [R1, #0x18]		@ Load mailbox status
	TST	R2, #0x40000000		@ Check if read is available
	BNE	_mb_read_wait		@ Recheck if not

	LDR	R2, [R1]		@ Read mailbox
	AND	R3, R2, #0b1111		@ Validate channel
	TEQ	R3, R0			@
	BNE	_mb_read_wait		@ Retry if invalid

	BIC	R0, R2, #0xF		@ Move answer to top 28 bits

	MOV	PC, LR			@ Return
