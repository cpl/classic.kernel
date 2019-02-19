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


/* uart.h - mini UART (Universal asynchronous receiver/transmitter)

Function definitions for mini-UART interactions.

*/


#ifndef _INC_UART_H
#define _INC_UART_H

#include "types.h"

extern void uart_init(void);

extern void uart_send(u8 byte);
extern void uart_send_string(char* str);
extern u8   uart_recv(void);
extern void uart_clrf(void);
extern void uart_send_hex(u32 val);

#endif
