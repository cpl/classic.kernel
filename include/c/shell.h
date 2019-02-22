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

#define SHELL_BUFFER_SIZE 256
#define SHELL_SYMBOL "\r$.\0"

#define SHELL_HELP_MSG "classic OS - v0.0\ntype shell - v0.0\n"

#define ASCII_NULL  0x00
#define ASCII_BS    0x08
#define ASCII_HT    0x09
#define ASCII_LF    0x0A
#define ASCII_CR    0x0D

void shell_init(void);
void shell_refresh(const char* buf);
void shell_handlecmd(const char* buf);


#endif
