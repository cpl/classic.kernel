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
#include "sched.h"
#include "syscall.h"
#include "error.h"
#include "vfb.h"


void _low0();
void _low1();
void _high();

task _LOW0 = {
    PID:   1,
    quantum: 5000,
    flags: 0,

    size: 0x100,
    entry: &_low0,

    prior: TASK_PRIOR_LOW,
    state: TASK_STATE_READY,

    mm_page_count: 0,
    mm_tables: {NULL},

    next: NULL,
    context: {
        0,0,0,0,0,0,0,0,0,0,0,0,0,
        SP: 0x1600,
        LR: 0x0,
        PC: ((u32)&_low0),
        CPSR: 0x0000015F,
    },
};



task _LOW1 = {
    PID:   2,
    quantum: 5000,
    flags: 0,

    size: 0x100,
    entry: &_low1,

    prior: TASK_PRIOR_LOW,
    state: TASK_STATE_READY,

    mm_page_count: 0,
    mm_tables: {NULL},

    next: NULL,
    context: {
        0,0,0,0,0,0,0,0,0,0,0,0,0,
        SP: 0x1400,
        LR: 0x0,
        PC: ((u32)&_low1),
        CPSR: 0x0000015F,
    },
};

task _HIGH = {
    PID:   10,
    quantum: 5000,
    flags: 0,

    size: 0x100,
    entry: &_high,

    prior: TASK_PRIOR_HIG,
    state: TASK_STATE_READY,

    mm_page_count: 0,
    mm_tables: {NULL},

    next: NULL,
    context: {
        0,0,0,0,0,0,0,0,0,0,0,0,0,
        SP: 0x1400,
        LR: 0x0,
        PC: ((u32)&_high),
        CPSR: 0x0000015F,
    },
};


void _low0() {
    for(u16 i = 50; i; i--)
        syscall_println("_low_0(default);");

    while(1)
        syscall_println("_low_0(alternative);");
}

void _low1() {
    for(u16 i = 80; i; i--)
        syscall_println("_low_1(start);");

    syscall_sleep(10000);

    while(1) {
        syscall_println("_low_1();");
    }
}


void _high() {
    while(1) {
        syscall_println("_high();");
    }
}


// ----


void _kinit(void) {
    // 0xF1F0CAFE signature on entry
    syscall_uputx(0xF1F0CAFE); syscall_uputnl();

    // ! DEBUG mmap intial allocations
    vfb_println("\n MMAP INITIAL ALLOCATIONS");
    vfb_printf("   PHYS MEM SYS: %x\n",   MM_PHYS_SYS);
    vfb_printf("   PHYS MEM GPU: %x\n",   MM_PHYS_GPU);
    vfb_printf("   PHYS MEM KNL: %x\n",   MM_PHYS_KNL);
    vfb_printf("   PHYS MEM LIB: %x\n",   MM_PHYS_LIB);
    vfb_printf("   PHYS MEM USR: %x\n\n", MM_PHYS_USR);
    vfb_printf("   PAGE COUNT: %x\n\n", MM_PAGES_TTL);

    // Queue initial tasks
    sched_enqueue(&_LOW0);
    sched_enqueue(&_LOW1);








    // Pass execution control to scheduler
    sched_init();

    // Catch
    _panic("catch scheduler ilegal exit");
}
