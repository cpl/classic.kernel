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
	CMP	R1, #0			@ Check invalid arguments
	BXEQ	LR			@

	CMP	R2, R0			@ If src > dst
	ADDHI	R0, R1			@  dst += len
	ADDHI	R2, R1			@  src += len
	BHI	_memcopy_1		@

 _memcopy_0:				@ Bottom to top
	LDRB	R3, [R0], #1		@ dst++ = src++
	STRB	R3, [R2], #1		@
	SUBS	R1, #1			@ while (len-- > 0)
	BNE	_memcopy_0		@   repeat
	BX	LR			@ Return

 _memcopy_1:				@ Top to bottom
	LDRB	R3, [R0, #-1]!		@ --dst = --src
	STRB	R3, [R2, #-1]!		@
	SUBS	R1, #1			@ while (len-- > 0)
	BNE	_memcopy_1		@   repeat
	BX	LR			@ Return


@ void memsetb (void* addr, u32 len, u8 value)
@ Set the next `len` bytes to to value.
.globl memsetb
memsetb:
	TEQ	R1, #0			@ Check for invalid arguments
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
	TEQ	R1, #0			@ Check for invalid arguments
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
	TEQ	R1, #0			@ Check for invalid arguments
	BXEQ	LR			@

 _memsetw:
	STR	R2, [R0], #4		@ Write hword
	SUBS	R1, #1			@ Decrement
	BNE	_memsetw		@ Repeat
	BX	LR			@ Return

	BX	LR			@ Return
