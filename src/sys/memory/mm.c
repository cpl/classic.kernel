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
#include "mm.h"
#include "vfb.h"
#include "memutils.h"
#include "asm.h"


mem_block*          _KERNEL_ALOC_LAST;
mem_block*          _KERNEL_ALOC_TAIL;


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

    if (mem_block_isdead(block)) {
        vfb_print(" DEAD");
    } else if (mem_block_isfree(block)) {
        vfb_print(" FREE");
    } else {
        vfb_print(" ALOC");
    }

    if (block == _KERNEL_ALOC_LAST) {
        vfb_print(" <--L");
    }
    if (block == _KERNEL_ALOC_TAIL) {
        vfb_print(" <--T");
    }
    if (block == _KERNEL_ALOC) {
        vfb_print(" <--H");
    }

    vfb_println(NULL);
}


mem_block* mem_block_spawn(mem_block* next, u32 size, void* addr) {

    // search for first dead block
    mem_block* current = _KERNEL_ALOC;
    while (current != _KERNEL_ALOC_LAST) {
        // found
        if (mem_block_isdead(current)) {
            break;
        }
        // next
        current -= sizeof(mem_block);
    }

    // set new block
    current -> next = next;
    current -> size = size;
    current -> addr = addr;

    // update end block
    if (_KERNEL_ALOC_LAST > current) {
        _KERNEL_ALOC_LAST = current;
    }

    return current;
}


void cls_knl_heap_init() {
    _KERNEL_ALOC -> addr = (void*)((u32)(&_KERNEL_HEAP)+1);
    _KERNEL_ALOC -> size = 0;
    _KERNEL_ALOC -> next = NULL;

    _KERNEL_ALOC_LAST = _KERNEL_ALOC;
    _KERNEL_ALOC_TAIL = _KERNEL_ALOC;
}


void* cls_knl_malloc(u32 size) {

    // align malloc request size to 0x40 bytes (16 words)
    size += ((_MIN_ALOC_SIZE-(size&(_MIN_ALOC_SIZE-1)))&(_MIN_ALOC_SIZE-1));

    // iterate memory blocks
    mem_block* current = _KERNEL_ALOC;
    while (current -> next != NULL) {

        // if block is free
        if (mem_block_isfree(current)) {

            // get free block size
            u32 fsize = current -> size;

            // if requested size, matches free block size, mark block as aloc
            if (fsize == size) {
                mem_block_aloc(current);
                return current -> addr;

            // else if free block size is larger than requested size
            // aloc the current free block to requested size and create
            // a new free block with the remaining size
            } else if (fsize > size) {

                // assign block to possible fragmented space
                if (mem_block_isdead((mem_block*)(current - sizeof(mem_block)))) {
                    (current - sizeof(mem_block)) -> size = fsize - size;
                    (current - sizeof(mem_block)) -> addr = current -> addr + size;
                    (current - sizeof(mem_block)) -> next = current -> next;

                    current -> next = (current - sizeof(mem_block));

                // otherwise find first dead block or alloc at end of blocks
                } else {
                    current -> next = mem_block_spawn(current -> next, fsize - size, (current -> addr) + size);
                }

                current -> size = size;

                mem_block_aloc(current);
                mem_block_free(current -> next);

                return current -> addr;
            }
            // NOT SURE I CARE ENOUGH FOR THIS CASE, OVERHEAD FOR FINDING FREE
            // MEMORY AND ALLOCATING IT THEN SETTING THE PROPER STATUS OF THE
            // BLOCKS IS TOO LARGE - TBD IF WORTHWHILE

            // else while next blocks are free, calculate total free size
            // and allocate a single block, setting the other as dead/free
            // } else {
            //     vfb_println("ERR (fsize else)");
            //     return NULL;
            // }
        }

        // walk to next block
        current = current -> next;
    }

    // reached end
    if (current != _KERNEL_ALOC_TAIL) {
        vfb_print("SEGFAULT: ");
        vfb_println(strtmp_hex(GETPC()));
        return NULL;
    }

    // allocate end block
    current -> size = size;

    // create new end block
    current -> next = _KERNEL_ALOC_LAST - sizeof(mem_block);
    current -> next -> next = NULL;
    current -> next -> size = 0;
    current -> next -> addr = (current -> addr) + size;

    // set allocations end
    _KERNEL_ALOC_LAST = current -> next;
    _KERNEL_ALOC_TAIL = current -> next;

    // return pointer to allocated block
    mem_block_aloc(current);
    return current -> addr;
}


