#    Copyright 2018-2019 Alexandru-Paul Copil
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# ARM GNU Compiler
COMPILER ?= arm-none-eabi

# Linker script
LINKER	= linker.ld

# Directories
SOURCE	= src
BUILD	= build
DIST	= dist
INCLD	= include
EXTERN  = external
INCLDC	= $(INCLD)/c
BOOT	= boot

# Libraries
LIBDIR	= libs
LIBS	:= csud cls

# Intermediary
LIST	= kernel.list
MAP	= kernel.map

# Final binary
TARGET	= kernel.img

# Objects
OBJECTS := $(patsubst $(SOURCE)/%.s, $(BUILD)/%.o, $(shell find $(SOURCE) -type f -name '*.s'))
OBJECTS += $(patsubst $(SOURCE)/%.c, $(BUILD)/%.o, $(shell find $(SOURCE) -type f -name '*.c'))

# C FLAGS
CFLAGS := -std=c99 -fpack-struct -fno-builtin -Wno-packed-bitfield-compat -fshort-wchar -Wall -c -nostdlib -nostartfiles -ffreestanding -O2


# Make all
all: $(TARGET) $(LIST)
rebuild: all


# Help message
help:
	@echo "  make clean"
	@echo "    - removes all build files and generated files"
	@echo "  make deploy"
	@echo "    - starts polling the microSD card for uploading kernel files"

# Generate - Code listing
$(LIST) : $(BUILD)/output.elf
	@echo "==== Generating code listing"
	@$(COMPILER)-objdump -d $(BUILD)/output.elf > $(LIST)

# Generate - Kernel image
$(TARGET) : $(BUILD)/output.elf
	@echo "==== Generating kernel image"
	@$(COMPILER)-objcopy $(BUILD)/output.elf -O binary $(TARGET)
	@ls -ahl $(TARGET)

# Generate - ELF
$(BUILD)/output.elf : $(OBJECTS) $(LINKER)
	@echo "==== Generating ELF output"
	@$(COMPILER)-ld --no-undefined --warn-common --print-memory-usage $(OBJECTS) -L$(LIBDIR) $(patsubst %,-l %,$(LIBS)) -Map $(MAP) -o $(BUILD)/output.elf -T $(LINKER)

# Generate - Objects - ASM
$(BUILD)/%.o: $(SOURCE)/%.s
	@echo "==== Generating ASM object: $@"
	@mkdir -p $(@D)
	@$(COMPILER)-as --reduce-memory-overheads -I$(INCLD)/ $< -o $@

# Generate - Objects - C
$(BUILD)/%.o: $(SOURCE)/%.c
	@echo "==== Generating C   object: $@"
	@mkdir -p $(@D)
	@$(COMPILER)-gcc $(CFLAGS) -I$(INCLDC) $< -o $@ -I$(LIBDIR) -I./external/cls/include

# Deploy firmware to SD card
firmware:
	@echo "==== SCANNING FOR SD CARD"
	@while [ ! -f /Volumes/CLASSIC/$(TARGET) ]; do sleep 1; echo "..." ; done
	@echo found
	@make -C "boot"

# Simple build of target
build: $(TARGET)

# Deploy kernel image to SD card
deploy: $(TARGET)
	@echo "==== SCANNING FOR SD CARD"
	@while [ ! -f /Volumes/CLASSIC/$(TARGET) ]; do sleep 1; echo "..." ; done
	@echo found
	@sum /Volumes/CLASSIC/$(TARGET)
	@cp $(TARGET) /Volumes/CLASSIC/
	@echo OK
	@sum /Volumes/CLASSIC/$(TARGET)
	@sudo diskutil unmountDisk disk2

# Clean generated files & directories
clean :
	@rm -rf $(BUILD)
	@rm -f $(TARGET)
	@rm -f $(LIST)
	@rm -f $(MAP)
	@echo "==== CLEAN: KERNEL"

$(LIBS):
	@echo "==== BUILDING LIBRARY: $@"
	@make -C "$(EXTERN)/$@"
	@cp $(EXTERN)/$@/lib$@.a $(LIBDIR)/
