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

    vfb_print("BLOCK ");
    vfb_print(strtmp_hex((u32)block));
    vfb_print(": SIZE: ");
    vfb_print(strtmp_hex((u32)block -> size));
    vfb_print(" ADDR: ");
    vfb_print(strtmp_hex((u32)block -> addr));
    vfb_print(" NEXT: ");
    vfb_print(strtmp_hex((u32)block -> next));

    if (mem_block_isfree(block) || block -> size == 0) {
        vfb_print(" free");
    } else {
        vfb_print(" alct");
    }

    if (block == _KERNEL_ALOC_LAST) {
        vfb_print(" <--L");
    }
    if (block == _KERNEL_ALOC_TAIL) {
        vfb_print(" <--T");
    }

    vfb_println(NULL);
}


void kheap_init() {
    _KERNEL_ALOC.addr = &_KERNEL_HEAP;
    _KERNEL_ALOC.size = 0;
    _KERNEL_ALOC.next = NULL;

    _KERNEL_ALOC_LAST = &_KERNEL_ALOC;
    _KERNEL_ALOC_TAIL = &_KERNEL_ALOC;
}


mem_block* mem_block_spawn(mem_block* next, u32 size) {
    mem_block* ret = _KERNEL_ALOC_LAST;

    ret -> size = size;
    ret -> next = ret + sizeof(mem_block);
    ret -> next -> addr = ret -> addr - size;
    ret -> next -> next = next;
    ret -> next -> size = 0;

    _KERNEL_ALOC_LAST = ret -> next;
    if (next == NULL) {
        _KERNEL_ALOC_TAIL = ret -> next;
    }

    return ret;
}


void* kmalloc(u32 size) {

    // Align to 4 bytes
    size += (4 - (size & 3)) & 3;


    mem_block* current = &_KERNEL_ALOC;
    while (current -> next != NULL) {
        if (mem_block_isfree(current)) {
            u32 csize = current -> size;

            if (csize == size) {
                mem_block_aloc(current);
                return current -> addr;
            } else if (csize > size) {

            }
        }

        current = current -> next;
    }

    return mem_block_spawn(NULL, size) -> addr;
}


void kfree(void* ptr) {

    // Search for block to free
    mem_block* current = &_KERNEL_ALOC;
    while (current -> addr != ptr) {
        // Check next
        current = current -> next;

        // Reached end of heap aloc chain
        if (current == NULL) {
            vfb_println("SEGFAULT");
            return;
        }
    }

    // [A]->[A]->[A]->[F]->[0]->NULL
    if (current -> next == _KERNEL_ALOC_LAST) {
        mem_block* prev = current - sizeof(mem_block);

        // [A]->[F]->[F]->[F]->[0]->NULL
        while (prev -> next == current) {
            if (mem_block_isfree(prev)) {
                current = prev;
                prev = current - sizeof(mem_block);
            } else {
                break;
            }
        }

        // [A]->[0]->NULL
        current -> size = 0;
        current -> next = NULL;
        mem_block_aloc(current);

        _KERNEL_ALOC_LAST = current;
        _KERNEL_ALOC_TAIL = current;
        return;
    }

    mem_block_free(current);
}