SOURCE_DIR := source
COMPILER := ghdl

ANALYSE = $(COMPILER) -a

opcodes.o: $(SOURCE_DIR)/opcodes.vhdl
	@ $(ANALYSE) $<

%.o: $(SOURCE_DIR)/%.vhdl opcodes.o
	@ $(ANALYSE) $<

clean:
	@ rm -f *.o
	@ rm -f *obj93.cf