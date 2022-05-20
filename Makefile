COMPILER=bin/acme
CRUNCHER=bin/pucrunch
EMULATOR=x64sc -kernal bin/kernal -basic bin/basic -chargen bin/chargen -dos1541II bin/d1541II
DISKTOOL=c1541

TARGET=c64-textwriter

all: compile crunch disk runprg
compile:
	$(COMPILER) --format cbm -v3 -o build/$(TARGET).prg source/main.asm
crunch:
	$(CRUNCHER) -x0x0801 -c64 -g55 -fshort build/$(TARGET).prg build/$(TARGET).prg
disk:
	$(DISKTOOL) -format $(TARGET),42 d64 build/$(TARGET).d64 -attach build/$(TARGET).d64 -write build/$(TARGET).prg $(TARGET)
runprg:
	$(EMULATOR) build/$(TARGET).prg
rundisk:
	$(EMULATOR) build/$(TARGET).d64
clean:
	rm -f build/*
