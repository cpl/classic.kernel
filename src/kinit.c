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


void _nothing(void) {
    while(1) {
        syscall_uputs("2");
    }
}

void _andanotherone(void) {
    while(1) {
        syscall_uputs("3");
    }
}


void _kinit(void) {
    // DEADBEEF on entry
    syscall_uputx(0xDEADBEEF); syscall_uputnl();

    // sched_enqueue(sched_spawn(&_nothing, 0xA37F, 0, TASK_PRIOR_MED));
    // sched_enqueue(sched_spawn(&_andanotherone, 0x100, 0, TASK_PRIOR_LOW));

    // Pass execution control to scheduler
    sched_init();

    // Catch
    syscall_uputs("_hang_main();\n\r");
    while(1);
}
