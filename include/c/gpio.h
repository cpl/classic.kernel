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


#ifndef _INC_GPIO_H
#define _INC_GPIO_H


#include "types.h"

#define MAX_GPIO_PIN	53
#define MAX_GPIO_CMD	7

#define GPIO_HIGH	    1
#define GPIO_LOW	    0

#define GPIO_ACT        47
#define GPIO_RX         14
#define GPIO_TX         15
#define GPIO_SDA	    0
#define GPIO_SCL        1

void gpio_fsel(u32 pin, u32 cmd);
void gpio_set(u32 pin, u32 status);


#endif
