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


#include "types.h"


#ifndef _INC_MMU_H
#define _INC_MMU_H

extern void mmu_enable(void* base, u32 flags);
extern void mmu_disable(void);
extern void mmu_invalidate_tlb(void);

extern void mmu_section(void* virt, void* phys, u32 flags);
extern void mmu_coarse (void* virt, void* base);
extern void mmu_page(void* virt, void* phys, u32 flags, void* base);

#endif
