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


.include "board/base.s"


.section .text


@ mb_write (channel, data)
@ Writes from the buffer R1 to channel R0.
.globl mb_write
mb_write:
	TST	R1, #0b1111		@ Validate input
	MOVNE	PC, LR			@ Exit if not valid
	CMP	R0, #0b1111		@ Validate channel
	MOVHI	PC, LR			@ Exit if out of range

	LDR	R2, =MAILBOX_BASE	@ Load mailbox base address

 _mb_write_wait:
	LDR	R3, [R2, #0x18]		@ Load mailbox status
	TST	R3, #0x80000000		@ Check if write is available
	BNE	_mb_write_wait		@ Recheck if not

	ADD	R0, R1			@ Append channel to input data
	STR	R0, [R2, #0x20]		@ Write

	MOV	PC, LR			@ Return


@ mb_read (channel) -> data
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
