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

#define SCHED_MAX_TASKS 0x100
#define TASKS_MAX_PAGES 0x100

typedef struct task_mmap {
    u32 count;
    u32 pages[TASKS_MAX_PAGES];
} task_mmap;


typedef enum {
    RUNNING,
    READY,
    BLOCKED,
    IDLE,
} task_state;

typedef enum {
    LOW,
    MED,
    HIG,
} task_prior;

typedef struct task {
    u16         PID;
    task_state  state;
    task_prior  prior;
    u8          slice;
    u8          flags;

    ctx       context;
    task_mmap pagemap;
} task;


void sched_switch(task* to);
void sched_tick(void);
void sched(void);

#endif
