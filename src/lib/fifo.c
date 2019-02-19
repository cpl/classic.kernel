/*
   Copyright 2018-2019 Alexandru-Paul Copil

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


// fifo_new allocates space for a fifo buffer with cap ammount of words in the
// kernel heap.
fifo* fifo_new(u32 cap) {
    if(cap <= 32)
        cap = 32;

    fifo* f = (fifo*)kmalloc(sizeof(fifo));
    if(f == NULL)
        return NULL;

    f -> data = (u32*)kmalloc(cap*4);
    if(f -> data == NULL)
        return NULL;

    f -> cap = cap-1;
    f -> len  = 0;
    f -> head = 0;
    f -> tail = 1;

    f -> is_a_fifo = FIFO_TAG;

    return f;
}


// fifo_free calls kfree on the FIFO data and on the FIFO struct.
void fifo_free(fifo* f) {
    f -> is_a_fifo = 0;

    kfree(f -> data);
    kfree(f);
}


// fifo_write takes the FIFO pointer and the value (a word) to write. The
// function returns 0 if write failed and 1 if write OK. On a write the
// tail must reach the head for a fail to occur. After a succesful write, the
// tail and len are both incremented. The tail may get capped within the FIFO
// cap limit, so use FIFO -> len to determine the number of items.
u8 fifo_write(fifo* f, u32 value) {
    if(f -> tail == f -> head)
        return 0;

    f -> data[f -> tail] = value; f -> len++; f -> tail++;

    if(f -> tail >= f -> cap)
        f -> tail = 0;

    return 1;
}


// fifo_read takes the FIFO pointer and a u32 pointer to place the read value.
// If fifo_read fails it returns 0 and 1 if OK. The function can fail if the
// FIFO buffer is empty (head is reaching tail). After a succesful read, the
// head is incremented and len is decremnted. Head pointer can get capped by
// FIFO cap limit.
u8 fifo_read(fifo* f, u32* ret) {
    if((f -> head + 1) % f -> cap == f -> tail)
        return 0;

    f -> head++;

    *ret = f -> data[f -> head]; f -> len--;

    if(f -> head >= f -> cap)
        f -> head = 0;

    return 1;
}


// ! DEBUG fifo_print is a debug function.
void fifo_print(fifo* f) {
    vfb_printf("-- FIFO --\n");
    vfb_printf("HEAD: %x | TAIL: %x\n", f -> head, f -> tail);
    vfb_printf("CAP:  %x | LEN:  %x\n", f -> cap, f -> len);
}
