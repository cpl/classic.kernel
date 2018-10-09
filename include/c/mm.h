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


#define _MIN_ALOC_SIZE 16*4


typedef struct mem_block {
    u32                 size;
    void*               addr;
    struct mem_block*   next;
} mem_block;


void        mem_block_print(mem_block*);
#define     mem_block_free(b) ((b -> addr) = (void*)((u32)(b -> addr) | 1))
#define     mem_block_dead(b) ((b -> addr) = (void*)((u32)(b -> addr) | 2))
#define     mem_block_aloc(b) ((b -> addr) = (void*)((u32)(b -> addr) & (u32)(-2)))
#define     mem_block_isfree(b) (((u32)(b -> addr) & 1) ? 1 : 0)
#define     mem_block_isdead(b) (((u32)(b -> addr) & 2) ? 1 : 0)
#define     mem_block_isfd(b)   (((u32)(b -> addr) & 3) ? 1 : 0)
#define     mem_block_islast(b) ((b == _KERNEL_ALOC_LAST) ? 1 : 0)


extern void*        _KERNEL_HEAP;
extern mem_block    _KERNEL_ALOC;


void  cls_knl_heap_init(void);
void* cls_knl_malloc(u32 size);
void  cls_knl_free(void*  ptr);
void* cls_knl_falloc(u32 size);
