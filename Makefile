
all: build flash

#---- BUILD ------------------------------------------------------------------------------------------------------------------------------------------------------

build: build/blink.uf2

# compile
build/blink.elf: blink.s
	arm-none-eabi-gcc -Wall -mcpu=cortex-m0plus -mthumb -nostdlib -T rp2040_ls.ld -std=gnu11 -O0 blink.s -o build/blink.elf

# convert ELF file to UF2 file
build/blink.uf2: build/blink.elf
	/Users/martin/sdk/pico-sdk/tools/elf2uf2/elf2uf2 build/blink.elf build/blink.uf2

#---- FLASH ------------------------------------------------------------------------------------------------------------------------------------------------------

flash: build/blink.uf2
	cp build/blink.uf2 /Volumes/RPI-RP2

#---- CLEAN ------------------------------------------------------------------------------------------------------------------------------------------------------

clean:
	rm -rf build/* blink.o

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------
