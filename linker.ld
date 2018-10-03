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
	.text   : {
		*.c.o(.text)
		*(.text)
	} > sys
	.rodata : { *(.rodata) } > sys
	. = ALIGN(4);

    /* Kernel data */
	.data   : {
		*(.data)
		*.c.o(*)
	} > sys
	. = ALIGN(4);

	_bss_start = .;
	.bss : { *(.bss) } > sys
	_bss_end = .;
	. = ALIGN(4);

    /* DISCARD EVERYTHING ELSE */
	/DISCARD/ : {
		*(*)
	}

    /* Kernel heap */
	_KERNEL_HEAP_ = ABSOLUTE(0x000FFFF0);
}
