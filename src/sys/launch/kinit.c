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
#include "sched.h"
#include "syscall.h"
#include "error.h"
#include "vfb.h"
#include "asm.h"
#include "draw.h"
#include "shell.h"
#include "sd.h"
#include "fat.h"
#include "conv.h"


void _low0();
void _low1();
void _low2();


void _high();
void _kbd();

task _LOW0 = {
    PID:   1,
    quantum: 5000,
    flags: 0,

    size: 0x100,
    entry: &_low0,

    prior: TASK_PRIOR_LOW,
    state: TASK_STATE_READY,

    mm_page_count: 0,
    mm_tables: {NULL},

    next: NULL,
    context: {
        0,0,0,0,0,0,0,0,0,0,0,0,0,
        SP: 0x1600,
        LR: 0x0,
        PC: ((u32)&_low0),
        CPSR: 0x0000015F,
    },
};



task _LOW1 = {
    PID:   2,
    quantum: 5000,
    flags: 0,

    size: 0x100,
    entry: &_low1,

    prior: TASK_PRIOR_LOW,
    state: TASK_STATE_READY,

    mm_page_count: 0,
    mm_tables: {NULL},

    next: NULL,
    context: {
        0,0,0,0,0,0,0,0,0,0,0,0,0,
        SP: 0x1400,
        LR: 0x0,
        PC: ((u32)&_low1),
        CPSR: 0x0000015F,
    },
};


task _LOW2 = {
    PID:   2,
    quantum: 5000,
    flags: 0,

    size: 0x100,
    entry: &_low2,

    prior: TASK_PRIOR_LOW,
    state: TASK_STATE_READY,

    mm_page_count: 0,
    mm_tables: {NULL},

    next: NULL,
    context: {
        0,0,0,0,0,0,0,0,0,0,0,0,0,
        SP: 0x1400,
        LR: 0x0,
        PC: ((u32)&_low2),
        CPSR: 0x0000015F,
    },
};

task _HIGH = {
    PID:   10,
    quantum: 5000,
    flags: 0,

    size: 0x100,
    entry: &_high,

    prior: TASK_PRIOR_HIG,
    state: TASK_STATE_READY,

    mm_page_count: 0,
    mm_tables: {NULL},

    next: NULL,
    context: {
        0,0,0,0,0,0,0,0,0,0,0,0,0,
        SP: 0x1400,
        LR: 0x0,
        PC: ((u32)&_high),
        CPSR: 0x0000015F,
    },
};

task _KBD = {
    PID:   20,
    quantum: 5000,
    flags: 0,

    size: 0x100,
    entry: &_kbd,

    prior: TASK_PRIOR_LOW,
    state: TASK_STATE_READY,

    mm_page_count: 0,
    mm_tables: {NULL},

    next: NULL,
    context: {
        0,0,0,0,0,0,0,0,0,0,0,0,0,
        SP: 0x1400,
        LR: 0x0,
        PC: ((u32)&_kbd),
        CPSR: 0x0000015F,
    },
};


void _low0() {
    while(1) {
        syscall_gpio_set(23, 0);
        syscall_gpio_sel(23, 1);

        for(u32 i = 2000000; i; i--)
            __asm__("MOV R0, R0");

        syscall_gpio_set(23, 1);
        syscall_gpio_sel(23, 1);

        for(u32 i = 2000000; i; i--)
            __asm__("MOV R0, R0");
    }
}

void _low1() {
    while(1) {
        syscall_gpio_set(18, 0);
        syscall_gpio_sel(18, 1);

        for(u32 i = 1000000; i; i--)
            __asm__("MOV R0, R0");

        syscall_gpio_set(18, 1);
        syscall_gpio_sel(18, 1);

        for(u32 i = 1000000; i; i--)
            __asm__("MOV R0, R0");
    }
}

void _low2() {
    while(1) {
        syscall_gpio_set(24, 0);
        syscall_gpio_sel(24, 1);

        for(u32 i = 3000000; i; i--)
            __asm__("MOV R0, R0");

        syscall_gpio_set(24, 1);
        syscall_gpio_sel(24, 1);

        for(u32 i = 3000000; i; i--)
            __asm__("MOV R0, R0");
    }
}


void _high() {
    while(1) {
        for(u16 i = 20; i; i--) {
            printf("_high(!priority!);\n");
        }
        syscall_sleep(10000);
    }
}



// ! DEBUG test code code keyboard
void _kbd() {
    char* c = "\0\0";
    while(1) {
        *c = syscall_getc();
        printf(c);
    }
}


// ----



void _kinit(void) {
    // 0xF1F0CAFE signature on entry
    syscall_uputx(0xF1F0CAFE); syscall_uputnl();

    // Start microSD drivers
    unsigned int cluster;
    if(sd_init() == SD_OK) {
        printf(" SD DRIVERS: OK\n");

        // read the master boot record and find our partition
        if(fat_getpartition()) {
            printf(" SD MBR: OK\n");

            cluster = fat_getcluster("ROOT       ");
            if(!cluster) {
                printf(" SD FAILED TO FIND FS ROOT CLUSTER\n");
            } else {
                printf(" SD FS ROOT CLUSTER: %x\n", cluster);
                char* rdata = fat_readfile(cluster);
                printf("\n-----------------------------------\n");
                vfb_printdump(rdata, 512);
                printf("\n-----------------------------------\n");
            }
        } else {
            printf(" SD MBR: ERR!\n");
        }
    } else {
        printf(" SD DRIVERS: ERR!\n");
    }

    // ! DEBUG mmap intial allocations
    printf("\n MMAP INITIAL ALLOCATIONS\n");
    printf("   PHYS MEM SYS: %x\n",   MM_PHYS_SYS);
    printf("   PHYS MEM GPU: %x\n",   MM_PHYS_GPU);
    printf("   PHYS MEM KNL: %x\n",   MM_PHYS_KNL);
    printf("   PHYS MEM LIB: %x\n",   MM_PHYS_LIB);
    printf("   PHYS MEM USR: %x\n\n", MM_PHYS_USR);
    printf("   PAGE COUNT: %x\n\n",   MM_PAGES_TTL);

    draw_img((u16*)&logo, 950, 0, 250, 250);


    // Queue demo tasks
    // sched_enqueue(&_LOW0);
    // sched_enqueue(&_LOW0);
    // sched_enqueue(&_LOW1);
    // sched_enqueue(&_LOW2);

    printf("\n-----------------------------------\n");
    vfb_printdump((unsigned char*)0x00200000, 512);
    printf("\n-----------------------------------\n");

    vfb_printdump((unsigned char*)0x00200000+512, 512);
    printf("\n-----------------------------------\n");

    vfb_printdump((unsigned char*)0x00200000+1024, 512);
    printf("\n-----------------------------------\n");

    vfb_printdump((unsigned char*)0x00200000+1536, 512);
    printf("\n-----------------------------------\n");

    // Pass execution control to scheduler
    sched_enqueue(&_SHELL_TASK);
    sched_init();

    // Catch
    _panic("catch scheduler ilegal exit");
}
