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


/*

void memcpy (void* src, void* dst, u32 len)
	if (src < dst)
		// normal memcpy
	if ()


*/


.section .text


@ void memzero (void* src, u32 len)
@ Takes a source addr, replaces the next 'len' bytes with 0.
.globl memzero
memzero:
	MOV	R2, #0			@ Set value to 0
	B	memsetb			@ Set memory


@ memcopy (void* src, u32 len, void* dst)
@ Takes a source addr, copies the first 'len' bytes from src to dst.
.globl memcopy
memcopy:
	TEQ	R1, #0			@ Check invalid arguments
	TEQNE	R0, R2			@
	BXEQ	LR			@

	ADD	R3, R0, R1		@ R3 = src+len
	CMP	R2, R3			@ if (src+len) > dst
	BHI	_memcopy_0		@  special case
	ADD	R1, R0			@ else
	B	_memcopy_1		@  normal  case

 _memcopy_0:
	LDRB	R3, [R0, R2]		@ Load byte from src + len
	STRB	R3, [R1, R2]		@ Save byte at   dst + len
	SUBS	R3, #1			@ Decrement len
	BNE	_memcopy_0		@ Check for end, repeat
	BX	LR			@ Return

 _memcopy_1:
	LDRB	R3, [R0], #1		@ Load byte from src
	STRB	R3, [R2], #1		@ Save byte at   dst
	CMP	R0, R1			@ Check for end
	BNE	_memcopy_1		@ Repeat
	BX	LR			@ Return


@ void memmove (*src, len bytes, *dst)
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


@ void memsetb (void* addr, u32 len, u8 value)
@ Set the next `len` bytes to to value.
.globl memsetb
memsetb:
	TEQ	R0, #0			@ Check for invalid arguments
	TEQNE	R1, #0			@
	TEQNE	R2, #0			@
	BXEQ	LR			@

	TST	R0, #2			@ Check if 4 byte aligned
	LSREQ	R1, #2			@ Transform byte len to word len
	ORREQ	R2, R2, R2, LSL #8	@ Fill word with 4xbyte
	ORREQ	R2, R2, R2, LSL #16	@
	BEQ	_memsetw		@ Fill space as words

	TST	R0, #1			@ Check if 2 byte aligned
	LSREQ	R1, #1			@ Transform byte len to hword len
	ORREQ	R2, R2, R2, LSL #8	@ Fill hword with 2xbyte
	BEQ	_memseth		@ Fill space as words

 _memsetb:
	STRB	R2, [R0], #1		@ Write byte
	SUBS	R1, #1			@ Decrement
	BNE	_memsetb		@ Repeat
	BX	LR			@ Return


@ void memseth (void* addr, u32 len, u16 value)
@ Set the next `len` hwords to to value.
.globl memseth
memseth:
	TEQ	R0, #0			@ Check for invalid arguments
	TEQNE	R1, #0			@
	TEQNE	R2, #0			@
	BXEQ	LR			@

	TST	R0, #2			@ Check if 4 byte aligned
	LSREQ	R1, #1			@ Transform hword len to word len
	ORREQ	R2, R2, R2, LSL #16	@ Fill word with 2xhword
	BEQ	_memsetw		@ Fill space as words

 _memseth:
	STRH	R2, [R0], #2		@ Write hword
	SUBS	R1, #1			@ Decrement
	BNE	_memseth		@ Repeat
	BX	LR			@ Return

	BX	LR			@ Return


@ void memsetw (void* addr, u32 len, u32 value)
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
