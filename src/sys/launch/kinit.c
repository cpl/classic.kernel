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
#include "fifo.h"


void _low0();
void _low1();

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


void _low0() {
    for(u16 i = 100; i; i--) {
        syscall_print(".");
    }

    syscall_kill(1, 0);

    while(1) {
        syscall_println("CATCH ]]]]]]]]]]]]]]]]]]]]]]]]");
    }
}

void _low1() {
    while(1) {
        syscall_print("+");
    }
}

// ----


void _kinit(void) {
    // DEADBEEF on entry
    syscall_uputx(0xDEADBEEF); syscall_uputnl();

    // ! DEBUG mmap intial allocations
    vfb_println("\n MMAP INITIAL ALLOCATIONS");
    vfb_printf("   PHYS MEM SYS: %x\n",   MM_PHYS_SYS);
    vfb_printf("   PHYS MEM GPU: %x\n",   MM_PHYS_GPU);
    vfb_printf("   PHYS MEM KNL: %x\n",   MM_PHYS_KNL);
    vfb_printf("   PHYS MEM LIB: %x\n",   MM_PHYS_LIB);
    vfb_printf("   PHYS MEM USR: %x\n\n", MM_PHYS_USR);
    vfb_printf("   PAGE COUNT: %x\n\n", MM_PAGES_TTL);

    // Testing area


    vfb_printf("CREATING: FIFO\n");
    fifo* FIFO = fifo_new(40);
    fifo_print(FIFO);

    u32 val;


    vfb_printf("...\n");

    fifo_write(FIFO, 0x10);
    vfb_printf("WRITING\n");
    fifo_print(FIFO);

    fifo_write(FIFO, 0x1B);
    vfb_printf("WRITING\n");
    fifo_print(FIFO);

    fifo_write(FIFO, 0x30);
    vfb_printf("WRITING\n");
    fifo_print(FIFO);

    fifo_write(FIFO, 0x4A);
    vfb_printf("WRITING\n");
    fifo_print(FIFO);

    vfb_printf("IS FIFO: %x\n", FIFO -> is_a_fifo);
    fifo_free(FIFO);


    // Queue initial tasks
    // sched_enqueue(&_LOW0);
    // sched_enqueue(&_LOW1);

    // Pass execution control to scheduler
    // sched_init();

    while(1);

    // Catch
    _panic("catch scheduler ilegal exit");
}
