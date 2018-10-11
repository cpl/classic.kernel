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


@ memsetb (void* addr, u32 len, u8 value)
@ Set the next `len` bytes to to value.
.globl memsetb
memsetb:
	TEQ	R0, #0			@ Check for invalid arguments
	TEQNE	R1, #0			@
	TEQNE	R2, #0			@
	BXEQ	LR			@

 _memsetb:
	STRB	R2, [R0], #1		@ Write byte
	SUBS	R1, #1			@ Decrement
	BNE	_memsetb		@ Repeat
	BX	LR			@ Return


@ memseth (void* addr, u32 len, u16 value)
@ Set the next `len` hwords to to value.
.globl memseth
memseth:
	TEQ	R0, #0			@ Check for invalid arguments
	TEQNE	R1, #0			@
	TEQNE	R2, #0			@
	BXEQ	LR			@

 _memseth:
	STRH	R2, [R0], #2		@ Write hword
	SUBS	R1, #1			@ Decrement
	BNE	_memseth		@ Repeat
	BX	LR			@ Return

	BX	LR			@ Return


@ memsetw (void* addr, u32 len, u32 value)
@ Set the next `len` words to to value.
.globl memsetw
memsetw:
	TEQ	R0, #0			@ Check for invalid arguments
	TEQNE	R1, #0			@
	TEQNE	R2, #0			@
	BXEQ	LR			@

 _memsetw:
	STR	R2, [R0], #4		@ Write hword
	SUBS	R1, #1			@ Decrement
	BNE	_memsetw		@ Repeat
	BX	LR			@ Return

	BX	LR			@ Return
