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


/* memutils.h - Memory handling functions

Utility functions that zero, move, copy and handle memory in general. Used by
many other libraries.

*/


#include "types.h"


extern void memzero(void*, u32);
extern void memcopy(void*, u32, void*);
extern void memmove(void*, u32, void*);
extern void memcomp(void*, void*);

extern void memset_b(void*, u8 );
extern void memset_h(void*, u16);
extern void memset_w(void*, u32);
