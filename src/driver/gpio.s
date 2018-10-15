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


.include "board/gpio.s"
.include "asm/gpio.s"


.section .text

@ gpio_fsel (gpio_pin, gpio_cmd)
@ Selects a function (lower 3 bits of R1) for register with ID (R0).
.globl gpio_fsel
gpio_fsel:
	CMP	R0, #MAX_GPIO_PIN	@ Check that the PIN is 0-53
	CMPLS	R1, #MAX_GPIO_CMD	@ Check that the CMD is 0-7
	BXHI	LR			@ Exit if not

	PUSH	{R4-R5, LR}

	MOV	R4, R1			@ R4 = CMD
	MOV	R1, #10			@ R0 = PIN / 10
	BL	math_div		@ R1 = PIN % 10

	ADD	R1, R1, R1, LSL #1	@ R1 = (PIN % 10) * 3
	LSL	R4, R4, R1		@ R4 = CMD << R1

	LDR	R5, =GPIO_BASE		@ Load GPIO address

	LDR	R2, [R5, R0, LSL #2]	@ Load PIN

	MOV	R3, #0b111		@ Load 3 bits
	BIC	R2, R2, R3, LSL R1	@ Clear  bits
	ORR	R4, R4, R2		@ Update bits

	STR	R4, [R5, R0, LSL #2]	@ Save PIN

	POP	{R4-R5, PC}		@ Return


@ gpio_set (gpio_pin, status)
@ Sets the GPIO PIN (R0), ON if R1==1, OFF if R1==0.
.globl gpio_set
gpio_set:
	CMP	R0, #MAX_GPIO_PIN	@ Check that the PIN is 0-53
	BXHI	LR			@ Exit if not

	CMP	R0, #31			@ Select register bank
	LDRLS	R2, =GPIO_BANK_0	@ 0
	LDRHI	R2, =GPIO_BANK_1	@ 4

	AND	R0, R0, #0b11111	@ PIN % 31

	MOV	R3, #1			@ Set bit
	LSL	R0, R3, R0		@

	TEQ	R1, #0			@ Check for ON or OFF
	STRNE	R0, [R2, #40]		@ ON
	STREQ	R0, [R2, #28]		@ OFF

	BX	LR			@ Return
