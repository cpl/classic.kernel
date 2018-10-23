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
#include "ctx.h"
#include "mmap.h"


#ifndef _INC_SCHED_H
#define _INC_SCHED_H

// CONTEXT

static ctx* CTX_IRQ = (ctx*)(0x2C00-0x40);


// TASK

#define TASK_MAX_MEM 0x02000000
#define TASK_MM_TLBS (TASK_MAX_MEM/MM_PAGE_SIZE)/MM_PAGES_PER_TLB


typedef enum task_state {
    TASK_STATE_RUNNING,
    TASK_STATE_READY,
    TASK_STATE_ZOMBIE,
    TASK_STATE_IDLE,

    TASK_STATE_COUNT = 4,
} task_state;

typedef enum task_prior {
    TASK_PRIOR_LOW = 0,
    TASK_PRIOR_MED = 1,
    TASK_PRIOR_HIG = 2,

    TASK_PRIOR_COUNT = 3,
} task_prior;

typedef struct task {

    u16           PID;
    u16           slice;
    u16           flags;

    u32           size;
    void*         entry;

    task_prior    prior;
    task_state    state;

    u32   mm_page_count;
    void* mm_tables[TASK_MM_TLBS];


    struct task* next;
    ctx          context;
} task;

void task_mm_set(task* t);

// SCHED

void sched_enqueue(task* new);
void sched_next(void);
void sched_tick(void);
void sched_init(void);

void sched_printproc(void);

#endif