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


extern void PUT32 (u32 addr, u32 val);
extern void PUT16 (u32 addr, u16 val);
extern void PUT08 (u32 addr, u8  val);

extern u32 GET32 (u32 addr);
extern u16 GET16 (u32 addr);
extern u8  GET08 (u32 addr);

extern u32 GETPC (void);
extern u32 GETSP (void);
extern u32 GETLR (void);
