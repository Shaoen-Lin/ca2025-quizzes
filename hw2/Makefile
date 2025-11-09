include ../../../mk/toolchain.mk

ARCH = -march=rv32izicsr
LINKER_SCRIPT = linker.ld

EMU ?= ../../../build/rv32emu

# -------------------------------------------------
# Optimization Level 
# -------------------------------------------------
OPT ?= 0
AFLAGS = -g $(ARCH)
CFLAGS = -g -O$(OPT) -march=rv32i_zicsr
LDFLAGS = -T $(LINKER_SCRIPT) -nostartfiles -nostdlib -nodefaultlibs
EXEC = test.elf

CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJDUMP = $(CROSS_COMPILE)objdump

OBJS = start.o main.o perfcounter.o single_number_3.o hanoi.o fast_rsqrt.o

.PHONY: all run dump clean

all: $(EXEC)

$(EXEC): $(OBJS) $(LINKER_SCRIPT)
	#$(LD) $(LDFLAGS) -o $@ $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	
%.o: %.S
	$(CC) $(CFLAGS) -x assembler-with-cpp $< -o $@ -c

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@ -c
	
run: $(EXEC)
	@test -f $(EMU) || (echo "Error: $(EMU) not found" && exit 1)
	@grep -q "ENABLE_ELF_LOADER=1" ../../../build/.config || (echo "Error: ENABLE_ELF_LOADER=1 not set" && exit 1)
	@grep -q "ENABLE_SYSTEM=1" ../../../build/.config || (echo "Error: ENABLE_SYSTEM=1 not set" && exit 1)
	$(EMU) $<

dump: $(EXEC)
	$(OBJDUMP) -Ds $< | less

clean:
	rm -f $(EXEC) $(OBJS)

