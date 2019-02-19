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

/* stack.h - Stack operations and constants

*/


#ifndef _INC_STACK_H
#define _INC_STACK_H

#include "types.h"

#define _STACK_SYS 0x3C00
#define _STACK_SVC 0x2400
#define _STACK_ABT 0x2800
#define _STACK_IRQ 0x2C00

void stack_dump(void* addr, u32 SP);

#endif
