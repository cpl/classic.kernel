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

void* mmap_get_page(void);
void  mmap_free(void* addr);

#define _SYS_PAGE_SHFT      12
#define _SYS_PAGE_SIZE      (1<<_SYS_PAGE_SHFT)

#define _KNL_PHYS_MEM       0x00A00000
#define _SYS_PHYS_MEM       0x20000000
#define _GPU_PHYS_MEM       0x04000000

#define _USR_PHYS_MEM       (_SYS_PHYS_MEM - _KNL_PHYS_MEM - _GPU_PHYS_MEM)
#define _USR_PAGE_MAX       (_USR_PHYS_MEM/_SYS_PAGE_SIZE)
#define _USR_VIRT_START     0x10000000

#endif
