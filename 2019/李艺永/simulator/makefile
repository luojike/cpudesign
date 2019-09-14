DC = dmd

OPTS := -O -J=./ -m64
TESTOPTS := $(OPTS) -unittest -debug -g

BIN = rv32i
DEBUG_BIN = rv32i-debug

MODULES = 		\
consts			\
inst			\
interp			\
regs			\
driver			\

SRC = $(addsuffix .d,$(addprefix source/,$(MODULES)))

all:
	@ printf "Compiling rv32i...\n"
	@ $(DC) $(OPTS) -of=$(BIN) $(SRC)

debug:
	@ printf "Compiling rv32i and running unittest...\n"
	@ $(DC) $(TESTOPTS) -of=$(DEBUG_BIN) $(SRC)
	@ ./$(DEBUG_BIN) > debug.txt
	@ printf "Done unittesting. See ./debug.text for details.\n"

clean:
	@ rm -f $(BIN) $(DEBUG_BIN) $(BIN).o $(DEBUG_BIN).o $(addsuffix .o,$(MODULES)) 
	@ rm -f debug.txt
