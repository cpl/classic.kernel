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


#ifndef _INC_VFB_H
#define _INC_VFB_H

extern void vfb_print(const char* str);
extern void vfb_printf(const char* fmt, ...);
extern void vfb_println(const char* str);
extern void vfb_printdump(void* addr, unsigned int len);

extern void vfb_scroll(void);
extern void vfb_reset(void);
extern void vfb_clear(void);

#define print vfb_print
#define println vfb_println
#define printf vfb_printf
#define printdump vfb_printdump

#endif
