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


#include "types.h"
#include "draw.h"
#include "syscall.h"


void draw_img(const u16* data, u32 x, u32 y, u32 width, u32 height) {
    if(data == NULL)
        return;

    u32 dx =  width-1;
    u32 dy = height-1;

    while(dy) {
        while(dx) {
            draw_pixel(data[dy*width+dx], x+dx, y+dy);
            dx--;
        }

        dy--;
        dx = width-1;
    }

    return;
}