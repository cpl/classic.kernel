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


#ifndef _INC_MMAP_H
#define _INC_MMAP_H

#define _SYS_PAGE_SHFT      12
#define _SYS_PAGE_SIZE      (1<<_SYS_PAGE_SHFT)
#define _SYS_SECT_SHFT      20
#define _SYS_SECT_SIZE      (1<<_SYS_SECT_SHFT)

#define _GPU_PHYS_MEM       0x04000000
#define _SYS_PHYS_MEM       (0x20000000 - _GPU_PHYS_MEM)
#define _SYS_PAGE_TTL       (_SYS_PHYS_MEM/_SYS_PAGE_SIZE)

#define _KNL_PHYS_MEM       0x00100000
#define _KNL_PHYS_START     0x00000000

#define _USR_PHYS_MEM       (_SYS_PHYS_MEM - _KNL_PHYS_MEM)
#define _USR_PAGE_TTL       (_USR_PHYS_MEM/_SYS_PAGE_SIZE)
#define _USR_VIRT_START     0x10000000
#define _USR_PHYS_START     (_KNL_PHYS_START + _KNL_PHYS_MEM)

void* mmap_aloc_page(void);
void  mmap_free_page(void* page_addr);

#endif
