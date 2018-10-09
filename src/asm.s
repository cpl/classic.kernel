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


@ PUT32 (R0)
.globl PUT32
PUT32:
	STR	R1, [R0]
	BX	LR


@ PUT16 (R0)
.globl PUT16
PUT16:
	STRH	R1, [R0]
	BX	LR


@ PUT08 (R0)
.globl PUT08
PUT08:
	STRB	R1, [R0]
	BX	LR


@ GET32 (R0) -> (R0)
.globl GET32
GET32:
	LDR	R0, [R0]
	BX	LR


@ GET16 (R0)-> (R0)
.globl GET16
GET16:
	LDRH	R0, [R0]
	BX	LR


@ GET08 (R0) -> (R0)
.globl GET08
GET08:
	LDRB	R0, [R0]
	BX	LR


@ GETPC -> (R0)
.globl GETPC
GETPC:
	MOV	R0, PC
	BX	LR


@ GETSP -> (R0)
.globl GETSP
GETSP:
	MOV	R0, SP
	BX	LR


@ GETLR -> (R0)
.globl GETLR
GETLR:
	MOV	R0, LR
	BX	LR
