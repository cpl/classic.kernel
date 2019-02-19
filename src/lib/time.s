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


.section .text


@ wait (microseconds)
@ Waits the specified number of microseconds in R0, before returning.
@ [DEBUG ONLY]
.globl wait
wait:
	PUSH	{R4, LR}

	MOV	R4, R0			@ Save delay
	BL	clk_sys_epoch		@ Get  starting time
	ADD	R4, R0			@ Save end time (starting time + delay)

 _wait:
	BL	clk_sys_epoch		@ Get current time
	CMP	R0, R4			@ Check if delay passed
	BLS	_wait			@ Recheck if not

	POP	{R4, PC}		@ Return
