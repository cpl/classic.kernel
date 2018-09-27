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
_str_test:	.ascii "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut magna tortor, lacinia eget magna vitae, auctor dictum leo. Mauris a facilisis neque. Fusce tristique urna libero, non dignissim nisi convallis in. Ut quis nisl posuere, vehicula neque eu, volutpat massa. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque in nulla ut elit sagittis dictum. Vivamus lacinia diam sed tortor lacinia, a tincidunt metus lobortis. Nam sagittis, lectus nec elementum facilisis, turpis justo sollicitudin tortor, ac ullamcorper risus nunc a nisl.\n\rNunc sed lacinia mi, a pharetra diam. Nulla faucibus purus purus, in dapibus nisi tincidunt id. Nunc vehicula mauris augue, vel vestibulum lorem feugiat vel. Donec tristique magna non diam gravida malesuada. Sed lorem justo, malesuada et enim quis, tempor mattis enim. Duis ut bibendum nisl. In tincidunt, ipsum eu accumsan rhoncus, leo nisi ornare ante, sed sagittis sapien purus eu est. Praesent convallis, nisl eget faucibus condimentum, felis eros laoreet ante, et interdum nunc dolor ac orci. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Ut non orci quis turpis maximus convallis. Duis at risus libero. Donec id tellus ante. Integer laoreet, massa eu aliquet accumsan, neque nulla laoreet lectus, eget ultrices velit turpis eget neque. Sed purus diam, feugiat sed tortor non, rhoncus facilisis dui.\n\r\0"


.section .text


.globl _main
_main:

	BL	vfb_get_data
	MOV	R4, R0
	MOV	R5, R1
	MOV	R6, R2
	MOV	R7, R3

	BL	str_hex
	BL	uart_send_string
	BL	uart_clrf

	MOV	R0, R5
	BL	str_hex
	BL	uart_send_string
	BL	uart_clrf

	MOV	R0, R6
	BL	str_hex
	BL	uart_send_string
	BL	uart_clrf

	MOV	R0, R7
	BL	str_hex
	BL	uart_send_string
	BL	uart_clrf

	BL	uart_clrf

	LDR	R0, =vfb_data
	LDR	R0, [R0]
	BL	str_hex
	BL	uart_send_string
	BL	uart_clrf

	LDR	R0, =vfb_data
	LDR	R0, [R0, #-4]
	BL	str_hex
	BL	uart_send_string
	BL	uart_clrf

	LDR	R0, =vfb_data
	LDR	R0, [R0, #4]
	BL	str_hex
	BL	uart_send_string
	BL	uart_clrf

	LDR	R0, =_str_test
	BL	vfb_print

	LDR	R0, =_str_test
	BL	vfb_println

	LDR	R0, =_str_test
	BL	vfb_print

	B	.			@ Stop here


.globl _hang
_hang:

	LDR	R0, =_str_hang
	BL	uart_send_string

	B .
