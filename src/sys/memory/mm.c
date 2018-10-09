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


mem_block*          _KERNEL_ALOC_LAST;
mem_block*          _KERNEL_ALOC_TAIL;
mem_block*          _KERNEL_ALOC_DEAD;


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
        vfb_print(" FREE");
    } else if (mem_block_isdead(block)) {
        vfb_print(" DEAD");
    } else {
        vfb_print(" ALOC");
    }

    if (block == _KERNEL_ALOC_LAST) {
        vfb_print(" <--L");
    }
    if (block == _KERNEL_ALOC_TAIL) {
        vfb_print(" <--T");
    }
    if (block == _KERNEL_ALOC_DEAD) {
        vfb_print(" <--D");
    }
    if (block == &_KERNEL_ALOC) {
        vfb_print(" <--A");
    }

    vfb_println(NULL);
}


void cls_knl_heap_init() {
    _KERNEL_ALOC.addr = &_KERNEL_HEAP;
    _KERNEL_ALOC.size = 0;
    _KERNEL_ALOC.next = NULL;

    _KERNEL_ALOC_LAST = &_KERNEL_ALOC;
    _KERNEL_ALOC_TAIL = &_KERNEL_ALOC;
    _KERNEL_ALOC_DEAD = &_KERNEL_ALOC;
}


void mem_block_spawn(mem_block* prev, mem_block* next, u32 size) {

    // MUST handle dead block finding by walking from _KERNEL_ALOC_DEAD
    // to _KERNEL_ALOC_LAST, if _KERNEL_ALOC_DEAD is a dead block then
    // allocate it, else find the next DEAD block, aloc it, and set the
    // DEAD pointer to it

    _KERNEL_ALOC_LAST = _KERNEL_ALOC_LAST + sizeof(mem_block);

    _KERNEL_ALOC_LAST -> size = size;
    _KERNEL_ALOC_LAST -> next = next;
    _KERNEL_ALOC_LAST -> addr = (prev -> addr) - (prev -> size);

    prev -> next = _KERNEL_ALOC_LAST;
}


void* cls_knl_malloc(u32 size) {

    size += ((_MIN_ALOC_SIZE - (size & (_MIN_ALOC_SIZE-1))) & (_MIN_ALOC_SIZE-1));

    mem_block* current = &_KERNEL_ALOC;
    while (current -> next != NULL) {
        if (mem_block_isfree(current)) {
            u32 csize = current -> size;

            if (csize == size) {
                mem_block_aloc(current);
                return current -> addr;
            } else if ((csize > size) && ((csize - size) >= _MIN_ALOC_SIZE)) {
                mem_block* next = current + sizeof(mem_block);
                if (mem_block_isdead(next)) {
                    next -> size = (csize - size);
                    next -> next = current -> next;
                    next -> addr = (current -> addr) - (current -> size);
                } else {
                    mem_block_spawn(current, current -> next, csize-size);
                }

                mem_block_aloc(current);
                current -> size = size;
                return current -> addr;
            } else {
                // while(next block is free)
                // add size
                // keep new pointer for sub-blockchain
                // if enough space, alloc first block, and set other as dead
                // or free, modify address of each to fit new space

                // else, break and continue checking main block, reseting csize
            }
        }

        current = current -> next;
    }

    if (current -> size != 0) {
        vfb_println("SEGFAULT");
        return NULL;
    }

    current -> size = size;
    current -> next = _KERNEL_ALOC_LAST + sizeof(mem_block);
    current -> next -> next = NULL;
    current -> next -> size = 0;
    current -> next -> addr = (current -> addr) - size;

    _KERNEL_ALOC_LAST = current -> next;
    _KERNEL_ALOC_TAIL = current -> next;

    return current -> addr;
}


void* cls_knl_falloc(u32 size) {
    _KERNEL_ALOC_LAST = _KERNEL_ALOC_LAST + sizeof(mem_block);
    _KERNEL_ALOC_TAIL -> next = _KERNEL_ALOC_LAST;
    _KERNEL_ALOC_TAIL -> size = size;

    return _KERNEL_ALOC_TAIL -> addr;
}


void cls_knl_free(void* ptr) {

    // CONSIDERING doing free block merges
    // this would speed up malloc and detect some
    // extra DEAD blocks at the cost of more
    // heap_aloc fragmentation

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
            if (mem_block_isfd(prev)) {
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
    if (mem_block_isfree(current -> next)) {
        current -> size += current -> next -> size;

        mem_block_dead(current -> next);
        if (_KERNEL_ALOC_DEAD == &_KERNEL_ALOC || _KERNEL_ALOC_DEAD > current -> next) {
            _KERNEL_ALOC_DEAD = current -> next;
        }

        current -> next = current -> next -> next;
    }
}