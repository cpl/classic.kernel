/* ENTRY POINT 0x8000 */
ENTRY(_start)

/* Kernel system memory region */
MEMORY {
	sys : ORIGIN = 0x8000,		LENGTH = 1M
	usr : ORIGIN = 0x1000000,	LENGTH = 1M
}

SECTIONS {
	/* .init includes initialization code, exceptions, reset routines, etc. */
	.init : {
		_init_start = .;
		*(.init)
		_init_end = .;
	} > sys

	/* Kernel code */
	.text   : {
		. = ALIGN(4);
		*(.text)
	} > sys
	.text.usb : {
		. = ALIGN(4);
		*.c.o(.text)
	} > sys

	/* Kernel read only data*/
	.rodata : {
		. = ALIGN(4);
		*(.rodata*)
	} > sys

	/* Kernel data */
	.data.vc : {
		. = ALIGN(4);
		build/driver/vc.o (.data)
	} > sys
	.data.usb  : {
		. = ALIGN(4);
		*.c.o(*.data)
	} > sys
	.data    : {
		. = ALIGN(4);
		*(.data)
	} > sys

	_bss_start = ALIGN(4);
	.bss : {
		*(*.bss*)
		*(*COMMON*)
	} > sys
	_bss_end = .;

	/* Kernel heap */
	_KERNEL_HEAP = ALIGN(0x40);

	/* User libraries and other user read only material */
	_USR_LOAD = ALIGN(4);
	.usr (0x1000000) : AT(_USR_LOAD) {
		*(*.usr)
	} > usr
	_USR_END = .;
	_USR_SIZE = _USR_END - _USR_LOAD;

	/DISCARD/ : {
		*(*)
	}
}
