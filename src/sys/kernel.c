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
#include "syscall.h"
#include "stack.h"
#include "asm.h"
#include "error.h"


void _kernel();


task _KERNEL_TASK = {
    PID:   0,
    slice: 1,
    flags: 0,

    size: 0x100,
    entry: &_kernel,

    prior: TASK_PRIOR_LOW,
    state: TASK_STATE_RUNNING,

    mm_page_count: 0,
    mm_tables: {NULL},

    next: &_KERNEL_TASK,
    context: {
        0,0,0,0,0,0,0,0,0,0,0,0,0,
        SP: 0x1800,
        LR: 0x0,
        PC: ((u32)&_kernel),
        CPSR: 0x0000015F,
    },
};


void _kernel() {
    syscall_println("   KERNEL    START: OK");
    while(1);
}