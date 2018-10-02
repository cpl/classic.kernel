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

    /* Kernel code */
	.text   : { *(.text) }   > sys
	.rodata : { *(.rodata) } > sys

    /* Kernel data */
	.data   : { *(.data) }   > sys
	_bss_start = .;
	.bss : { *(.bss) } > sys
	_bss_end = .;

    /* Kernel heap */
    _KERNEL_HEAP_ = ABSOLUTE(0x000FFFF0);
}
