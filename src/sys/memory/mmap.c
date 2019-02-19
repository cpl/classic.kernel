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


#include "types.h"
#include "mmap.h"
#include "memutil.h"
#include "error.h"


static u8  MMAP_PHYS_PAGES[MM_PAGES_TTL] = {0,};
static u32 MMAP_FREE_PP  = 0;
static u32 MMAP_ALOC_PAGE_COUNT = 0;


u32 mmap_get_aloc_memory() {
    return MMAP_ALOC_PAGE_COUNT<<MM_PAGE_SHIFT;
}


void* mmap_aloc_page() {
    for(u32 index = MMAP_FREE_PP; index < MM_PAGES_TTL; index++)
        if(MMAP_PHYS_PAGES[index] == 0) {
            MMAP_PHYS_PAGES[index] = 1;
            MMAP_FREE_PP = index+1;
            MMAP_ALOC_PAGE_COUNT++;

            memzero((void*)(MM_PHYS_KNL+(index<<MM_PAGE_SHIFT)), MM_PAGE_SIZE);

            return (void*)(MM_PHYS_KNL+(index<<MM_PAGE_SHIFT));
        }

    _panic("mmap_aloc_page() failed to find free page.");

    return NULL;
}


void mmap_free_page(void* addr) {
    u32 index = ((u32)addr-MM_PHYS_KNL)>>MM_PAGE_SHIFT;

    MMAP_PHYS_PAGES[index] = 0;
    MMAP_ALOC_PAGE_COUNT--;

    if(index < MMAP_FREE_PP)
        MMAP_FREE_PP = index;
}
