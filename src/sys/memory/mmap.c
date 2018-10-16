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


static u32 mmap_findex = 0;
static u8  mmap_ppages [_USR_PAGE_MAX] = {0,};


void* mmap_get_page(void) {

    // Iterate all phyisical pages and find a free one
    for (u32 index = mmap_findex; index < _USR_PAGE_MAX; index++) {

        // Check if physical page is free
        if(!mmap_ppages[index]) {
            mmap_findex = index+1;           // Set next possible free page
            mmap_ppages[index] = 1;          // Set page as allocated

            // Return physical page address
            return (void*)(_USR_VIRT_START+(index<<_SYS_PAGE_SHFT));
        }
    }

    return NULL;
}


void mmap_free(void* addr) {
    // Convert address to index
    u8 index = (((u32)addr - _USR_VIRT_START)>>_SYS_PAGE_SHFT);

    // Set possible free index
    if(index < mmap_findex)
        mmap_findex = index;

    // Free page
    mmap_ppages[index] = 0;
}
