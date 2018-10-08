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
#include "mm.h"
#include "vfb.h"


void mem_block_print(mem_block* block) {
    if (block == NULL) {
        vfb_println("BLOCK: NULL");
        return;
    }

    vfb_print("BLOCK: SIZE: ");
    vfb_print(strtmp_hex((u32)block -> size));
    vfb_print(" ADDR: ");
    vfb_print(strtmp_hex((u32)block -> addr));
    vfb_print(" NEXT: ");
    vfb_print(strtmp_hex((u32)block -> next));

    if ((u32)(block -> addr) & 1 || block -> size == 0) {
        vfb_println(" free");
    } else {
        vfb_println(" alct");
    }
}


void kheap_init() {
    _KERNEL_ALOC.addr = &_KERNEL_HEAP;
    _KERNEL_ALOC.size = 0;
    _KERNEL_ALOC.next = NULL;

    _KERNEL_ALOC_FREE[0] = &_KERNEL_ALOC;
}


void* kmalloc(u32 size) {

    // Align to 4 bytes
    size += (4 - (size & 3)) & 3;


    // Find last block
    mem_block* current = &_KERNEL_ALOC;
    while(current -> next != NULL) {
        current = current -> next;
    }

    // Allocate last block
    current -> size = size;
    current -> next = current + sizeof(mem_block);

    // Write next empty block
    current -> next -> size = 0;
    current -> next -> addr = current -> addr - size;
    current -> next -> next = NULL;

    // Return allocated address
    return current -> addr;
}


void kfree(void* ptr) {

    mem_block* current = &_KERNEL_ALOC;
    while (current -> addr != ptr) {
        if (current -> next == NULL) {
            vfb_println("SEGFAULT");
            return;
        }

        current = current -> next;
    }

    mem_block* next = current -> next;

    if (next -> size == 0) {
        current -> size = 0;
        current -> next = NULL;
        return;
    } else if ((u32)(next -> addr) & 1) {
        current -> size += next -> size;
        current -> next  = next -> next;
    }

    current -> addr = (void*)((u32)(current -> addr) | 1);
}


void* malloc(u32 size) {
    return NULL;
}


void free(void* ptr) {
    return;
}


void* calloc(u32 size) {
    return NULL;
};


void* realloc(void* ptr, u32 size) {
    return NULL;
};