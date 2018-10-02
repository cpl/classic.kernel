#    Copyright 2018 Alexandru-Paul Copil
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

# Libraries
LIBDIR	= libs
LIBS	:= csud

# Intermediary
LIST	= kernel.list
MAP	= kernel.map

# Final binary
TARGET	= kernel.img

# Objects
OBJECTS := $(patsubst $(SOURCE)/%.s, $(BUILD)/%.o, $(shell find $(SOURCE) -type f -name '*.s'))

# Make all
all: $(TARGET) $(LIST)
rebuild: all

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
	@$(COMPILER)-ld --no-undefined $(OBJECTS) -L$(LIBDIR) $(patsubst %,-l %,$(LIBS)) -Map $(MAP) -o $(BUILD)/output.elf -T $(LINKER)

# Generate - Objects
$(BUILD)/%.o: $(SOURCE)/%.s
	@echo "==== Generating object: $@"
	@mkdir -p $(@D)
	@$(COMPILER)-as --reduce-memory-overheads -I $(INCLD)/ $< -o $@

deploy: $(TARGET)
	@while [ ! -f /Volumes/CLASSIC/$(TARGET) ]; do sleep 1; echo "..." ; done
	@echo found
	@sum /Volumes/CLASSIC/$(TARGET)
	@cp $(TARGET) /Volumes/CLASSIC/
	@echo OK
	@sum /Volumes/CLASSIC/$(TARGET)
	@sudo umount /Volumes/CLASSIC

# Clean generated files & directories
clean :
	-rm -rf $(BUILD)
	-rm -f $(TARGET)
	-rm -f $(LIST)
	-rm -f $(MAP)