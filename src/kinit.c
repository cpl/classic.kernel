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
#include "error.h"
#include "vfb.h"


void _kinit(void) {
    // DEADBEEF on entry
    syscall_uputx(0xDEADBEEF); syscall_uputnl();

    // ! DEBUG mmap intial allocations
    vfb_println("\n MMAP INITIAL ALLOCATIONS");
    vfb_printf("   PHYS MEM SYS: %x\n",   MM_PHYS_SYS);
    vfb_printf("   PHYS MEM GPU: %x\n",   MM_PHYS_GPU);
    vfb_printf("   PHYS MEM KNL: %x\n",   MM_PHYS_KNL);
    vfb_printf("   PHYS MEM LIB: %x\n",   MM_PHYS_LIB);
    vfb_printf("   PHYS MEM USR: %x\n\n", MM_PHYS_USR);
    vfb_printf("   PAGE COUNT: %x\n\n", MM_PAGES_TTL);

    // Queue initial tasks


    // Pass execution control to scheduler
    sched_init();

    // Catch
    _panic("catch kernel ilegal exit");
}
