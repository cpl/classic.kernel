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


#include "cls.stdlib.h"


typedef struct mem_block {
    u32                 size;
    void*               addr;
    struct mem_block*   next;
} mem_block;

void mem_block_print(mem_block* block);
// mem_block* mem_block_spawn(mem_block* prev, mem_block* next, u32 size);

#define mem_block_isfree(block) (((u32)(block -> addr) & 1) ? 1 : 0)
#define mem_block_islast(block) ((block == _KERNEL_ALOC_LAST) ? 1 : 0)
#define mem_block_free(block) ((block -> addr) = (void*)((u32)(block -> addr) | 1))
#define mem_block_aloc(block) ((block -> addr) = (void*)((u32)(block -> addr) & (u32)(-2)))
#define mem_block_dead(block) ()


extern void*        _KERNEL_HEAP;
extern mem_block    _KERNEL_ALOC;
mem_block*          _KERNEL_ALOC_LAST;
mem_block*          _KERNEL_ALOC_TAIL;


void  kheap_init(void);
void* kmalloc(u32 size);
void  kfree(void*  ptr);
