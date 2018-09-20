@ ARM PROCESSOR MODES
.set	PSR_MODE_USR,		0b00010000
.set	PSR_MODE_FIQ,		0b00010001
.set	PSR_MODE_IRQ,		0b00010010
.set	PSR_MODE_SVC,		0b00010011
.set	PSR_MODE_ABT,		0b00010111
.set	PSR_MODE_UND,		0b00011011
.set	PSR_MODE_SYS,		0b00011111

@ DISABLE IRQ (1), ENABLE IRQ (0)
.set	PSR_IRQ,		0b10000000

@ DISABLE FIQ (1), ENABLE FIQ (0)
.set	PSR_FIQ,		0b01000000