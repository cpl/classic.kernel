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


#ifndef _INC_SHELL_H
#define _INC_SHELL_H

#include "types.h"
#include "sched.h"

extern task _SHELL_TASK;


#define SHELL_BUFFER_SIZE       512
#define SHELL_SYMBOL            "\r$."
#define SHELL_END               "\n"
#define SHELL_SPLIT_SYMBOL      ':'

#define SHELL_MAX_ARGC          16
#define SHELL_CMD_MAX_LEN       64

#define ASCII_NULL  0x00
#define ASCII_BS    0x08
#define ASCII_HT    0x09
#define ASCII_LF    0x0A
#define ASCII_CR    0x0D

extern void shell_init(void);
extern void shell_refresh(const char* buf);
extern void shell_handlecmd(char* buf);

extern void _shell_arg_debug(u32 argc, char* argv[]);



// CMD

// cmd function format
typedef void (*cmd_ptr)(u32 argc, char* argv[]);

extern void _cmd_undefined(u32 argc, char* argv[]);
extern void _cmd_help(u32 argc, char* argv[]);
extern void _cmd_clear(u32 argc, char* argv[]);
extern void _cmd_time(u32 argc, char* argv[]);
extern void _cmd_gpio(u32 argc, char* argv[]);
extern void _cmd_mem(u32 argc, char* argv[]);



extern void _cmd_notfound();

#define _CMD_ID_HELP    0
#define _CMD_ID_CLEAR   1
#define _CMD_ID_REBOOT  2
#define _CMD_ID_TIME    3
#define _CMD_ID_GPIO    4
#define _CMD_ID_MEM     5


static const char SHELL_CMDID_CMDSTR[][SHELL_BUFFER_SIZE] = {
    [_CMD_ID_HELP]      = "help",
    [_CMD_ID_CLEAR]     = "clear",
    [_CMD_ID_REBOOT]    = "reboot",
    [_CMD_ID_TIME]      = "time",
    [_CMD_ID_GPIO]      = "gpio",
    [_CMD_ID_MEM]       = "mem",
};

static const char SHELL_CMDID_CMDINS[][SHELL_CMD_MAX_LEN] = {
    [_CMD_ID_HELP]      = "display this help message",
    [_CMD_ID_CLEAR]     = "clear the framebuffer using the background color",
    [_CMD_ID_REBOOT]    = "restart the operating system",
    [_CMD_ID_TIME]      = "display the system time",
    [_CMD_ID_GPIO]      = "control LOW/HIGH and FN SEL of GPIO",
    [_CMD_ID_MEM]       = "allows for on memory operations",
};

static const cmd_ptr SHELL_CMDID_CMDFN[] = {
    [_CMD_ID_HELP]      = _cmd_help,
    [_CMD_ID_CLEAR]     = _cmd_clear,
    [_CMD_ID_REBOOT]    = _cmd_undefined,
    [_CMD_ID_TIME]      = _cmd_time,
    [_CMD_ID_GPIO]      = _cmd_gpio,
    [_CMD_ID_MEM]       = _cmd_mem,
};


#define SHELL_CMD_LIMIT (sizeof(SHELL_CMDID_CMDSTR)/(SHELL_BUFFER_SIZE))
#define SHELL_CMD_MAX SHELL_CMD_LIMIT-1

#endif
