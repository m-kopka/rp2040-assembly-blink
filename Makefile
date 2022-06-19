
# RP2040 Makefile
# Martin Kopka 2022
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------

# CPU core
CPU = cortex-m0plus

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------

# build target name
TARGET = build/blink

# list folders containing C and Assembly source files here
SRC_DIRS = . src src/*

# list folders containing header files here
INC_DIRS = . ./include/

# linker script path
LINKER_SCRIPT = rp2040_ls.ld

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------

CC      = arm-none-eabi-gcc
OBJDUMP = arm-none-eabi-objdump
ELF2UF2 = /Users/martin/sdk/pico-sdk/tools/elf2uf2/elf2uf2

# optimization flag
OPT = 0

# compiler flags
CFLAGS = -Wall -mcpu=$(CPU) -mthumb -std=gnu11 -O$(OPT) $(foreach D,$(INC_DIRS), -I$(D)) -MP -MD

# linkek flags
LFLAGS = -mcpu=$(CPU) -mthumb -nostdlib -T $(LINKER_SCRIPT) -Wl,-Map=$(TARGET).map

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------

# find all C source files
CFILES  = $(foreach D,$(SRC_DIRS),$(wildcard $(D)/*.c))

# find all Assembly source files
SFILES  = $(foreach D,$(SRC_DIRS),$(wildcard $(D)/*.s))

#define all object files
OFILES  = $(patsubst %.c,%.o,$(CFILES))
OFILES += $(patsubst %.s,%.o,$(SFILES))

#define all dependency files
DFILES  = $(patsubst %.c,%.d,$(CFILES))

#=================================================================================================================================================================

all: build flash

#---- BUILD ------------------------------------------------------------------------------------------------------------------------------------------------------

build: $(TARGET).uf2

# create object files from C source files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# create object files from Assembly source files
%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

# link object files to ELF file
$(TARGET).elf: $(OFILES)
	$(CC) $(LFLAGS) $^ -o $@
	$(OBJDUMP) -d $@ > $(TARGET).dis

# convert ELF file to UF2 file
$(TARGET).uf2: $(TARGET).elf
	$(ELF2UF2) $< $@

#---- FLASH ------------------------------------------------------------------------------------------------------------------------------------------------------

flash: $(TARGET).uf2
	cp $< /Volumes/RPI-RP2

#---- CLEAN ------------------------------------------------------------------------------------------------------------------------------------------------------

clean:
	rm -rf build/* $(OFILES) $(DFILES)

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-include $(DFILES)