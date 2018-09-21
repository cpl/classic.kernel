.set	MMU_ENABLE,			(1<<0)
.set	MMU_CACHE,			(1<<2)
.set	MMU_CACHE_INS,			(1<<12)
.set	MMU_UNALIGNED,			(1<<22)


.set	MMU_COARSE,			1
.set	MMU_SECTION,			2

.set	MMU_PAGE_L,			1
.set	MMU_PAGE_S,			2


.set	VMSA_B,				(1<<2)
.set	VMSA_C,				(1<<3)
.set	VMSA_CACHEABLE,			VMSA_C
.set	VMSA_BUFFERABLE,		VMSA_B

.set	VMSA_AP,			(3<<10)

.set	VMSA_AP_XX_XX,			(0<<10)
.set	VMSA_AP_RW_XX,			(1<<10)
.set	VMSA_AP_RW_RX,			(2<<10)
.set	VMSA_AP_RW_RW,			(3<<10)
