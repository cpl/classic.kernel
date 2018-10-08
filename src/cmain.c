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


#include "cls.stdlib.h"
#include "asm.h"
#include "vfb.h"


extern void* _KERNEL_HEAP;
extern void* _KERNEL_ALOC;

void cmain(void) {


    vfb_println(strtmp_hex((u32)&_KERNEL_HEAP));
    vfb_println(strtmp_hex((u32)&_KERNEL_ALOC));
    vfb_println(strtmp_hex((u32)&_KERNEL_HEAP+1));
}
