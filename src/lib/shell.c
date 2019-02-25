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


#include "shell.h"
#include "syscall.h"
#include "vfb.h"
#include "bool.h"
#include "string.h"


void shell_init() {
    // create buffer for storing chars as they come in from the user
    char* CMD_BUFFER = syscall_kmalloc(SHELL_BUFFER_SIZE);
    // a pointer to the end of the command string on the command buffer
    char* CMD_CURSOR = CMD_BUFFER;

    // set first char as NULL and display shell
    *CMD_CURSOR = ASCII_NULL;
    shell_refresh(CMD_BUFFER);

    while(TRUE) {
        // read char from keyboard
        char c = syscall_getc();

        switch(c) {
            // ignore no key press
            case ASCII_NULL:
                break;
            // backspace, go back in buffer and replace char with space and move
            // string terminator, ignoring left most position on buffer
            case ASCII_BS:
                if(CMD_CURSOR == CMD_BUFFER)
                    break;

                *CMD_CURSOR = ASCII_NULL;
                CMD_CURSOR--;
                *CMD_CURSOR = ' ';

                shell_refresh(CMD_BUFFER);
                break;

            // catch escape chars
            // case '\\':
            // case '%':

            // new line (enter), trigger command handling and buffer reset
            // * dev note, could implement a history list of command by keeping
            // * the buffer pointers and allocating new ones on each command
            case ASCII_LF:
                shell_handlecmd(CMD_BUFFER);

                // reset buffer
                CMD_CURSOR = CMD_BUFFER; *CMD_CURSOR = ASCII_NULL;
                shell_refresh(CMD_BUFFER);
                break;
            // normal behaviour is to write the given char to the buffer,
            // checking that the command is within SHELL_BUFFER_SIZE
            default:
                if(CMD_CURSOR == CMD_BUFFER+SHELL_BUFFER_SIZE)
                    break;

                *CMD_CURSOR = c; CMD_CURSOR++; *CMD_CURSOR = ASCII_NULL;
                shell_refresh(CMD_BUFFER);
        }
    }

    syscall_kfree(CMD_BUFFER);
}


void shell_refresh(const char* buf) {
    printf(SHELL_SYMBOL);
    printf(buf);

    return;
}


void shell_handlecmd(char* buf) {
    printf("\n");

    // ignore empty buffer
    if(*buf == ASCII_NULL)
        return;

    char* argv[SHELL_MAX_ARGC];             // store argv pointers
    argv[0]  = buf;                         // first argv is the command
    u32 argc = 1;                           // count of arguments

    // scan buffer for argc and argv
    while(*buf) {

        if(*buf == SHELL_SPLIT_SYMBOL) {    // check for split symbol
            *buf = ASCII_NULL;              // null pad argv
            argv[argc++] = (buf+1);         // set argv ptr start at next char
        }

        buf++;                              // move forward
    }

    // at this point argv[0] is the command
    _shell_arg_debug(argc, argv);
    return;

    // search commands
    for(u32 idx = 0; idx < SHELL_CMD_LIMIT; idx++) {

        // if match command
        if(strequ(argv[0], SHELL_CMDID_CMDSTR[idx])) {
            SHELL_CMDID_CMDFN[idx]();

            printf(SHELL_END);
            return;
        }
    }

    _cmd_notfound();
    printf(SHELL_END);
    return;
}


// CMD

void _cmd_undefined(void) {
    printf("sorry, function not implemented");
}


void _cmd_notfound(void) {
    printf("sorry, function not found, for more details type 'help'");
}


void _cmd_help(void) {
    printf("classic OS, type shell\navailable commands:\n\n");
    for(u32 idx = 0; idx < SHELL_CMD_LIMIT; idx++) {
        printf("  ");
        printf(SHELL_CMDID_CMDSTR[idx]);
        printf(" - ");
        printf(SHELL_CMDID_CMDINS[idx]);
        printf(SHELL_END);
    }
}


void _shell_arg_debug(u32 argc, char* argv[]) {
    printf("\n---- ARG DEBUG ----\n");
    printf("command is: "); printf(argv[0]); printf("\n");
    printf("command has %x [argc]\n", argc);
    printf("----\n");
    for(u32 idx = 1; idx < argc; idx++) {
        printf("%x arg: ", idx);
        printf(argv[idx]);
        printf("\n");
    }




}



