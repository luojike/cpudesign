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

TESTBENCH = 			\
core_testbench			\
mem_testbench			\
multiplexer_testbench	\
pc_mem_testbench		\
pc_testbench			\
registerfile_testbench	\

simulate: elaborate
	@ printf "Running core_testbench...\n"
	@ $(SIM) core_testbench --vcd=core_testbench.vcd

%_testbench: anaylse
	@ printf "Elaborating %s\n" $@
	@ $(ELAB) $@
	@ printf "Running %s...\n" $@
	@ $(SIM) $@ --vcd=$@.vcd

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
	@ rm -f *.vcd
	@ rm -f $(COMPONENTS)
	@ rm -f *_testbench