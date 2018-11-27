/* ENTRY POINT 0x8000 */
ENTRY(_start)

/* Kernel system memory region */
MEMORY {
	sys : ORIGIN = 0x0000008000,	LENGTH = 1M
	usr : ORIGIN = 0x0001000000,	LENGTH = 1M
}

SECTIONS {
	/* .init includes initialization code, exceptions, reset routines, etc. */
	.init : {
		_init_start = .;
		*(.init)
		_init_end = .;
	} > sys
	. = ALIGN(4);

	/* Kernel code */
	.text.usb : { *.c.o(.text) } > sys
	. = ALIGN(4);
	.text   : {
		*(.text)
	} > sys

	/* Kernel read only data*/
	.rodata : { *(.rodata*) } > sys
	. = ALIGN(4);

	/* Kernel data */
	.data.vc : { build/driver/vc.o (.data) } > sys
	. = ALIGN(4);
	.data.usb  : { *.c.o(*.data) } > sys
	. = ALIGN(4);
	.data    : {
		*(.data)
	} > sys
	. = ALIGN(4);

	_bss_start = .;
	.bss : {
		*(*.bss*)
		*(*COMMON*)
	} > sys
	_bss_end = .;
	. = ALIGN(4);

	/* Kernel heap */
	. = ALIGN(0x40);
	_KERNEL_HEAP = .;

	/* User libraries and other user read only material */
	_USR_LOAD = ALIGN(4);
	.usr (0x1000000) : AT(_USR_LOAD) {
		*(*.usr)
	} > usr

	/DISCARD/ : {
		*(*)
	}
}
