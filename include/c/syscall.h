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


#ifndef _INC_SYSCALL_H
#define _INC_SYSCALL_H

extern void syscall_exit(void);
extern void syscall_fork(void);
extern void syscall_kill(void);

extern u32  syscall_time(void);
extern void syscall_sleep(u32 ms);

extern void syscall_uputc(u8 c);
extern void syscall_uputs(char* str);
extern u8   syscall_ugetc(void);

extern void syscall_gpio_set(u8 pin, u8 status);
extern void syscall_gpio_sel(u8 pin, u8 cmd);

extern void syscall_print(char* str);
extern void syscall_println(char* str);
extern void syscall_printf(char* str);

#endif
