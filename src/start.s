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


.section .init


.globl _start
_start:

	LDR	PC, sig_reset
	LDR	PC, sig_undef
	LDR	PC, sig_swi
	LDR	PC, sig_prefc
	LDR	PC, sig_datah
	LDR	PC, sig_undef
	LDR	PC, sig_irq
	LDR	PC, sig_fiq

	B	_hang

sig_reset:	.word _reset
sig_undef:	.word _hang
sig_swi:	.word _swi
sig_prefc:	.word _hang
sig_datah:	.word _hang
sig_unuse:	.word _hang
sig_irq:	.word _hang
sig_fiq:	.word _hang

.globl _start_end
_start_end:
