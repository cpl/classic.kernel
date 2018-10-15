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


#include "vfb.h"
#include "mm.h"
#include "conv.h"
#include "memutils.h"
#include "varg.h"
#include "asm.h"


void _memdump(void* ptr, u32 len) {
    u32* p = (u32*)ptr;
    void* bufr = cls_knl_malloc(0x40);

    while(len-- > 0) {
        conv_hex_str(bufr, (u32) p); vfb_print(bufr); vfb_print(" : ");
        conv_hex_str(bufr, (u32)*p); vfb_println(bufr);
        p++;
    }

    cls_knl_free(bufr);
}



void multi_args(int n, ...) {
    va_list vl;
    VA_STA(vl, n);
    VA_SKI(vl, 1);

    void* bufr = cls_knl_malloc(0x80);
    for (int index = 0; index < n; index++) {
        conv_hex_str(bufr, VA_ARG(vl, u32));
        vfb_println(bufr);
    }
    cls_knl_free(bufr);

    VA_END(vl);
}


void print_stack() {
    vfb_print("STACK: ");
    void* bufr = cls_knl_malloc(0x40);
    conv_hex_str(bufr, GETSP());
    vfb_println(bufr);
    cls_knl_free(bufr);
}


void cmain(void) {

    print_stack();

    void* bufr = cls_knl_malloc(0x40);
    conv_hex_str(bufr, 0xDEADBEEF);
    vfb_println(bufr);
    cls_knl_free(bufr);

    print_stack();

    vfb_printf("\nHello, world!\n");
    vfb_printf("Testing printf: %% \t _-.\n");
    vfb_printf("Print a char %c <--- '7'?\n", '7');
    vfb_printf("Printing 42 as hex: %x <--- right there\n", 42, 0);

    vfb_println(NULL);
    vfb_println(NULL);
    vfb_println(NULL);

    vfb_printf("PRINTF MULTI\tARG: %x |+|  |c| %x |+| %x |---| |E| %%\n", 0xDEADBEEF, -1, 0x0);
    vfb_printf("HOW MUCH WOOD WOULD A WOOD CHUCK CHUCK IF A WOULD A WOOD CHUCK CHUCK IF A WOULD A WOOD CHUCK CHUCK IF A WOULD CHUCK COULD CHUCK WOOD, LARGE STRING TEST DISPLAY WRAP TEST LOREM IPSUM ... BLA");


    print_stack();

    multi_args(6, 1, 2, 3, 4, 5, 6);

    print_stack();
}
