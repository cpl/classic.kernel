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


/*

keyboard drivers - libcsud

provided by:
Copyright (c) 2012 Alex Chadwick

API

csudUsbInitialise		()			-> (result-code)
csudUsbCheckForChange		()			-> ()
csudKeyboardCount		()			-> (count)
csudKeyboardGetAddress		(index)			-> (address)
csudKeyboardPoll		(address)		-> (result-code)
csudKeyboardGetModifiers	(address)		-> (modifer-state)
csudKeyboardGetKeyDownCount	(address)		-> (count)
csudKeyboardGetKeyDown		(address, key index)	-> (scan-code)
csudKeyboardGetLedSupport	(address)		-> (LEDs)
csudKeyboardSetLeds		(address, LEDs)		-> (result-code)


The general usage of the driver is as follows:

1. Call UsbInitialise
2. Call UsbCheckForChange
3. Call KeyboardCount
4. If this is 0, go to 2.
5. For each keyboard you support:
    1. Call KeyboardGetAddress
    2. Call KeybordGetKeyDownCount
    3. For each key down:
        1. Check whether or not it has just been pushed
        2. Store that the key is down
    4. For each key stored:
        1. Check whether or not key is released
        2. Remove key if released
6. Perform actions based on keys pushed/released
7. Go to 2.

*/


.section .data


.align 2
_kbd_addr:	.word 0


.globl _kbd_down
_kbd_down:	.hword 0
		.hword 0
		.hword 0
		.hword 0
		.hword 0
		.hword 0


.align 3
_kbd_keymap_n:
	.byte 0x0, 0x0, 0x0, 0x0, 'a', 'b', 'c', 'd'
	.byte 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l'
	.byte 'm', 'n', 'o', 'p', 'q', 'r', 's', 't'
	.byte 'u', 'v', 'w', 'x', 'y', 'z', '1', '2'
	.byte '3', '4', '5', '6', '7', '8', '9', '0'
	.byte '\n', 0x0, '\b', '\t', ' ', '-', '=', '['
	.byte ']', '\\', '#', ';', '\'', '`', ',', '.'
	.byte '/', 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, '/', '*', '-', '+'
	.byte '\n', '1', '2', '3', '4', '5', '6', '7'
	.byte '8', '9', '0', '.', '\\', 0x0, 0x0, '='


.align 3
_kbd_keymap_s:
	.byte 0x0, 0x0, 0x0, 0x0, 'A', 'B', 'C', 'D'
	.byte 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'
	.byte 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T'
	.byte 'U', 'V', 'W', 'X', 'Y', 'Z', '!', '"'
	.byte '#', '$', '%', '^', '&', '*', '(', ')'
	.byte '\n', 0x0, '\b', '\t', ' ', '_', '+', '{'
	.byte '}', '|', '~', ':', '@', '#', '<', '>'
	.byte '?', 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, '/', '*', '-', '+'
	.byte '\n', '1', '2', '3', '4', '5', '6', '7'
	.byte '8', '9', '0', '.', '|', 0x0, 0x0, '='


.section .text


@ void kbd_update(void)
@ Update the keyboard pressed and released data
.globl kbd_update
kbd_update:
	PUSH	{R4, LR}

	kbd	.req R4

	LDR	kbd, =_kbd_addr			@ Load keyboard   address*
	LDR	R0, [kbd]			@ Load keyboard   address
	TEQ	R0, #0				@ Check for !NULL address

	BNE	_kbd_update_ok			@ If keyboard address is !NULL

 _kbd_update_null:				@ If keyboard address is NULL

	BL	csudUsbCheckForChange		@ Check for new peripherals
	BL	csudKeyboardCount		@ Get keyboard count

	TEQ	R0, #0				@ Check for no peripherals
	STREQ	R0, [kbd]			@ and write 0 as kbd address
	POPEQ	{R4, PC}			@ then exit

	MOV	R0, #0				@ Set keyboard index 0
	BL	csudKeyboardGetAddress		@ Get keyboard address
	STR	R0, [kbd]			@ Set keyboard address

	TEQ	R0, #0				@ Check for !NULL address
	POPEQ	{R4, PC}			@ Exit if NULL

 _kbd_update_ok:				@ Continue if keyboard !NULL
	MOV	R5, #5				@ R0 = keyboard address
						@ R4 = keyboard address *

 _kbd_update_poll:


	POP	{R4, PC}			@ Return
