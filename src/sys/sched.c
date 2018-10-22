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


#include "sched.h"
#include "mmap.h"
#include "mmu.h"
#include "uart.h"
#include "syscall.h"
#include "vfb.h"



void print_ctx(ctx* c) {
    vfb_println(NULL);
    vfb_printf("%x\n", c->R0);
    vfb_printf("%x\n", c->R1);
    vfb_printf("%x\n", c->R2);
    vfb_printf("%x\n", c->R3);
    vfb_printf("%x\n", c->R4);
    vfb_printf("%x\n", c->R5);
    vfb_printf("%x\n", c->R6);
    vfb_printf("%x\n", c->R7);
    vfb_printf("%x\n", c->R8);
    vfb_printf("%x\n", c->R9);
    vfb_printf("%x\n", c->R10);
    vfb_printf("%x\n", c->R11);
    vfb_printf("%x\n", c->R12);
    vfb_printf("%x\n", c->SP);
    vfb_printf("%x\n", c->LR);
    vfb_printf("%x\n", c->PC);
}


void _kernel() {
    while(1) {
        // vfb_reset();
        // vfb_printf("CLK: %x\n", syscall_time());
        // print_ctx(CTX_IRQ);
        syscall_uputs("---\n\r");
    }
}

void _new_proc() {
    while(1)
        syscall_uputs("_new_proc();\n\r");
}


static task* CURRENT = NULL;

// static task* CURRENT_HIG = NULL;
// static task* CURRENT_MED = NULL;
// static task* CURRENT_LOW = NULL;


static task _KERNEL_TASK = {
    PID:   0,
    flags: 0,
    slice: 4,

    size: 0x100,
    entry: &_kernel,

    prior: TASK_PRIOR_MED,
    state: TASK_STATE_RUNNING,

    mm_page_count: 0,
    mm_tables: {NULL, },

    next: &_KERNEL_TASK,
    context: {
        0,
        SP: 0x2000,
        LR: 0x0,
        PC: ((u32)&_kernel)+4,
    },
};

static task _NEW_TASK = {
    PID:   1,
    flags: 0,
    slice: 4,

    size: 0x100,
    entry: &_new_proc,

    prior: TASK_PRIOR_MED,
    state: TASK_STATE_RUNNING,

    mm_page_count: 0,
    mm_tables: {NULL, },

    next: &_KERNEL_TASK,
    context: {
        0,
        SP: 0x2400,
        LR: 0x0,
        PC: ((u32)&_new_proc)+4,
    },
};



void sched_init() {
    CURRENT = &_KERNEL_TASK;
    sched_enqueue(&_NEW_TASK);

    ctx_load(&_KERNEL_TASK.context);
}


u16 prior_to_slice[TASK_PRIOR_COUNT] = {
    [TASK_PRIOR_LOW] = 0x1,
    [TASK_PRIOR_MED] = 0x5,
    [TASK_PRIOR_HIG] = 0xA,
};


void sched_enqueue(register task* new) {
    new     -> next  = CURRENT -> next;
    CURRENT -> next  = new;
    new     -> slice = prior_to_slice[new -> prior];
}


void sched_tick() {
    syscall_uputs("SCHED TICK\n\r");

    if(--(CURRENT->slice))
        return;

    // Update time slice for executed task
    CURRENT -> slice = prior_to_slice[CURRENT -> prior];
    sched_next();
}


void sched_next() {

    syscall_uputs("SCHED NEXT\n\r");

    // Check next task
    register task* next = CURRENT -> next;
    if(next == CURRENT) {
        syscall_uputs("SCHED SAME PROC\n\r");
        return;
    }

    // Save ref to previous
    task* prev = CURRENT;

    // Skip non-running tasks
    while(next -> state != TASK_STATE_RUNNING)
        next = next -> next;

    // Update memory maps
    // task_mm_set(next);

    syscall_uputs("CONTEXT SWITCH\n\r");

    ctx_copy(CTX_IRQ, &(prev -> context));
    syscall_uputs("OK\n\r");

    ctx_copy(&(next -> context), CTX_IRQ);
    syscall_uputs("OK\n\r");

    ctx_user(&(prev -> context), &(next -> context));
    syscall_uputs("OK\n\r");


    print_ctx(&(prev -> context));
    print_ctx(&(next -> context));
    print_ctx(CTX_IRQ);

    _hang();
}


void task_mm_set(task* t) {
    for(u8 index = 0; index < TASK_MM_TLBS; index++)
        mmu_coarse(
            (void*)(MM_VIRT_USR_START+(index<<MM_SECT_SHIFT)),
            t -> mm_tables[index]);
}


void sched_update_ctx(void) {

}


void sched_printproc(void) {
    register task* next = CURRENT -> next;
    vfb_printf("PROC: %x %x %x\n", next -> PID, next -> entry, next -> prior);

    while(next -> next != CURRENT) {
        vfb_printf("PROC: %x %x %x\n", next -> PID, next -> entry, next -> prior);
        next = next -> next;
    }
}
