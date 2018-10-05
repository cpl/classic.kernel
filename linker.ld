/* ENTRY POINT 0x8000 */
ENTRY(_start)

/* Kernel system memory region */
MEMORY {
    sys : ORIGIN = 0x8000,     LENGTH = 1M
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
	.text.c : { *.c.o(.text) } > sys
	. = ALIGN(4);

	.text   : {
		*(.text)
	} > sys
	.rodata : { *(.rodata) } > sys
	. = ALIGN(4);

    /* Kernel data */
	.data.vc : { build/driver/vc.o (.data) } > sys
	. = ALIGN(4);

	.data.c  : { *.c.o(*) } > sys
	. = ALIGN(4);

	.data    : {
		*(.data)
	} > sys
	. = ALIGN(4);

	_bss_start = .;
	.bss : {
		*(.bss)
		*(COMMON)
	} > sys
	_bss_end = .;
	. = ALIGN(4);

    /* DISCARD EVERYTHING ELSE */
	/DISCARD/ : {
		*(*)
	}

    /* Kernel heap */
	_KERNEL_ALOC = ALIGN(12);
	_KERNEL_HEAP = ABSOLUTE(0x000FFFF0);
}
