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


.set	AUX_IRQ,		0x0
.set	AUX_ENABLES,		0x4

.set	AUX_MU_IO_REG,		0x40
.set	AUX_MU_IER_REG,		0x44
.set	AUX_MU_IIR_REG,		0x48
.set	AUX_MU_LCR_REG,		0x4C
.set	AUX_MU_MCR_REG,		0x50
.set	AUX_MU_LSR_REG,		0x54
.set	AUX_MU_MSR_REG,		0x58
.set	AUX_MU_SCRATCH,		0x5C
.set	AUX_MU_CNTL_REG,	0x60
.set	AUX_MU_STAT_REG,	0x64
.set	AUX_MU_BAUD_REG,	0x68
