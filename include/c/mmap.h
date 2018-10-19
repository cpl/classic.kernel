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

/* mmap.h - Memory map of physical pages

Map and free physical pages for kernel and user use. In userland pages are
mapped to virtual address space. The user address space starts at 0x1000 0000,
and goes up to 0x1200 0000, giving each task a total of 32MB of physical
memory. In order to map 32MB of memory, 32 coarse tables are assigned taking
up 1kb of memory each and so 4 coarse tables can fit on a single 4kb page.
Giving each task 8 page pointers for all 32 tables.

*/


#ifndef _INC_MMAP_H
#define _INC_MMAP_H

#define MM_PHYS_SYS 0x20000000
#define MM_PHYS_GPU 0x04000000
#define MM_PHYS_KNL 0x00100000
#define MM_PHYS_USR (MM_PHYS_SYS-MM_PHYS_GPU-MM_PHYS_KNL)

#define MM_SECT_SHIFT 20
#define MM_PAGE_SHIFT 12

#define MM_SECT_SIZE (1<<MM_SECT_SHIFT)
#define MM_PAGE_SIZE (1<<MM_PAGE_SHIFT)

#define MM_PAGES_TTL (MM_PHYS_USR/MM_PAGE_SIZE)
#define MM_PAGES_PER_TLB 0x100

#define MM_VIRT_USR_START 0x10000000

void* mmap_aloc_page();
void  mmap_free_page(void* addr);

#endif
