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


.set	IRQ_BASIC_PENDING,	0x0
.set	IRQ_PENDING_1,		0x4
.set	IRQ_PENDING_2,		0x8
.set	IRQ_ENABLE_1,		0x10
.set	IRQ_ENABLE_2,		0x14
.set	IRQ_ENABLE_BASIC,	0x18
.set	IRQ_DISABLE_1,		0x1C
.set	IRQ_DISABLE_2,		0x20
.set	IRQ_DISABLE_BASIC,	0x24

.set	FIQ_CONTROL,		0xC

.set	IRQ_CLK_SYS_0,	(1<<0)
.set	IRQ_CLK_SYS_1,	(1<<1)
.set	IRQ_CLK_SYS_2,	(1<<2)
.set	IRQ_CLK_SYS_3,	(1<<3)
