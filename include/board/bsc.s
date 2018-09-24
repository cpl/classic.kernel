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


.include "board/base.s"

.set	BSC_C,			0x0			@ Control
.set	BSC_S,			0x4			@ Status
.set	BSC_DLEN,		0x8			@ Data Length
.set	BSC_A,			0xC			@ Slave Address
.set	BSC_FIFO,		0x10			@ Data FIFO
.set	BSC_DIV,		0x14			@ Clock Divider
.set	BSC_DEL,		0x18			@ Data Delay
.set	BSC_CLKT,		0x1C			@ Clock Stretch Timer

.set	BSC_C_I2CEN,		(1<<15)			@ I2C Enable
.set	BSC_C_INTR,		(1<<10)			@ Interrupt on RX
.set	BSC_C_INTT,		(1<<9)			@ Interrupt on TX
.set	BSC_C_INTD,		(1<<8)			@ Interrupt on DONE
.set	BSC_C_ST,		(1<<7)			@ Start Transfer
.set	BSC_C_CLEAR,		(1<<4)			@ FIFO Clear
.set	BSC_C_READ,		(1<<0)			@ Read Transfer

.set	BSC_START_READ,		BSC_C_I2CEN|BSC_C_ST|BSC_C_CLEAR|BSC_C_READ
.set	BSC_START_WRITE,	BSC_C_I2CEN|BSC_C_ST

.set	BSC_S_CLKT,		(1<<9)			@ Clock Stretch Timer
.set	BSC_S_ERR,		(1<<8)			@ ACK Error
.set	BSC_S_RXF,		(1<<7)			@ FIFO Full
.set	BSC_S_TXE,		(1<<6)			@ FIFO Empty
.set	BSC_S_RXD,		(1<<5)			@ FIFO contains Data
.set	BSC_S_TXD,		(1<<4)			@ FIFO can accept Data
.set	BSC_S_RXR,		(1<<3)			@ FIFO needs Reading
.set	BSC_S_TXW,		(1<<2)			@ FIFO needs Writing
.set	BSC_S_DONE,		(1<<1)			@ Transfer Done
.set	BSC_S_TA,		(1<<0)			@ Transfer Active

.set	BSC_CLEAR_STATUS,	BSC_S_CLKT|BSC_S_ERR|BSC_S_DONE
