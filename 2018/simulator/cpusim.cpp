#include <stdint.h>

#define AUIPC 0b0010111
#define LHU 0b0000011
#define FENCE 0b0001111
#define EBREAK 0b1110011
#define CSRRWI 0b1110011

// 测试
class MEM {
private:
	unsigned int msize = 1024;
	char m[];

public:
	MEM(uint32_t s) {
		m = new char[s];
		msize = s;
	}
	MEM() {
		return MEM(1024);
	}
	~MEM() {
		delete[] m;
		msize = 0;
	}

	uint32_t readword(unsigned int address) {
		return m[address];
	}
	void writeword(unsigned int address, uint32_t data) {
		main[address] = data;
	}
}


class CPU {
public:
	uint32_t pc;
	uint32_t ir;
	unsigned int opcode;
	unsigned int rs1, rs2;
	unsigned int rd;
	uint32_t r[32];

	void decode(uint32_t w) {
		opcode = w & 0b1111111;
		rd = (w & 0b111110000000) >> 7;
		rs1 = (w & 0b111110000000) >> 7;
		rs2 = (w & 0b111110000000) >> 7;
	}

}

int main(int argc, char const *argv[]) {
	/* code */
	CPU cpu;
	MEM mem;

	while(1) {
		cpu.ir=mem.readword(cpu.PC);

		//cpu.ir.opcode = IR >> 26;

		switch(cpu.IR.opcode) {
			case ADD:
				R[rd]=R[rs]+R[rt];
		}

	}

	return 0;
}
