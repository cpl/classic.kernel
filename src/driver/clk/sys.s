/*
   Copyright 2018-2019 Alexandru-Paul Copil

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
.include "board/clk.s"


.section .text


@ clk_sys_epoch -> (lower 32, upper 32)
@ Returns the current timestamp of the clock inside R0 & R1.
.globl clk_sys_epoch
clk_sys_epoch:
	LDR	R0, =CLK_SYS_BASE		@ Get timer address
	LDRD	R0, R1, [R0, #CLK_SYS_CLO]	@ Get timer value (64 bits)
	BX	LR				@ Return
