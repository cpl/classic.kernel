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
#include "mmap.h"
#include "sched.h"
#include "mmu.h"
#include "error.h"
#include "memutil.h"


static u32 mmap_free_index = 0;
static u8  mmap_phys_pages[_USR_PAGE_TTL] = {0,};


void* mmap_aloc_page(void) {
    // Iterate physical pages from "free probable index", until a free page
    for(register u32 index = mmap_free_index; index < _USR_PAGE_TTL; index++) {
        // Check if page is free
        if(mmap_phys_pages[index] == 0) {
            // Set page as allocated
            mmap_phys_pages[index]  = 1;
            // Set "free probable index" to next index
            mmap_free_index = index + 1;

            // Clean page memory
            memzero(
                (void*)(_USR_PHYS_START+(index << _SYS_PAGE_SHFT)),
                _SYS_PAGE_SIZE);

            // Return physical addres of page
            return (void*)(_USR_PHYS_START+index);
        }
    }

    // Fail to find free page, panic
    _panic(); return NULL;
}


void mmap_free_page(void* page_addr) {
    // Extract index from physical address of page
    register u32 index = (u32)page_addr - _USR_PHYS_START;

    // Check index bounds
    if(index > _USR_PAGE_TTL)
        return;

    // Set page as free
    mmap_phys_pages[index] = 0;

    // Move free page index
    if(index < mmap_free_index) {
        mmap_free_index = index;
    }
}
