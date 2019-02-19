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


/* fifo.h - First-In-First-Out buffer structs and functions

Mainly used for IPC.

*/


#ifndef _INC_FIFO_H
#define _INC_FIFO_H


#include "types.h"

#define FIFO_TAG 0xF1F0


typedef struct fifo {
    u32 is_a_fifo;

    u32 tail, head;
    u32 len, cap;

    u32* data;
} fifo;


fifo* fifo_new(u32 cap);
void  fifo_free(fifo* f);
u8    fifo_write(fifo* f, u32 value);
u8    fifo_read(fifo* f, u32* ret);


void fifo_print(fifo* f);

#endif
