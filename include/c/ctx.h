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


/* ctx.h - Context

Define the CPU context and operations to switch, store and restore it.

*/


#ifndef _INC_CTX_H
#define _INC_CTX_H

#include "types.h"

typedef struct ctx {
    u32 R0;
    u32 R1;
    u32 R2;
    u32 R3;

    u32 R4;
    u32 R5;
    u32 R6;
    u32 R7;
    u32 R8;
    u32 R9;
    u32 R10;
    u32 R11;
    u32 R12;

    u32 SP;
    u32 LR;
    u32 PC;

    u32 CPSR;
} ctx;


extern void ctx_scpu(ctx* from, ctx* to);

#endif
