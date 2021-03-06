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


.include "asm/psr.s"
.include "asm/gpio.s"


.section .init


.globl _reset
_reset:

	LDR	R0, =_start			@ Move entry point from 0x8000
	LDR	R1, =_start_end			@ to 0x0000 where the ARM CPU
	SUB	R1, R1, R0			@ expects them to be after a
	MOV	R2, #0				@ restart. On the first run the
	BL	kmemcopy			@ GPU enters at 0x8000 (_start)

	LDR	R0, =_bss_start			@ Zero BSS memory zone
	LDR	R1, =_bss_end			@
	SUB	R1, R1, R0			@
	BL	kmemzero			@

	MOV	R1, #0x80000000			@ Stack pointers storage
	@ MOV	R1, #0				@

	MOV	R0, #(PSR_MODE_SVC|PSR_IRQ|PSR_FIQ)	@ SVC, DISABLE:
	MSR	CPSR_c, R0				@ IRQ & FIQ
	ADD	SP, R1, #0x2400				@ Set stack to 0x2400

	BL	kheap_init				@ Initialize knl heap

	MOV	R0, #(PSR_MODE_ABT|PSR_IRQ|PSR_FIQ)	@ ABT, DISABLE:
	MSR	CPSR_c, R0				@ IRQ & FIQ
	ADD	SP, R1, #0x2800				@ Set stack to 0x2800

	MOV	R0, #(PSR_MODE_IRQ|PSR_IRQ|PSR_FIQ)	@ IRQ, DISABLE:
	MSR	CPSR_c, R0				@ IRQ & FIQ
	ADD	SP, R1, #0x2C00				@ Set stack to 0x2C00

	MOV	R0, #(PSR_MODE_SYS|PSR_IRQ|PSR_FIQ)	@ SYS, DISABLE:
	MSR	CPSR_c, R0				@ IRQ & FIQ
	ADD	SP, R1, #0x3C00				@ Set stack to 0x3C00

							@ Stay in SYS MODE

	LDR	R0, =_USR_LOAD				@ Load clslib from
	LDR	R1, =_USR_SIZE				@ its load address
	LDR	R2, =0x1000000				@ to user space
	BL	kmemcopy

	BL	csudUsbInitialise			@ Initialize CSUD USB

	B	sys_init				@ Initialize system
							@ - LED
							@ - UART
							@ - Framebuffer
							@ - ARM Clock
							@ - Interrupts
							@ - MMU
