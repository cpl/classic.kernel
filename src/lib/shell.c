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
#include "types.h"
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

                *CMD_CURSOR = ASCII_NULL; CMD_CURSOR--; *CMD_CURSOR = ' ';
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
}


void shell_handlecmd(const char* buf) {
    printf("\n");

    if(strequ(buf, "help\0"))
        printf(SHELL_HELP_MSG);

    printf("\n");
}