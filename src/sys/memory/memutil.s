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


@ memzero (*src, len bytes)
@ Takes a source addr, replaces the next 'len' bytes with 0.
.globl memzero
memzero:
	CMP	R1, #0			@ Check for len=0
	MOVEQ	PC, LR			@ Exit

	MOV	R2, #0			@ Prepare zero
	ADD	R1, R0			@ Compute end addr

 _memzero:
	STRB	R2, [R0], #1		@ Zero memory
	CMP	R0, R1			@ Check for end addr
	BNE	_memzero		@ Repeat

	BX	LR			@ Return


@ memcopy (*src, len bytes, *dst)
@ Takes a source addr, copies the first 'len' bytes from *src to *dst.
.globl memcopy
memcopy:
	CMP	R1, #0			@ Check for len==0
	MOVEQ	PC, LR			@ Exit

	CMP	R0, R2			@ Check *src==*dst
	MOVEQ	PC, LR			@ Exit

	ADD	R1, R0			@ Compute end addr

 _memcopy:
	LDRB	R3, [R0], #1		@ Load  byte
	STRB	R3, [R2], #1		@ Store byte
	CMP	R0, R1			@ Check for end
	BNE	_memcopy		@ Repeat

	BX	LR			@ Return


@ memmove (*src, len bytes, *dst)
@ Takes a source addr, copies the first 'len' bytes from *src to *dst replacing
@ the bytes with 0.
.globl memmove
memmove:
	CMP	R1, #0			@ Check for len=0
	MOVEQ	PC, LR			@ Exit

	MOV	R2, #0			@ Prepare zero
	ADD	R1, R0			@ Compute end addr

 _memmove:
	LDRB	R3, [R0]		@ Load  byte
	STRB	R2, [R0], #1		@ Zero  byte
	STRB	R3, [R2], #1		@ Store byte
	CMP	R0, R1			@ Check for end
	BNE	_memmove		@ Repeat

	BX	LR			@ Return
