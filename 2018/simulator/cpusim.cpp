#include <cstdint>
#include <iostream>

// 演示指令
#define AUIPC 0b0010111
#define LHU 0b0000011
#define FENCE 0b0001111
#define EBREAK 0b1110011
#define CSRRWI 0b1110011


// 大家可以对主程序做修改

// 内存模拟器
// 内存模拟器有关数据
const int WORDSIZE = sizeof(uint32_t);
unsigned int MSIZE = 4096;
char* M;

// 内存模拟器有关函数
int allocMem(uint32_t s) {
		M = new char[s];
		MSIZE = s;

		return s;
}

void freeMem() {
		delete[] M;
		MSIZE = 0;
}

char readByte(unsigned int address) {
	if(address >= MSIZE) {
		cout << "ERROR: address out of range in readByte" << endl;
		return 0;
	}

	return M[address];
}

void writeByte(unsigned int address, char data) {
	if(address >= MSIZE) {
		cout << "ERROR: address out of range in writeByte" << endl;
		return;
	}

	M[address] = data;
}

uint32_t readWord(unsigned int address) {
	if(address >= MSIZE-WORDSIZE) {
		cout << "ERROR: address out of range in readWord" << endl;
		return 0;
	}

	return *((uint32_t*)&(M[address]));
}

void writeWord(unsigned int address, uint32_t data) {
	if(address >= MSIZE-WORDSIZE) {
		cout << "ERROR: address out of range in writeWord" << endl;
		return;
	}

	*((uint32_t*)&(M[address])) = data;
}

// 这个函数直接写入要测试的指令
void progMem() {
	// 从地址0开始写入测试指令
	writeWord(0, );
}


// CPU模拟器有关数据
uint32_t PC;
uint32_t R[32];
uint32_t IR;

unsigned int opcode;
unsigned int rs1, rs2, rd;
unsigned int funct7, funct3;
// immediate values for I-type, S-type, B-type, U-type, J-type
unsigned int imm11_0i;
unsigned int imm11_5s, imm4_0s;
unsigned int imm12b, imm10_5b, imm4_1b, imm11b;
unsigned int imm31_12u;
unsigned int imm20j, imm10_1j, imm11j, imm19_12j;

// CPU模拟器有关函数
void decode(uint32_t instruction) {
	opcode = instruction & 0b01111111;
	rd = (instruction & 0b0111110000000) >> 7;
	rs1 = (instruction & 0b011111000000000000000) >> 15;
	rs2 = (instruction & 0b01111100000000000000000000) >> 20;
	funct3 = (instruction & 0b0111000000000000) >> 12;
	funct7 = instruction >> 25;
	imm11_0i = instruction >> 20;
	imm11_5s = instruction >> 25;
	imm4_0s = (instruction & 0b0111110000000) >> 7;
	imm12b = instruction >> 31;
	imm10_5b = (instruction >> 25) & 0b0111111;
	imm4_1b = (instruction & 0b0111100000000) >> 8;
	imm11b = (instruction & 0b010000000) >> 7;
	imm31_12u = instruction >> 12;
	imm20j = instruction >> 31;
	imm10_1j = (instruction >> 21) & 0b01111111111;
	imm11j = (instruction >> 20) & 1;
	imm19_12j = (instruction >> 12) & 0b011111111;
}

void showRegs() {
	cout << "PC=" << PC << endl;
	cout << "IR=" << IR << endl;

	for(int i=0; i<32; i++) {
		cout << "R[" << i << "]=" << R[i] << endl;
	}
}

int main(int argc, char const *argv[]) {
	/* code */
	allocMem(4096);
	PC = 0;

	while(1) {
		showRegs();

		IR = readWord(PC);
		PC = PC + WORDSIZE;

		decode(IR);

		switch(opcode) {
			case AUIPC:
				cout << "Do AUIPC" << endl;
				break;
			case LHU:
				cout << "Do LHU" << endl;
				break;
			case FENCE:
				cout << "Do FENCE" << endl;
				break;
			case EBREAK:
				cout << "Do EBREAK" << endl;
				break;
			case CSRRWI:
				cout << "Do CSRRWI" << endl;
				break;
		}

	}

	freeMem();

	return 0;
}
