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
#include "memutil.h"
#include "asm.h"
#include "mm.h"
#include "error.h"
#include "ctx.h"


// Timestamp used to determine premtive scheduling based on time quantum
static u32 entry_timestamp = 0;

// Location of context saved by interrupt exception
static ctx* CTX_IRQ = (ctx*)(0x2C00-0x40);

// Kernel main task
extern task _KERNEL_TASK;

// Current executed task
static task* CURRENT = &_KERNEL_TASK;

// Priority round robins
static task* _TASK_LOW = NULL;
static task* _TASK_MED = NULL;
static task* _TASK_HIG = NULL;

// TODO implement sleeping queue
// Sleeping queue
// static task* _TASK_SLEEPING = NULL;


// List of task quantum size based on priority
u32 prior_to_qunatum[TASK_PRIOR_COUNT] = {
    [TASK_PRIOR_LOW] = 5000,
    [TASK_PRIOR_MED] = 7500,
    [TASK_PRIOR_HIG] = 10000,
};

// Pointers to task priority lists based on task priority
task** prior_to_list[TASK_PRIOR_COUNT] = {
    [TASK_PRIOR_LOW] = &_TASK_LOW,
    [TASK_PRIOR_MED] = &_TASK_MED,
    [TASK_PRIOR_HIG] = &_TASK_HIG,
};


// Initialize kernel task for idle state
void sched_init() {
    syscall_println(" SCHEDULER START: OK");
    CURRENT -> entry();
}


void sched_enqueue(register task* new) {
    // Get the priority list current task
    task** plist = prior_to_list[new -> prior];

    // Set as first task in priority round robin, if it's empty or append it
    // as the next task to the current task in the round robin
    if (*plist == NULL) {
        *plist = new;
        new -> next = new;
    } else {
        new -> next = (*plist) -> next;
        (*plist) -> next = new;
    }

    // Mark newly added task as READY and set the quantum
    new -> state = TASK_STATE_READY;
    new -> quantum = prior_to_qunatum[new -> prior];
}


void sched_tick() {

    // ! DEBUG
    // If no running task, panic
    if(CURRENT == NULL || CURRENT -> state != TASK_STATE_RUNNING)
        _panic("no active running task");

    // Check time quantum and continue if within limits
    if(syscall_time() < entry_timestamp + CURRENT -> quantum)
        return;

    // Imidiatlly attempt to schedule next task
    if(CURRENT == &_KERNEL_TASK)
        return sched_next();

    // Set current task as READY after RUNNING
    CURRENT -> state = TASK_STATE_READY;

    // Set the next task in the list
    task** plist = prior_to_list[CURRENT -> prior];
    *plist = CURRENT -> next;

    // And schdule next task
    sched_next();
}


void sched_next() {

    task* prev = CURRENT;
    task* next = &_KERNEL_TASK;
    task* temp;

    // Decide from which list to take a task, fallback is KERNEL TASK
    if(_TASK_LOW != NULL) {
        next = _TASK_LOW;
    }
    if(_TASK_MED != NULL) {
        next = _TASK_MED;
    }
    if(_TASK_HIG != NULL) {
        next = _TASK_HIG;
    }

    // Search for a READY task
    temp = next;
    while(temp -> state != TASK_STATE_READY) {
        temp = temp -> next;

        // Searched entire list, fallback to kernel task
        if(temp == next) {
            next = &_KERNEL_TASK;
            break;
        }
    }

    // Update next task with the proper task
    next = temp;
    next -> state = TASK_STATE_RUNNING;

    // Update entry timestamp
    entry_timestamp = syscall_time();

    // If same task, return without switching context
    if(next == prev) {
        return;
    }

    // Update CURRENT task
    CURRENT = next;

    // Update memory maps
    // task_mm_set(next);

    // Perform context switch
    memcopy(CTX_IRQ, sizeof(ctx), &(prev -> context));
    memcopy(&(next -> context), sizeof(ctx), CTX_IRQ);
    ctx_scpu(&(prev -> context), &(next -> context));
}


void task_mm_set(task* t) {
    for(u8 index = 0; index < TASK_MM_TLBS; index++)
        for(u8 tindex = 0x0; tindex < 0x1000; tindex+=0x400)
            mmu_coarse(
                (void*)(MM_VIRT_USR_START+(index<<MM_SECT_SHIFT)),
                t -> mm_tables[index]+tindex);
}


void task_mm_add(task* t, u32 page_count) {

    // Optimie frequent variables
    register void** mm_tables = t -> mm_tables;
    register u16    mm_page_count = t -> mm_page_count;

    // Allocate coarse tables for task, within the needed range
    for(register u8 tindex = 0; tindex <= (mm_page_count + page_count)>>10; tindex++)
        if(mm_tables[tindex] == NULL)
            mm_tables[tindex] = mmap_aloc_page();

    // Allocate requested pages in the coarse table and page handler
    for(register u16 pindex = mm_page_count; pindex < (mm_page_count + page_count); pindex++)
        mmu_page((void*)MM_VIRT_USR_START, mmap_aloc_page(), 0xFF0, mm_tables[pindex>>10]);
}


void task_free(task* t) {

}


task* sched_spawn(void* entry, u32 size, u16 flags, task_prior prior) {
    register task* new = mmap_aloc_page();

    size += MM_USR_STACK_SIZE;
    size += ((MM_PAGE_SIZE - (size & MM_PAGE_SIZE_MASK)) & MM_PAGE_SIZE_MASK);

    if(size > TASK_MAX_MEM)
        size = TASK_MAX_MEM;

    new -> size = size;
    new -> PID = 5;

    new -> flags = flags;
    new -> prior = prior;
    new -> state = TASK_STATE_READY;

    new -> entry = entry;
    // new -> entry = (void*)MM_VIRT_USR_BEGIN;
    memcopy(entry, size, new -> entry);

    new -> context.PC = (u32)(entry);
    new -> context.SP = MM_VIRT_USR_STACK;
    new -> context.CPSR = 0x0000015F;

    task_mm_add(new, size>>MM_PAGE_SHIFT);

    return new;
}
