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
#include "vfb.h"
#include "conv.h"
#include "mm.h"
#include "uart.h"
#include "sched.h"
#include "syscall.h"


void _memdump(void* ptr, u32 len) {
    u32* p = (u32*)ptr;
    void* bufr = syscall_kmalloc(0x40);

    while(len-- > 0) {
        conv_hex_str(bufr, (u32) p); vfb_print(bufr); vfb_print(" : ");
        conv_hex_str(bufr, (u32)*p); vfb_println(bufr);
        p++;
    }

    syscall_kfree(bufr);
}

extern void _hang(void);

void cmain(void) {
    // ctx my_context;
    // ctx new;

    // my_context.R0 = 0x100;
    // my_context.R1 = 0x200;
    // my_context.R2 = 0x300;

    // ctx_save(&my_context);
    // my_context.R0 = 0x500;
    // my_context.PC = (u32)&_hang;

    // new = my_context;


    // ctx_load(&my_context);

    sched_init();

    vfb_println("_hang_main();\n\r");

    while(1) {}

    // while(1) {
    //     vfb_reset();
    //     vfb_printf("CLK: %x\n", syscall_time());
    // }
}
