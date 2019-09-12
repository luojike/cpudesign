SOURCE_DIR := source
COMPILER := ghdl

ANALYSE = $(COMPILER) -a
ELAB = $(COMPILER) -e
SIM = $(COMPILER) -r

COMPONENTS = 	\
pc 				\
multiplexer		\
registerfile	\
mem				\
core			\
control_unit	\
alu				\

TESTBENCH = core_testbench

simulate: elaborate
	@ printf "Running core_testbench...\n"
	@ $(SIM) core_testbench --vcd=core_testbench.vcd

elaborate: anaylse
	@ printf "Elaborating core_testbench...\n"
	@ $(ELAB) core_testbench

anaylse: $(addsuffix .o,$(COMPONENTS)) $(addsuffix .o,$(TESTBENCH))
	@ printf "Analysing components...\n"

%.o: $(SOURCE_DIR)/%.vhdl opcodes.o
	@ $(ANALYSE) $<

opcodes.o: $(SOURCE_DIR)/opcodes.vhdl
	@ $(ANALYSE) $<

clean:
	@ rm -f *.o
	@ rm -f *obj93.cf