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


.section .text


@ math_div (dividend, divisor) -> (quotient, remainder)
@ Does divison R0 / R1, returning R0 = R0/R1, R1 = R0%R1.
.globl math_div
math_div:
	MOV	R2, #0			@ Reset accumulator
	MOV	R3, #32			@ Number of bit divisions
	ADDS	R0, R0, R0		@ Shift dividend
 _math_div:
	ADC	R2, R2, R2		@ Shift accumulator, w carry
	CMP	R2, R1			@ Does it go?
	SUBHS	R2, R2, R1		@ if not, substract
	ADCS	R0, R0, R0		@ Shift dividend and accumulator
	SUB	R3, R3, #1		@ Decrement loop count
	TST	R3, R3			@ Leave carry
	BNE	_math_div		@ Loop

	MOV	R1, R2			@ Move remainder in R1 for return
					@ R0 holds the quotient

	BX	LR			@ Return
