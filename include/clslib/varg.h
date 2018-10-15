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


/* varg.h - Variable arguments

Allows for parsing and using `...` in function definitions and calls with
a variable number of arguments.

*/


#include "types.h"


typedef unsigned int* va_list;

#define VA_STA(vl, f) (vl = (va_list)&f)
#define VA_ARG(vl, t) (*(t*)vl++)
#define VA_END(vl)    (vl = NULL)
#define VA_SKI(vl, n) (vl+=n)
