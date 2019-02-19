/*
   Copyright 2018-2019 Alexandru-Paul Copil

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


.set	VC_TAG_FIRMWARE,		0x00000001

.set	VC_TAG_BOARD_MODEL,		0x00010001
.set	VC_TAG_BOARD_REVISION,		0x00010002
.set	VC_TAG_BOARD_MAC,		0x00010003
.set	VC_TAG_BOARD_SERIAL,		0x00010004

.set	VC_TAG_MEM_ARM,			0x00010005
.set	VC_TAG_MEM_GPU,			0x00010006

.set	VC_TAG_CMD_LINE,		0x00050001
.set	VC_TAG_DMA_CHANS,		0x00060001

.set	VC_TAG_TEMPERATURE,		0x00030006
.set	VC_TAG_TEMPERATURE_MAX,		0x0003000A

.set	VC_TAG_POWER_GET_STATE,		0x00020001
.set	VC_TAG_POWER_SET_STATE,		0x00028001
.set	VC_TAG_TIMING,			0x00020002
.set	VC_TAG_VOLTAGE_GET,		0x00030003
.set	VC_TAG_VOLTAGE_SET,		0x00038003
.set	VC_TAG_VOLTAGE_MAX,		0x00030005
.set	VC_TAG_VOLTAGE_MIN,		0x00030008

.set	VC_TAG_CLOCKS,			0x00010007
.set	VC_TAG_CLOCK_GET_STATE,		0x00030001
.set	VC_TAG_CLOCK_SET_STATE,		0x00038001
.set	VC_TAG_CLOCK_GET_RATE,		0x00030002
.set	VC_TAG_CLOCK_SET_RATE,		0x00038002
.set	VC_TAG_CLOCK_MAX_RATE,		0x00030004
.set	VC_TAG_CLOCK_MIN_RATE,		0x00030007

.set	VC_TAG_TURBO_GET,		0x00030009
.set	VC_TAG_TURBO_SET,		0x00038009

.set	VC_TAG_MALLOC,			0x0003000C
.set	VC_TAG_MLOCK,			0x0003000D
.set	VC_TAG_MUNLOCK,			0x0003000E
.set	VC_TAG_MFREE,			0x0003000F
.set	VC_TAG_DRMH,			0x00030014

.set	VC_TAG_EXECUTE,			0x00030010

.set	VC_TAG_EDID_GET,		0x00030020
