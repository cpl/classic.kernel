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



void _kernel() {
    while(1)
        uart_send_string("_kernel();\n\r");
}

static task* CURRENT = NULL;
static task _KERNEL_TASK = {
    PID:   0,
    flags: 0,
    slice: 1,

    size: 0x100,
    entry: &_kernel,

    prior: TASK_PRIOR_MED,
    state: TASK_STATE_RUNNING,

    mm_page_count: 0,
    mm_tables: {NULL, },

    next: &_KERNEL_TASK,
    context: {
        SP: 0x2000,
        PC: (u32)&_kernel,
    },
};


void sched_init() {
    CURRENT = &_KERNEL_TASK;
    ctx_load(&(_KERNEL_TASK.context));
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
    uart_send_string("SCHED TICK\n\r");

    if(--(CURRENT->slice))
        return;

    sched_next();
}


void sched_next() {
    // Update time slice for finished task
    CURRENT -> slice = prior_to_slice[CURRENT -> prior];

    // Check next task
    register task* next = CURRENT -> next;
    if(next == CURRENT) {
        uart_send_string("SCHED SAME PROC\n\r");
        return;
    }

    // Save ref to previous
    task* prev = CURRENT;

    // Skip non-running tasks
    while(next -> state != TASK_STATE_RUNNING)
        next = next -> next;

    // Update memory maps
    task_mm_set(next);

    // Switch CPU context
    ctx_switch(
        &(prev -> context),
        &(next -> context));
}


void task_mm_set(task* t) {
    for(u8 index = 0; index < TASK_MM_TLBS; index++)
        mmu_coarse(
            (void*)(MM_VIRT_USR_START+(index<<MM_SECT_SHIFT)),
            t -> mm_tables[index]);
}
