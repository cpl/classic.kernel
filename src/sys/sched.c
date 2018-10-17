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


#include "bool.h"
#include "types.h"
#include "sched.h"
#include "mmu.h"


static task* CURRENT = NULL;
static task* TASKS[SCHED_MAX_TASKS];
static u8    TASK_COUNT = 1;


void sched_switch(task* to) {
    // Ignore if trying to switch to current task
    if(to == CURRENT)
        return;

    // Update current task
    task* prev = CURRENT;
    CURRENT = to;

    // Switch coarse table
    mmu_coarse((void*)_USR_VIRT_START, to -> pagemap.coarse_tlb);

    // Switch CPU context
    ctx_switch(
        &(prev -> context),
        &(to   -> context));
}


void sched_tick(void) {
    // Decrement current task time slice
    if(--(CURRENT -> slice) > 0)
        return;

    // Schedule next task
    sched();
}


void sched(void) {
    task* check;

    while(TRUE) {
        for(u8 index = 0; index < SCHED_MAX_TASKS; index++) {
            check = TASKS[index];
            if(check && check -> state == RUNNING) {
                break;
            }
        }
        if(check -> slice) {
            break;
        }
    }

    sched_switch(check);
}
