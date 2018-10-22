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


.globl sys_exit, sys_fork, sys_kill, sys_time, sys_sleep, sys_uputc, sys_uputs
.globl sys_ugetc, sys_gpio_set, sys_gpio_sel, sys_print, sys_println, sys_printf

.set	sys_exit,	0x0	// void sys_exit(void)
.set	sys_fork,	0x1	// void sys_fork(void)
.set	sys_kill,	0x2	// void sys_kill(void)

.set	sys_time,	0x3	// u32  sys_time(void)
.set	sys_sleep,	0x4	// void sys_sleep(u32 ms)

.set	sys_uputc,	0x5	// void sys_uputc(u8 c)
.set	sys_uputs,	0x6	// void sys_uputs(u8* str)
.set	sys_ugetc,	0x7	// u8   sys_ugetc(void)

.set	sys_gpio_set,	0x8	// void sys_gpio_set(u8 pin, u8 status)
.set	sys_gpio_sel,	0x9	// void sys_gpio_sel(u8 pin, u8 cmd)

.set	sys_print,	0xA	// void sys_print(char* str)
.set	sys_println,	0xB	// void sys_println(char* str)
.set	sys_printf,	0xC	// void sys_printf(char* str, ...)
