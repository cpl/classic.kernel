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

.set	GPIO_BANK_0,		GPIO_BASE+0
.set	GPIO_BANK_1,		GPIO_BASE+4

.set	GPIO_GPFSEL0,		0x0
.set	GPIO_GPFSEL1,		0x4
.set	GPIO_GPFSEL2,		0x8
.set	GPIO_GPFSEL3,		0xC
.set	GPIO_GPFSEL4,		0x10
.set	GPIO_GPFSEL5,		0x14
.set	GPIO_GPSET0,		0x1C
.set	GPIO_GPSET1,		0x20
.set	GPIO_CLR0,		0x28
.set	GPIO_CLR1,		0x2C
.set	GPIO_GPPUD,		0x94
.set	GPIO_GPPUDCLK0,		0x98
.set	GPIO_GPPUDCLK1,		0x9C
