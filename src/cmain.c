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


void cmain(void) {
    vfb_println(strtmp_hex(0xDEADBEEF));
    vfb_print("sizeof(mem_block) = ");
    vfb_println(strtmp_hex(sizeof(mem_block)));
    vfb_println(NULL);

    cls_knl_heap_init();

    mem_block* p = NULL;

    cls_knl_malloc(0x1);
    cls_knl_malloc(0x40);
    cls_knl_malloc(0xDF);
    cls_knl_malloc(0x20);
    p = cls_knl_malloc(0x50);
    cls_knl_free(p);
    cls_knl_malloc(0x30);

    mem_block* c = _KERNEL_ALOC;
    while (c -> next != NULL) {
        mem_block_print(c);
        c = c -> next;
    }
    mem_block_print(c);
    vfb_println(NULL);


    c = _KERNEL_ALOC;
    while (c != _KERNEL_ALOC_LAST) {
        mem_block_print(c);
        c -= sizeof(mem_block);
    }
    mem_block_print(c);
    vfb_println(NULL);
}