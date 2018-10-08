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
#include "asm.h"
#include "vfb.h"
#include "mm.h"


void cmain(void) {
    vfb_println(strtmp_hex(0xDEADBEEF));
    vfb_println(NULL);

    kheap_init();

    kmalloc(0x39);
    kmalloc(0x10);
    kmalloc(0x20);
    kmalloc(0x30);
    void* p = kmalloc(0x40);
    void* a = kmalloc(0x20);
    void* b = kmalloc(0x50);
    void* f = kmalloc(0x20);
    void* l = kmalloc(0x10);

    kfree(l);
    kfree(p);

    kfree(a);
    kfree(b);


    kfree((void*)0xF0F0F0F0);
    vfb_println(NULL);

    mem_block* c = &_KERNEL_ALOC;
    while (c -> next != NULL) {
        mem_block_print(c);
        c = c -> next;
    }
    mem_block_print(c);


    vfb_println(NULL);
    kfree(f);

    c = &_KERNEL_ALOC;
    while (c -> next != NULL) {
        mem_block_print(c);
        c = c -> next;
    }
    mem_block_print(c);


    vfb_println(NULL);
    kmalloc(0x10);
    p = kmalloc(0x40);
    kmalloc(0x20);

    kfree(p);
    kmalloc(0x40);

    c = &_KERNEL_ALOC;
    while (c -> next != NULL) {
        mem_block_print(c);
        c = c -> next;
    }
    mem_block_print(c);
}
