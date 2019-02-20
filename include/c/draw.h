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


#ifndef _INC_DRAW_H
#define _INC_DRAW_H

#include "types.h"

extern const u16* logo;

extern void draw_pixel(u16 color, u32 x, u32 y);
extern void draw_fill_fb(u16 color);
extern void draw_char(char c, u32 x, u32 y);
extern void draw_string(const char* str, u32 x, u32 y);
extern void draw_img(const u16* data, u32 x, u32 y, u32 width, u32 height);

#endif
