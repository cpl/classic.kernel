.section .text


.globl _main
_main:

	NOP
	NOP
	NOP

	B	_hang			@ Hang execution

.globl _hang
_hang:
	B .
