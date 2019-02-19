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


.set	MMU_BASE,		0x4000
.set	PERIPHERALS_BASE,	0x20000000

.set	GPIO_BASE,	    	PERIPHERALS_BASE+0x200000
.set	CLK_SYS_BASE,		PERIPHERALS_BASE+0x3000
.set	CLK_ARM_BASE,		PERIPHERALS_BASE+0xB400
.set	MAILBOX_BASE,		PERIPHERALS_BASE+0xB880
.set	INTERRUPTS_BASE,	PERIPHERALS_BASE+0xB200
.set	AUX_BASE,		PERIPHERALS_BASE+0x215000
.set	BSC_BASE_0,		PERIPHERALS_BASE+0x205000
.set	BSC_BASE_1,		PERIPHERALS_BASE+0x804000
.set	BSC_BASE_2,		PERIPHERALS_BASE+0x805000
