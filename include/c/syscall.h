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


#ifndef _INC_SYSCALL_H
#define _INC_SYSCALL_H

#include "types.h"

extern void syscall_exit(void);
extern void syscall_kill(void);
extern void syscall_spawn(void);
extern void syscall_yield(void);

extern u32  syscall_time(void);
extern void syscall_sleep(u32 ms);

extern void syscall_uputc(u8 c);
extern void syscall_uputs(char* str);
extern void syscall_uputx(u32 val);
extern u8   syscall_ugetc(void);
extern void syscall_uputnl(void);

extern void syscall_gpio_set(u8 pin, u8 status);
extern void syscall_gpio_sel(u8 pin, u8 cmd);

extern void syscall_print(const char* str);
extern void syscall_println(const char* str);
extern void syscall_printf(const char* fmt, ...);

extern void* syscall_kmalloc(u32 size);
extern void* syscall_kcalloc(u32 size);
extern void  syscall_kfree(void* addr);

extern void  syscall_cdraw(u8 c, u16 x, u16 y);
extern void  syscall_fdraw(u16 color);
extern void  syscall_sdraw(char* str, u16 x, u16 y);

#endif
