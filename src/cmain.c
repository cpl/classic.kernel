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
#include "vfb.h"
#include "mm.h"


void print_block() {
    mem_block* c = _KERNEL_ALOC;
    while (c -> next != NULL) {
        mem_block_print(c);
        c = c -> next;
    }
    mem_block_print(c);
    vfb_println(NULL);
}


void print_memory() {
    mem_block* c = _KERNEL_ALOC;
    while (c != _KERNEL_ALOC_LAST) {
        mem_block_print(c);
        c -= sizeof(mem_block);
    }
    mem_block_print(c);
    vfb_println(NULL);
}


void cmain(void) {
    vfb_println(strtmp_hex(0xDEADBEEF));
    vfb_print("sizeof(mem_block) = ");
    vfb_println(strtmp_hex(sizeof(mem_block)));
    vfb_println(NULL);

    cls_knl_heap_init();

    mem_block* p = NULL;
    mem_block* q = NULL;
    mem_block* r = NULL;
    mem_block* s = NULL;
    mem_block* t = NULL;
    mem_block* f = NULL;



    cls_knl_malloc(0x40);
    mem_block* a = cls_knl_malloc(0x40);
    mem_block* b = cls_knl_malloc(0x40);
    cls_knl_malloc(0x40);
    cls_knl_malloc(0x40);
    cls_knl_malloc(0x40);
    cls_knl_malloc(0x40);
    cls_knl_malloc(0x40);
    f = cls_knl_malloc(0x40);
    s = cls_knl_malloc(0x40);
    r = cls_knl_malloc(0x40);
    q = cls_knl_malloc(0x40);
    p = cls_knl_malloc(0x40);
    cls_knl_malloc(0x40);

    // ---

    cls_knl_free(s);
    cls_knl_free(r);
    cls_knl_free(q);
    cls_knl_free(p);

    cls_knl_free(b);
    cls_knl_free(a);

    print_memory();

    cls_knl_free(f);

    print_memory();

    cls_knl_malloc(0x100);
    cls_knl_malloc(0x200);
    cls_knl_malloc(0x80);
    cls_knl_malloc(0x80);
    cls_knl_malloc(0x40);

    print_memory();
}
