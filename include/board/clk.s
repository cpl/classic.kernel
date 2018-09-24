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


@ SYS CLOCK

.set	CLK_SYS_CS,		0x0		@ Control/Status
.set	CLK_SYS_CLO,		0x4		@ Clock (lower  32 bits)
.set	CLK_SYS_CHI,		0x8		@ Clock (higher 32 bits)
.set	CLK_SYS_C0,		0xC		@ Compare 0
.set	CLK_SYS_C1,		0x10		@ Compare 1
.set	CLK_SYS_C2,		0x14		@ Compare 2
.set	CLK_SYS_C3,		0x18		@ Compare 3

.set	CLK_SYS_M0,		(1<<0)
.set	CLK_SYS_M1,		(1<<1)
.set	CLK_SYS_M2,		(1<<2)
.set	CLK_SYS_M3,		(1<<3)

@ ARM CLOCK

.set	CLK_ARM_LOD,		0x0		@ Load
.set	CLK_ARM_VAL,		0x4		@ Value
.set	CLK_ARM_CTL,		0x8		@ Control
.set	CLK_ARM_CLI,		0xC		@ IRQ Clear/Ack
.set	CLK_ARM_RIS,		0x10		@ RAW IRQ
.set	CLK_ARM_MIS,		0x14		@ Masked IRQ
.set	CLK_ARM_RLD,		0x18		@ Reload
.set	CLK_ARM_DIV,		0x1C		@ Pre-divider
.set	CLK_ARM_CNT,		0x20		@ Free running counter
