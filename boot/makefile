all: copy

DFILES := bootcode.bin fixup.dat start.elf LICENCE.broadcom

# Clean directory, then download latest firmware version
firmware: clean
	@echo "==== DOWNLOADING FIRMWARE"
	@wget -q -O LICENCE.broadcom https://github.com/raspberrypi/firmware/blob/master/boot/LICENCE.broadcom?raw=true
	@md5 LICENCE.broadcom
	@wget -q -O bootcode.bin https://github.com/raspberrypi/firmware/blob/master/boot/bootcode.bin?raw=true
	@md5 bootcode.bin
	@wget -q -O fixup.dat https://github.com/raspberrypi/firmware/blob/master/boot/fixup.dat?raw=true
	@md5 fixup.dat
	@wget -q -O start.elf https://github.com/raspberrypi/firmware/blob/master/boot/start.elf?raw=true
	@md5 start.elf

# Copy downloaded files onto SD card
copy: firmware
	@echo "==== DEPLOY FIRMWARE"
	@cp $(DFILES) /Volumes/CLASSIC/

# Remove downloaded files
clean:
	@rm -f $(DFILES) kernel.img kernel7.img
	@echo "==== CLEAN: FIRMWARE"