void* cls_knl_falloc(u32 size) {

    // align malloc request size to 0x40 bytes (16 words)
    size += ((_MIN_ALOC_SIZE-(size&(_MIN_ALOC_SIZE-1)))&(_MIN_ALOC_SIZE-1));

    // create new end block
    _KERNEL_ALOC_LAST -= sizeof(mem_block);

    // alloc wanted memory at the tail block
    _KERNEL_ALOC_TAIL -> size = size;
    _KERNEL_ALOC_TAIL -> next = _KERNEL_ALOC_LAST;

    // create ew tail block at the end block
    _KERNEL_ALOC_LAST -> addr = (_KERNEL_ALOC_TAIL -> addr) + size;
    _KERNEL_ALOC_LAST -> next = NULL;
    _KERNEL_ALOC_LAST -> size = 0;

    // update tail to end
    _KERNEL_ALOC_TAIL = _KERNEL_ALOC_LAST;

    return _KERNEL_ALOC_TAIL -> addr;
}


void* cls_knl_calloc(u32 size) {
    // perform normal malloc
    mem_block* block = cls_knl_malloc(size);

    // avoid memzero wrong region
    if (block == NULL) {
        vfb_print("SEGFAULT: ");
        vfb_println(strtmp_hex(GETPC()));
        return NULL;
    }

    // zero memory
    memzero(block, size);

    // return addr
    return block -> addr;
}


void cls_knl_free(void* addr) {

    // iterate memory blocks, until block is found
    mem_block* current = _KERNEL_ALOC;
    while (current -> addr != addr) {
        // check next
        current = current -> next;

        // if end is reached, SEGFAULT
        if (current == NULL) {
            vfb_print("SEGFAULT: ");
            vfb_println(strtmp_hex(GETPC()));
            return;
        }
    }

    // if next block is the tail block, set the current to be freed block
    // to be the tail block
    if (current -> next == _KERNEL_ALOC_TAIL) {

        // if tail block is also last aloc block
        // set the last aloc block to the new tail block
        if (_KERNEL_ALOC_LAST == _KERNEL_ALOC_TAIL) {
            _KERNEL_ALOC_LAST += sizeof(mem_block);
        } else {
            mem_block_dead(current -> next);
        }

        // set as tail block
        current -> size = 0;
        current -> next = NULL;

        // set pointer to new tail
        _KERNEL_ALOC_TAIL = current;

    // if next blocks are free, merge with current block
    } else if (mem_block_isfree(current -> next)) {
        mem_block* next = current -> next;

        // iterate free blocks, if any
        while (mem_block_isfree(next)) {

            // set blocks as dead on the way
            mem_block_dead(next);

            // if free chain spans to tail block, unchain free blocks
            // and set current block as tail block
            if (next == _KERNEL_ALOC_TAIL) {
                current -> size = 0;
                _KERNEL_ALOC_TAIL = current;
                break;
            }

            // accumulate size, set block as dead and move to next
            current -> size += next -> size;
            next = next -> next;
        }

        // set appropiate next pointer,
        // handles tail case as tail -> next is NULL
        current -> next = next -> next;
    }

    // free block by setting the flag in the block -> addr
    mem_block_free(current);

    // clear trail of dead bodies
    while (mem_block_isdead(_KERNEL_ALOC_LAST)) {
        _KERNEL_ALOC_LAST += sizeof(mem_block);
    }

    return;
}