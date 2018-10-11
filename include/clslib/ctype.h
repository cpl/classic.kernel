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


/* ctype.h - Character handling functions

These functions take the `char` as the argument and return a `bool` (int) as
defined in `types.h`. The return value can be FALSE or TRUE.

*/


#include "bool.h"


extern bool isalnum(char c);    // Check if char is alphanumeric
extern bool isalpha(char c);    // Check if char is alphabetic
extern bool isblank(char c);    // Check if char is blank
extern bool iscntrl(char c);    // Check if char is a control char
extern bool isdigit(char c);    // Check if char is decimal digit
extern bool isgraph(char c);    // Check if char has graphical representation
extern bool islower(char c);    // Check if char is lowercase
extern bool isprint(char c);    // Check if char is printable
extern bool ispunct(char c);    // Check if char is a punctuation char
extern bool isspace(char c);    // Check if char is white-space
extern bool isupper(char c);    // Check if char is uppercase
extern bool ishexad(char c);    // Check if char is hexadecimal digit

extern char tolower(char c);    // Convert uppercase letter to lowercase
extern char toupper(char c);    // Convert lowercase letter to uppercase
