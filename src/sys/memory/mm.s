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


/* malloc

 ADDR  |0 |1 |2 |3 |
-------+--+--+--+--+
0x0000 |__|__|__|__|
0x0004 |__|__|__|__|
0x0008 |__|__|__|__|
0x000C |__|__|__|__|
0x0010 |__|__|__|__|
0x0014 |__|__|__|__|
0x0018 |__|__|__|__|
0x001C |__|__|__|__|
0x0020 |__|__|__|__|
0x0024 |__|__|__|__|
0x0028 |__|__|__|__|
0x002C |__|__|__|__| ---- malloc header
|
+---- heap base

*/


.section .text


@ malloc (*mem, size_words)
.globl malloc
malloc:
	MOV	PC, LR


@ free (*mem)
.globl free
free:
	MOV	PC, LR
