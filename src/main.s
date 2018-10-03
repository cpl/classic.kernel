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


.section .rodata


_str_hang:	.ascii "HANG\n\r\0"
_str_knl_heap:	.ascii "KERNEL HEAP: \0"
_str_main:	.ascii "\n\r\n\r_main_loop()\n\r\0"

.section .text


.globl _main
_main:

	LDR	R0, =_str_knl_heap
	BL	vfb_print
	LDR	R0, =_KERNEL_HEAP_
	BL	strtmp_hex
	BL	vfb_println
	BL	vfb_println

	NOP
	NOP
	NOP

	BL	UsbInitialise
	BL	strtmp_hex
	BL	vfb_println

	BL	KeyboardCount
	BL	strtmp_hex
	BL	vfb_println

	LDR	R0, =_str_main
	BL	vfb_print

 _main_loop:

	NOP
	NOP
	NOP

	B	_main_loop


.globl _hang
_hang:

	LDR	R0, =_str_hang
	BL	uart_send_string

	B .
