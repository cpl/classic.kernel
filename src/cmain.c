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
    vfb_println(NULL);

    cls_knl_heap_init();

    mem_block* p = NULL;
    mem_block* q = NULL;

    cls_knl_malloc(0x1);
    cls_knl_malloc(0x40);
    q = cls_knl_malloc(0xDF);
    p = cls_knl_malloc(0x20);
    cls_knl_malloc(0x50);

    cls_knl_free(p);
    cls_knl_free(q);


    mem_block* c = &_KERNEL_ALOC;
    while (c -> next != NULL) {
        mem_block_print(c);
        c = c -> next;
    }
    mem_block_print(c);
    vfb_println(NULL);
}
