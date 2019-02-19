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

/* mmu.h - Memory Management Unit

*/


#ifndef _INC_MMU_H
#define _INC_MMU_H

#include "types.h"

void mmu_invalidate_tlb(void);
void mmu_coarse(void* virt_addr, void* mmu_base);
void mmu_page(void* virt_addr, void* phys_addr, u32 flags, void* mmu_base);

#endif
