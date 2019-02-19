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


#include "stack.h"
#include "uart.h"
#include "syscall.h"


void stack_dump(void* addr, u32 SP) {
    syscall_uputs("STACK DUMP\n\r\n\r");

    u32* p = (u32*)addr;

    syscall_uputs("STACK: "); syscall_uputx((u32)p); syscall_uputs("\n\r");
    syscall_uputs("SP:    "); syscall_uputx(SP); syscall_uputs("\n\r\n\r");

    while((u32)p >= SP) {
        syscall_uputx((u32)(p)); syscall_uputs(" : "); syscall_uputx(*p);
        syscall_uputs("\n\r");
        p--;
    }

    syscall_uputs("\n\r");
}

