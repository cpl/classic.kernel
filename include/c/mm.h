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


typedef struct mem_block {
	u32			size;
	void*			addr;
	struct mem_block*	next;
} mem_block;


extern void* 		_KERNEL_HEAP;
extern mem_block*	_KERNEL_ALOC;


void* kmalloc(u32 size);
void  kfree(void*  ptr);

void* malloc(u32 size);
void  free(void*  ptr);
void* calloc(u32 size);
void* realloc(void* ptr, u32 size);
