.include "gpio.s"
.include "board/bsc.s"


.section .text


@ i2c_init
@ Enable the I2C Interface.
.globl i2c_init
i2c_init:
	PUSH	{LR}

	MOV	R0, #GPIO_SDA		@ Enable SDA
	MOV	R1, #0			@
	BL	gpio_fsel		@
	MOV	R0, #GPIO_SDA		@
	MOV	R1, #1			@
	BL	gpio_set		@

	MOV	R0, #GPIO_SCL		@ Enable SCL
	MOV	R1, #0			@
	BL	gpio_fsel		@
	MOV	R0, #GPIO_SCL		@
	MOV	R1, #1			@
	BL	gpio_set		@

	POP	{PC}			@ Return


@ i2c_wait
@ Wait for the I2C to finish the current operation.
.globl i2c_wait
i2c_wait:
	LDR	R0, =BSC_BASE_0

 _i2c_wait:

	LDRB	R1, [R0, #BSC_S]
	TST	R1, #BSC_S_DONE
	BEQ	_i2c_wait

	MOV	PC, LR


@ i2c_set_slave (slave_addr)
@ Set the BSC_A register to the 7 bit long address of the slave in R0.
.globl i2c_set_slave
i2c_set_slave:
	LDR	R1, =BSC_BASE_0
	STRB	R0, [R1, #BSC_A]
	MOV	PC, LR
