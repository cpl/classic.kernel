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


#include "sched.h"
#include "mmap.h"
#include "mmu.h"
#include "uart.h"
#include "memutil.h"
#include "asm.h"
#include "mm.h"
#include "error.h"
#include "ctx.h"
#include "vfb.h"
#include "clk.h"


// // Timestamp used to determine premtive scheduling based on time quantum
// static u32 entry_timestamp = 0;

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

// Sleeping queue
static sleep_node* _TASK_SLEEPING = NULL;


// List of task quantum size based on priority
u32 prior_to_qunatum[TASK_PRIOR_COUNT] = {
    [TASK_PRIOR_KNL] = 1000,

    [TASK_PRIOR_LOW] = 100000,
    [TASK_PRIOR_MED] = 200000,
    [TASK_PRIOR_HIG] = 300000,
};

// Pointers to task priority lists based on task priority
task** prior_to_list[TASK_PRIOR_COUNT] = {
    [TASK_PRIOR_KNL] = NULL,

    [TASK_PRIOR_LOW] = &_TASK_LOW,
    [TASK_PRIOR_MED] = &_TASK_MED,
    [TASK_PRIOR_HIG] = &_TASK_HIG,
};


// Initialize kernel task for idle state
void sched_init() {
    clk_sys_init(CURRENT -> quantum);
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
        new -> prev = new;
    } else {
        new -> next = (*plist) -> next;
        new -> prev = (*plist);
        (*plist) -> next = new;
    }

    // Mark newly added task as READY and set the quantum
    new -> state = TASK_STATE_READY;
    new -> quantum = prior_to_qunatum[new -> prior];
}


void sched_tick() {

    // printf(".");

    // Panic if no current task
    if(CURRENT == NULL)
        _panic("CURRENT task is NULL");

    // Get time and check sleeping Q
    u32 t = clk_sys_epoch();
    if(_TASK_SLEEPING != NULL && t > _TASK_SLEEPING -> _ms)
        sched_wake();

    // Imidiatlly attempt to schedule next task
    if(CURRENT == &_KERNEL_TASK)
        return sched_next();

    // Current task is no longer running, schedule another
    if(CURRENT -> state != TASK_STATE_RUNNING)
        return sched_next();

    // // Check time quantum and continue if within limits
    // if(t < entry_timestamp + CURRENT -> quantum)
    //     return;

    // Set current task as READY after RUNNING
    CURRENT -> state = TASK_STATE_READY;

    // Set the next task in the list
    task** plist = prior_to_list[CURRENT -> prior];
    *plist = CURRENT -> next;

    // And schdule next task
    sched_next();
}


void sched_next() {
    task* prev = CURRENT;           // save current task as "previous"
    task* next = &_KERNEL_TASK;

    // Decide from which list to take a task, fallback is KERNEL TASK

    if(_TASK_HIG != NULL) {
        next = _TASK_HIG;
        while(next -> state != TASK_STATE_READY) {
            next = next -> next;

            if(next == _TASK_HIG)
                goto _sched_next_check_med;
        }
        goto _sched_next_prep;
    }


    _sched_next_check_med:
    if(_TASK_MED != NULL) {
        next = _TASK_MED;
        while(next -> state != TASK_STATE_READY) {
            next = next -> next;

            if(next == _TASK_MED)
                goto _sched_next_check_low;
        }
        goto _sched_next_prep;
    }

    _sched_next_check_low:
    if(_TASK_LOW != NULL) {
        next = _TASK_LOW;
        while(next -> state != TASK_STATE_READY) {
            next = next -> next;
        }
    }


    _sched_next_prep:
    if(next -> state != TASK_STATE_READY)
        next = &_KERNEL_TASK;
    // else
        // entry_timestamp = clk_sys_epoch();

    clk_sys_isr(next -> quantum);

    // Set task as running
    next -> state = TASK_STATE_RUNNING;

    // If same task, return without switching context
    if(next == prev)
        return;

    // Update CURRENT task
    CURRENT = next;
    CURRENT -> quantum = prior_to_qunatum[CURRENT -> prior];

    // Update memory maps
    // task_mm_set(next);

    // Perform context switch
    memcopy(CTX_IRQ, sizeof(ctx), &(prev -> context));
    memcopy(&(next -> context), sizeof(ctx), CTX_IRQ);
    ctx_scpu(&(prev -> context), &(next -> context));
}


