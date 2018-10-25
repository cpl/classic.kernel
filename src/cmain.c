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


void _nothing() {
    while(1) {
        syscall_uputs("_nothing();\n\r");
    }
}


void cmain(void) {

    syscall_uputx(0xDEADBEEF);
    uart_clrf();

    syscall_uputx(syscall_time()); uart_clrf();
    sched_spawn(&_nothing, 0xA37F, 0, TASK_PRIOR_MED);
    syscall_uputx(syscall_time()); uart_clrf();
    syscall_uputx(mmap_get_aloc_memory()); uart_clrf();

    // sched_init();

    vfb_println("_hang_main();\n\r");
    _memdump((void*)0x10000000, 0x30);

    while(1) {}

    // while(1) {
    //     vfb_reset();
    //     vfb_printf("CLK: %x\n", syscall_time());
    // }
}
