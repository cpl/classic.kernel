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


#include "fifo.h"
#include "types.h"
#include "mm.h"
#include "vfb.h"


fifo* fifo_new(u32 cap) {
    if(cap <= 32)
        cap = 32;

    fifo* f = (fifo*)kmalloc(sizeof(fifo));
    f -> data = (u32*)kcalloc(sizeof(u32)*cap);
    f -> cap = cap-1;
    f -> len  = 0;
    f -> head = 0;
    f -> tail = 1;

    f -> is_a_fifo = FIFO_TAG;

    return f;
}


void fifo_free(fifo* f) {
    f -> is_a_fifo = 0;

    kfree(f -> data);
    kfree(f);
}


u8 fifo_write(fifo* f, u32 value) {

    vfb_println(">> ENTER WRITE");

    if(f -> tail == f -> head)
        return 0;

    vfb_println(">> CHECKED TAIL IS HEAD");

    f -> data[f -> tail] = value; f -> len++; f -> tail++;

    vfb_println(">> WROTE DATA");

    if(f -> tail >= f -> cap)
        f -> tail = 0;

    vfb_println(">> CAP TAIL");

    return 1;
}


u8 fifo_read(fifo* f, u32* ret) {
    if((f -> head + 1) % f -> cap == f -> tail)
        return 0;

    f -> head++;

    *ret = f -> data[f -> head]; f -> len--;

    if(f -> head >= f -> cap)
        f -> head = 0;

    return 1;
}


void fifo_print(fifo* f) {
    vfb_printf("-- FIFO --\n");
    vfb_printf("HEAD: %x | TAIL: %x\n", f -> head, f -> tail);
    vfb_printf("CAP:  %x | LEN:  %x\n", f -> cap, f -> len);
}
