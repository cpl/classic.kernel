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
#include "memutil.h"
#include "error.h"


static mem_block*   _KERNEL_ALOC = (void*)0x000FFFFF;
mem_block*          _KERNEL_ALOC_LAST;
mem_block*          _KERNEL_ALOC_TAIL;


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


void kheap_init() {
    _KERNEL_ALOC -> addr = (void*)((u32)(&_KERNEL_HEAP)+1);
    _KERNEL_ALOC -> size = 0;
    _KERNEL_ALOC -> next = NULL;

    _KERNEL_ALOC_LAST = _KERNEL_ALOC;
    _KERNEL_ALOC_TAIL = _KERNEL_ALOC;
}


void* kmalloc(u32 size) {

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
        }

        // walk to next block
        current = current -> next;
    }

    // reached end
    if (current != _KERNEL_ALOC_TAIL) {
        _panic("kmalloc() end is not tail");
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


void* kfalloc(u32 size) {

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


void* kcalloc(u32 size) {
    // perform normal malloc
    mem_block* block = kmalloc(size);

    // avoid memzero wrong region
    if (block == NULL) {
        _panic("kcalloc() got NULL block from malloc");
        return NULL;
    }

    // zero memory
    memzero(block, size);

    // return addr
    return block -> addr;
}


void kfree(void* addr) {

    // iterate memory blocks, until block is found
    mem_block* current = _KERNEL_ALOC;
    while (current -> addr != addr) {
        // check next
        current = current -> next;

        // if end is reached, SEGFAULT
        if (current == NULL) {
            _panic("kfree() failed to find block");
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