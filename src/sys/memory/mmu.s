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
.include "mmu.s"


.section .text


@ mmu_enable (mmu_base, mmu_flags)
@ Enable the MMU with the specified flags.
.globl mmu_enable
mmu_enable:
	MOV	R2, #0
	MCR	P15, 0, R2, C7, C7, 0		@ Invalidate Caches
	MCR	P15, 0, R2, C8, C7, 0		@ Invalidate TLB
	MCR	P15, 0, R2, C7, C10, 4		@ Data Synchronization Barrier

	MVN	R2, #0				@ Reset all domains except
	BIC	R2, #0xC			@ D1 which is set as manager
	MCR	P15, 0, R2, C3, C0, 0		@ Domain Access Control

	MCR	P15, 0, R0, C2, C0, 0		@ Translation Table 0 Base
	MCR	P15, 0, R0, C2, C0, 1		@ Translation Table 1 Base

	MRC	P15, 0, R2, C1, C0, 0		@ Read MMU Control REG
	ORR	R2, R2, R1			@ Enable MMU + Caches
	MCR	P15, 0, R2, C1, C0, 0		@ Set  MMU Control REG

	MOV	PC, LR				@ Return


@ mmu_disable
@ Disable the MMU.
.globl mmu_disable
mmu_disable:
	MRC	P15, 0, R0, C1, C0, 0		@ Read MMU Control REG
	LDR	R1, =(MMU_ENABLE || MMU_CACHE || MMU_CACHE_INS)
	BIC	R0, R0, R1			@ Disable MMU + Caches
	MCR	P15, 0, R0, C1, C0, 0		@ Set  MMU Control REG

	MOV	PC, LR				@ Return


@ mmu_invalidate_tlb
.globl mmu_invalidate_tlb
mmu_invalidate_tlb:
	MOV	R0, #0
	MCR	P15, 0, R0, C8, C7, 0		@ Invalidate TLB
	MCR	P15, 0, R0, C7, C10, 4		@ Data Synchronization Barrier
	MOV	PC, LR				@ Return


@ mmu_section (v_addr, p_addr, flags)
@ Assign a virtual address to a physical address space of 1MB (aka section),
@ using specified flags (R2).
.globl mmu_section
mmu_section:
	LSR	R1, R1, #20			@ Get first 12 bits of
	LSL	R1, R1, #20			@ physical address

	ORR	R2, R2, #0b10			@ MMU_SECTION
	ORR	R1, R1, R2			@ Prepare flags

	LSR	R0, R0, #20			@ Compute MMU TLB first level
	LSL	R0, R0, #2			@ address
	ORR	R0, R0, #MMU_BASE		@

	STR	R1, [R0]			@ Update TLB

	MOV	PC, LR				@ Return

/*

V	= V >> 20
SADR	= MMU_TLB_BASE | (V << 2)
SVAL	= (C & 0xFFFFFC00) | 0b01
STR	SVAL, [SADR]

V	= (V >> 12) & 0xFF
SADR	= (C & 0xFFFFFC00) | (V << 2)
SVAL	= (P & 0xFFFFF000) | AP | F | 2
STR	SVAL, [SADR]

*/


@ mmu_coarse (v_addr, mmu_base)
@ Create the first level lookup for a two level lookup TLB with a coarse page
@ table and then sub-pages (small pages of 4kb).
.globl mmu_coarse
mmu_coarse:
	LSR	R0, R0, #20			@ Compute MMU TLB first level
	LSL	R0, R0, #2			@ address
	ORR	R0, R0, #MMU_BASE		@

	LDR	R2, =0x3FF			@ Align coarse TLB address
	BIC	R1, R1, R2			@ to 1kb
	ORR	R1, R1, #0b01			@ COARSE TLB

	STR	R1, [R0]			@ Update TLB

	MOV	PC, LR				@ Return


@ mmu_page (v_addr, p_addr, flags, mmu_base)
.globl mmu_page
mmu_page:
	PUSH	{R4}

	LSR	R0, R0, #12			@ Get bits 19:12 from virtual
	AND	R0, R0, #0xFF			@ address

	LDR	R4, =0x3FF			@ Align coarse TLB address
	BIC	R3, R3, R4			@ to 1kb
	ORR	R0, R3, R0, LSL #2		@ Coarse TLB 4kb address space

	LDR	R4, =0xFFF			@ Align physical address to 4kb
	BIC	R1, R1, R4			@

	ORR	R2, R2, #0b10			@ SMALL PAGE
	ORR	R1, R1, R2			@ Prepare flags

	STR	R1, [R0]			@ Update coarse TLB

	POP	{R4}				@ Return
	MOV	PC, LR				@


@ mmu_setup
@ Setup memory section to map virtual to physical and uncache peripherals.
.globl mmu_setup
mmu_setup:
	PUSH	{R4-R5, LR}

	LDR	R4, =0xFFF00000			@ End   address
	MOV	R5, #0				@ Start address

 _mmu_setup:
	MOV	R0, R5				@ Map virtual to physical
	MOV	R1, R5				@ with cache and buffer enabled
	LDR	R2, =(VMSA_C | VMSA_B | VMSA_AP_RW_XX)
	BL	mmu_section

	CMP	R5, R4				@ Check for end address
	ADD	R5, #0x00100000			@ Increment address
	BNE	_mmu_setup			@

	LDR	R0, =0x20000000			@ Disable cache and buffer
	MOV	R1, R0				@ for periherals 0x200.. 0x202..
	LDR	R2, =(VMSA_AP_RW_XX)		@
	BL	mmu_section			@
	LDR	R0, =0x20200000			@
	MOV	R1, R0				@
	LDR	R2, =(VMSA_AP_RW_XX)		@
	BL	mmu_section			@

	POP	{R4-R5, PC}			@ Return


@ mmu_init
@ Initialize the MMU TLB, then enable the MMU with custom flags.
.globl mmu_init
mmu_init:
	PUSH	{LR}

	LDR	R0, =MMU_BASE			@ Enable MMU with custom flags
	LDR	R1, =(MMU_ENABLE|MMU_CACHE_INS|MMU_CACHE|MMU_UNALIGNED)
	BL	mmu_enable

	POP	{PC}				@ Return