// sched_pid returns the PID of the CURRENT running task
u16 sched_pid() {
    return CURRENT -> PID;
}


// sched_sleep puts the CURRENT running task to sleep for the given number
// of miliseconds
void sched_sleep(u32 ms) {

    // ignore
    if(CURRENT -> state != TASK_STATE_RUNNING)
        return;

    // transform given miliseconds into TIME + miliseconds_to_wake_up_after
    ms = clk_sys_epoch() + ms*1000;

    // first sleeping node
    if(_TASK_SLEEPING == NULL) {

        _TASK_SLEEPING = (sleep_node*)kmalloc(sizeof(sleep_node));

        _TASK_SLEEPING -> _t   = CURRENT;
        _TASK_SLEEPING -> _ms  = ms;
        _TASK_SLEEPING -> next = NULL;
        _TASK_SLEEPING -> prev = NULL;

        CURRENT -> state = TASK_STATE_SLEEPING;

        CURRENT -> quantum = 0;
        return;
    }


    // find insert position
    sleep_node* node = _TASK_SLEEPING;
    while(node -> next != NULL && ms > node -> _ms) {
        node = node -> next;
    }

    // left
    if(ms < node -> _ms) {
        // left new
        if(node -> prev == NULL) {
            node -> prev = (sleep_node*)kmalloc(sizeof(sleep_node));
            node -> prev -> next = node;

            node = node -> prev;

            node -> prev = NULL;
            node -> _t   = CURRENT;
            node -> _ms  = ms;

            _TASK_SLEEPING = node;

            CURRENT -> state = TASK_STATE_SLEEPING;

            CURRENT -> quantum = 0;
            return;
        }

        // left insert
        sleep_node* new_node = (sleep_node*)kmalloc(sizeof(sleep_node));
        new_node -> _ms = ms;
        new_node -> _t  = CURRENT;

        node -> prev -> next = new_node;
        new_node -> prev = node -> prev;
        new_node -> next = node;
        node -> prev = new_node;

        CURRENT -> state = TASK_STATE_SLEEPING;

        CURRENT -> quantum = 0;
        return;
    }


    // Append sleep node at the end of sleep q
    node -> next = (sleep_node*)kmalloc(sizeof(sleep_node));
    node -> next -> prev = node;
    node = node -> next;
    node -> _ms  = ms;
    node -> _t   = CURRENT;
    node -> next = NULL;

    CURRENT -> quantum = 0;
    return;
}


// sched_wake will wake up the FIRST task and only the first task from the
// sleeping q. Next sleeping tasks will be handled on the next tick.
void sched_wake() {
    // mark task as READY
    _TASK_SLEEPING -> _t -> state = TASK_STATE_READY;

    // if removing the only item, free, set NULL and return
    if(_TASK_SLEEPING -> next == NULL) {
        kfree(_TASK_SLEEPING);
        _TASK_SLEEPING = NULL;
        return;
    }

    // if other items in Q, set next as head of sleeping Q then free the
    // previous node (first node) and mark prev as NULL
    _TASK_SLEEPING = _TASK_SLEEPING -> next;
    kfree(_TASK_SLEEPING -> prev);
    _TASK_SLEEPING -> prev = NULL;

    return;
}


/*
void task_mm_set(task* t) {
    for(u8 index = 0; index < TASK_MM_TLBS; index++)
        for(u8 tindex = 0x0; tindex < 0x1000; tindex+=0x400)
            mmu_coarse(
                (void*)(MM_VIRT_USR_START+(index<<MM_SECT_SHIFT)),
                t -> mm_tables[index]+tindex);
}



! DEBUG
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
*/