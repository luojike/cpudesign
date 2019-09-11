SOURCE_DIR := source
COMPILER := ghdl

ANALYSE = $(COMPILER) -a

%.o: $(SOURCE_DIR)/%.vhdl opcodes.o
	@ $(ANALYSE) $<

opcodes.o: $(SOURCE_DIR)/opcodes.vhdl
	@ $(ANALYSE) $<

clean:
	@ rm -f *.o
	@ rm -f *obj93.cf