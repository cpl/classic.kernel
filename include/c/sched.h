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


#ifndef _INC_SCHED_H
#define _INC_SCHED_H

#include "types.h"
#include "ctx.h"
#include "mmap.h"

// TASK

#define TASK_MAX_MEM 0x02000000
// #define TASK_MM_TLBS ((TASK_MAX_MEM/MM_PAGE_SIZE)/MM_PAGES_PER_TLB)
#define TASK_MM_TLBS 8

typedef enum task_state {
    TASK_STATE_RUNNING,
    TASK_STATE_READY,
    TASK_STATE_SLEEPING,
    TASK_STATE_BLOCKED,
    TASK_STATE_KILLED,
} task_state;
#define TASK_STATE_COUNT 5

typedef enum task_prior {
    TASK_PRIOR_KNL = 0,

    TASK_PRIOR_LOW = 1,
    TASK_PRIOR_MED = 2,
    TASK_PRIOR_HIG = 3,
} task_prior;
#define TASK_PRIOR_COUNT 4

typedef struct task {
    u16           PID;
    u16           flags;

    u32           quantum;

    u32           size;
    void(*entry)(void);

    task_prior    prior;
    task_state    state;

    u16   mm_page_count;
    void* mm_tables[TASK_MM_TLBS];


    struct task* next;
    struct task* prev;

    ctx          context;
} task;

void task_mm_set(task* t);

extern u32 prior_to_qunatum[TASK_PRIOR_COUNT];
extern task** prior_to_list[TASK_PRIOR_COUNT];

// SLEEP

typedef struct sleep_node {
    struct sleep_node* next;
    struct sleep_node* prev;

    task* _t;
    u32   _ms;
} sleep_node;

// SCHED

void sched_init(void);
void sched_next(void);
void sched_tick(void);

u16  sched_pid(void);
void sched_enqueue(task* new);
void sched_sleep(u32 ms);
void sched_wake(void);

#endif
