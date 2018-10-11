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
.include "board/gpio.s"
.include "board/aux.s"
.include "board/irq.s"
.include "asm/ascii.s"


.section .text


@ uart_init
@ Enables the UART receiver and transmitter on GPIO pins 14, 15
.globl uart_init
uart_init:

	LDR	R0, =INTERRUPTS_BASE		@ Disable AUX Interrupts
	MOV	R1, #(1<<29)			@
	STR	R1, [R0, #IRQ_DISABLE_1]	@

	LDR	R0, =AUX_BASE			@ Load UART AUX Base

	MOV	R1, #1
	STR	R1, [R0, #AUX_ENABLES]		@ Enable mini-UART registers

	MOV	R2, #0
	STR	R2, [R0, #AUX_MU_IER_REG]	@ Disable interrupts
	STR	R2, [R0, #AUX_MU_CNTL_REG]	@ Disable RX, RT, flow

	MOV	R1, #3
	STR	R1, [R0, #AUX_MU_LCR_REG]	@ Set 8 bit mode

	STR	R2, [R0, #AUX_MU_MCR_REG]	@ Set RTS to always high
	STR	R2, [R0, #AUX_MU_IER_REG]	@ Disable interrupts

	MOV	R1, #0xC6
	STR	R1, [R0, #AUX_MU_IIR_REG]	@ Disable interrupts

						@ ((250,000,000/115200)/8)-1
	LDR	R1, =270			@     = 270
	STR	R1, [R0, #AUX_MU_BAUD_REG]	@ Set baud rate to 115200


	LDR	R2, =GPIO_BASE			@ Load   GPIO base
	LDR	R1, [R2, #GPIO_GPFSEL1]		@ Load   GPIO value
	BIC	R1, R1, #(7<<12)		@ Clean  GPIO 14
	ORR	R1, R1, #(2<<12)		@ Func 5 GPIO 14
	BIC	R1, R1, #(7<<15)		@ Clean  GPIO 15
	ORR	R1, R1, #(2<<15)		@ Func 5 GPIO 15
	STR	R1, [R2, #GPIO_GPFSEL1]		@ Update GPIO register


	MOV	R1, #3
	STR	R1, [R0, #AUX_MU_CNTL_REG]	@ Enable receiver, transmitter

	BX	LR				@ Return


@ uart_recv -> R0
@ Receive a byte from the mini-UART interface and place it in R0.
.globl uart_recv
uart_recv:
	LDR	R0, =AUX_BASE			@ Load AUX base

 _uart_recv:
	LDRB	R1, [R0, #AUX_MU_LSR_REG]	@ Load status REG
	TST	R1, #0x1			@ Check receiver empty
	BEQ	_uart_recv			@ Recheck

	LDRB	R0, [R0, #AUX_MU_IO_REG]	@ Read

	BX	LR				@ Return


@ uart_send (byte)
@ Sends the value (R0) to the mini-UART interface.
.globl uart_send
uart_send:
	LDR	R1, =AUX_BASE			@ Load AUX base

 _uart_send:
	LDRB	R2, [R1, #AUX_MU_LSR_REG]	@ Load status REG
	TST	R2, #0x20			@ Check transmitter empty
	BEQ	_uart_send			@ Recheck

	STRB	R0, [R1, #AUX_MU_IO_REG]	@ Write

	BX	LR				@ Return


@ uart_send_string (*str)
@ Sends a 0 terminated string via the mini-UART interface.
.globl uart_send_string
uart_send_string:
	PUSH	{R4, LR}

	MOV	R4, R0				@ Save string pointer

 _uart_send_string:
	LDRB	R0, [R4], #1			@ Load char
	CMP	R0, #ASCII_NUL			@ Check for NULL terminator
	POPEQ	{R4, PC}			@ Exit if NULL terminator
	BL	uart_send			@ Send char otherwise
	B	_uart_send_string		@ Repeat


@ uart_clrf
@ Send line feed and carriage return to mini-UART interface.
.globl uart_clrf
uart_clrf:
	PUSH	{LR}

	MOV	R0, #ASCII_LF			@ Send Line Feed
	BL	uart_send			@

	MOV	R0, #ASCII_CR			@ Send Carriage Return
	BL	uart_send			@

	POP	{PC}				@ Return
