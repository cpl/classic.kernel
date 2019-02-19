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


.set	MMU_ENABLE,			(1<<0)
.set	MMU_CACHE,			(1<<2)
.set	MMU_CACHE_INS,			(1<<12)
.set	MMU_UNALIGNED,			(1<<22)


.set	MMU_COARSE,			1
.set	MMU_SECTION,			2

.set	MMU_PAGE_L,			1
.set	MMU_PAGE_S,			2


.set	VMSA_B,				(1<<2)
.set	VMSA_C,				(1<<3)
.set	VMSA_CACHEABLE,			VMSA_C
.set	VMSA_BUFFERABLE,		VMSA_B

.set	VMSA_AP,			(3<<10)

.set	VMSA_AP_XX_XX,			(0<<10)
.set	VMSA_AP_RW_XX,			(1<<10)
.set	VMSA_AP_RW_RX,			(2<<10)
.set	VMSA_AP_RW_RW,			(3<<10)
