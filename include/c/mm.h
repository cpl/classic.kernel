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


/* mm.h - Memory Manager header

Define the types, functions, macros and pointers used by the memory allocator.

*/


#ifndef _INC_MM_H
#define _INC_MM_H

#include "types.h"

// Minimum allocation size is 16 words or 64 bytes
#define _MIN_ALOC_SIZE 16*4

typedef struct mem_block {
    u32                 size;
    void*               addr;
    struct mem_block*   next;
} mem_block;

#define     mem_block_free(b) ((b -> addr) = (void*)((u32)(b -> addr) | 1))
#define     mem_block_dead(b) ((b -> addr) = NULL)
#define     mem_block_aloc(b) ((b -> addr) = (void*)((u32)(b -> addr) & ~1))

#define     mem_block_isfree(b) (((u32)(b -> addr) & 1) ? 1 : 0)
#define     mem_block_isdead(b) ((b -> addr) == NULL)
#define     mem_block_islast(b) (b == _KERNEL_ALOC_LAST)

extern void*        _KERNEL_HEAP;

// sizes are in bytes
void  kheap_init(void);
void* kmalloc(u32 size);
void  kfree(void* addr);
void* kfalloc(u32 size);
void* kcalloc(u32 size);

#endif
