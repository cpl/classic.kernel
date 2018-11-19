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


#include "error.h"
#include "stack.h"
#include "asm.h"
#include "bool.h"
#include "syscall.h"


void _panic(const char* msg) {
    // Print error message
    syscall_uputs("\n\r\n\rPANIC: ");
    syscall_uputs(msg);
    syscall_uputs("\n\r");

    // Print LR
    syscall_uputs("LR: ");
    syscall_uputx(GETLR());
    syscall_uputs("\n\r");

    // Print SYS stack
    stack_dump(_STACK_SYS, _STACK_SYS-0x40);

    // Print SVC stack
    stack_dump(_STACK_SVC, _STACK_SVC-0x40);

    // HANG
    syscall_uputs("HANG\n\r");
    while(TRUE){};
}
