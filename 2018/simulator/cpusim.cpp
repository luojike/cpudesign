#define AUIPC 0b0010111
#define LHU 0b0000011
#define FENCE 0b0001111
#define EBREAK 0b1110011
#define CSRRWI 0b1110011

class MEM {
	
}

class CPU {

}

int main() {

	CPU cpu;
	MEM mem;

	while(1) {
		cpu.IR=mem.read(cpu.PC);

		cpu.IR.opcode = IR >> 26;

		switch(cpu.IR.opcode) {
			case ADD:
				R[rd]=R[rs]+R[rt];
		}

	}

}
