DC = dmd
RDC = rdmd

OPTS := -O -J=./ -m64
TESTOPTS := $(OPTS) -unittest -debug -g

BIN = rv32i
DEBUG_BIN = rv32i-debug

MODULES = 		\
inst			\
interp			\
regs			\
driver			\

SRC = $(addsuffix .d,$(addprefix source/,$(MODULES)))

all: genbin
	@ printf "Compiling rv32i...\n"
	@ $(DC) $(OPTS) -of=$(BIN) $(SRC)

debug: genbin
	@ printf "Compiling rv32i and running unittest...\n"
	@ $(DC) $(TESTOPTS) -of=$(DEBUG_BIN) $(SRC)
	@ ./$(DEBUG_BIN) $(SIM_BIN_NAME) > debug.txt
	@ printf "Done unittesting. See ./debug.text for details.\n"

SIM_BIN_NAME = example.bin

genbin:
	@ $(RDC) genbin.d $(SIM_BIN_NAME)

clean:
	@ rm -f $(BIN) $(DEBUG_BIN) $(BIN).o $(DEBUG_BIN).o $(addsuffix .o,$(MODULES)) 
	@ rm -f debug.txt
	@ rm -f $(SIM_BIN_NAME)
