#include <cstdint>
//#include <cstdio>
#include <iostream>

using namespace std;

// 演示指令
#define AUIPC 0x17

// 分支类型的指令，其中BRANCH用于表示共同的opcode
#define BRANCH 0x63

#define BEQ 0x0
#define BNE 0x1
#define BLT 0x4
#define BGE 0x5
#define BLTU 0x6
#define BGEU 0x7


// 装载类型的指令，其中LOAD用于表示共同的opcode
#define LOAD 0x03

#define LB 0x0
#define LH 0x1
#define LW 0x2
#define LBU 0x4
#define LHU 0x5


// 保存类型的指令，其中STORE用于表示共同的opcode
#define STORE 0x23

#define SB 0x0
#define SH 0x1
#define SW 0x2


// 已分配指令
#define LUI 0x37
#define JAL 0x6F
#define JALR 0x67

// 有一个源操作数是立即数的算术逻辑运算指令，采用 ALUR1 作为共同的opcode符号
#define ALUR1 0x13

#define ADDI 0x0
#define SLTI 0x2
#define SLTIU 0x3
#define XORI 0x4
#define ORI 0x6
#define ANDI 0x7
#define SLLI 0x1

#define SHR 0x5

#define SRLI 0x0
#define SRAI 0x20


// 源操作数都来自于寄存器的算术逻辑运算指令，采用 ALUR2 作为共同的opcode符号
#define ALUR2 0x33

#define ADDSUB 0x0
#define ADD 0x0
#define SUB 0x20

#define SLL 0x1
#define SLT 0x2
#define SLTU 0x3
#define XOR 0x4
#define OR 0x6
#define AND 0x7

#define SRLA 0x5

#define SRL 0x0
#define SRA 0x20

// 另外分配的指令

#define FENCES 0x0F
#define FENCE 0x0
#define FENCE_I 0x1

#define CSRX 0x73

#define CALLBREAK 0x0
#define ECALL 0x0
#define EBREAK 0x1

#define CSRRW 0x1
#define CSRRS 0x2
#define CSRRC 0x3
#define CSRRWI 0x5
#define CSRRSI 0x6
#define CSRRCI 0x7


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

uint32_t readhalfWord(unsigned int address){
	if(address >= MSIZE-WORDSIZE/2) {
		cout << "ERROR: address out of range in readWord" << endl;
		return 0;
	}

	return *((uint16_t*)&(M[address]));
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
	writeWord(0, (1 << 12) | (5 << 7) | (AUIPC));
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
	opcode = instruction & 0x7F;
	rd = (instruction & 0x0F80) >> 7;
	rs1 = (instruction & 0xF8000) >> 15;
	rs2 = (instruction & 0x1F00000) >> 20;
	funct3 = (instruction & 0x7000) >> 12;
	funct7 = instruction >> 25;
	imm11_0i = instruction >> 20;
	imm11_5s = instruction >> 25;
	imm4_0s = (instruction & 0x0F80) >> 7;
	imm12b = instruction >> 31;
	imm10_5b = (instruction >> 25) & 0x3F;
	imm4_1b = (instruction & 0x0F00) >> 8;
	imm11b = (instruction & 0x080) >> 7;
	imm31_12u = instruction >> 12;
	imm20j = instruction >> 31;
	imm10_1j = (instruction >> 21) & 0x3FF;
	imm11j = (instruction >> 20) & 1;
	imm19_12j = (instruction >> 12) & 0x0FF;
}

void showRegs() {
	cout << "PC=" << PC << " " << "IR=" << IR << endl;

	for(int i=0; i<32; i++) {
		cout << "R[" << i << "]=" << R[i] << " ";
	}
	cout << endl;
}

int main(int argc, char const *argv[]) {
	/* code */
	allocMem(4096);
	progMem();

	PC = 0;

	char c = 'Y';

	while(c != 'n') {
		cout << "执行当前指令之前寄存器的内容" << endl;
		showRegs();

		IR = readWord(PC);
		PC = PC + WORDSIZE;

		decode(IR);

		switch(opcode) {
			case LUI:
				cout << "Do LUI" << endl;
				R[rd] = imm31_12u << 12;
				break;
			case AUIPC:
				cout << "Do AUIPC" << endl;
				R[rd] = PC + (imm31_12u << 12);
				break;
			case JAL:
				//TODO: 补充指令模拟代码:
				break;
			case JALR:
				//TODO: 补充指令模拟代码:
				break;
			case BRANCH:
				switch(funct3) {
					case BEQ:
						//TODO: 补充指令模拟代码:
						break;
					case BNE:
						cout << "Do BNE " << endl;
						if(R[rs1]!=R[rs2]){
							PC += ((imm12b<<12) | (imm11b<<11) | (imm10_5b<<5) | (imm4_1b<<1));
						}
						break;
					case BLT:
						//TODO: 补充指令模拟代码:
						break;
					case BGE:
						cout << "Do BGE" << endl;
						if(rs1>=rs2)
							PC = PC + ((imm12b << 12) | (imm11b << 11) | (imm10_5b << 5) | (imm4_1b << 1));
						break;
					case BLTU:
						//TODO: 补充指令模拟代码:
						break;
					case BGEU:
						//TODO: 补充指令模拟代码:
						break;
					default:
						cout << "ERROR: Unknown funct3 in BRANCH instruction " << IR << endl;
				}
				break;
			case LOAD:
				switch(funct3) {
					case LB:
						//TODO: 补充指令模拟代码:
						break;
					case LH:
						cout << "Do LH " << endl;
						unsigned int re2,imm2;
						imm2=imm11_0i>>11;
						if(imm2==1){
							re2=(0xfffff000 | imm11_0i);
						}else{
							re2=(0 | imm11_0i);
						}
						R[rd]=readhalfWord(R[rs1]+re2);	
						break;
					case LW:
						//TODO: 补充指令模拟代码:
						break;
					case LBU:
						cout << "Do LBU" << endl;
						R[rd] = R[imm11_0i + rs1] & 0x07;
						break;
					case LHU:
						//TODO: 补充指令模拟代码:
						break;
					default:
						cout << "ERROR: Unknown funct3 in LOAD instruction " << IR << endl;
				}
				break;
			case STORE:
				switch(funct3) {
					case SB:
						//TODO: 补充指令模拟代码:
						break;
					case SH:
						//TODO: 补充指令模拟代码:
						break;
					case SW:
						//TODO: 补充指令模拟代码:
						break;
					default:
						cout << "ERROR: Unknown funct3 in STORE instruction " << IR << endl;
				}
				break;
			case ALUR1:
				switch(funct3) {
					case ADDI:
						cout <<	"Do ADDI" << endl;
						unsigned int re3,imm3;
						imm3=imm11_0i>>11;
						if(imm3==1){
							re3=(0xfffff000 | imm11_0i);
						}else{
							re3=(0 | imm11_0i);
						}
						R[rd]=R[rs1]+re3;
						break;
					case SLTI:
						//TODO: 补充指令模拟代码:
						break;
					case SLTIU:
						cout << "Do SLTIU" << endl;
						if(rs1<imm11_0i)
							R[rd] = 1;
						else
							R[rd] = 0;
						break;
					case XORI:
						//TODO: 补充指令模拟代码:
						break;
					case ORI:
						//TODO: 补充指令模拟代码:
						break;
					case ANDI:
						//TODO: 补充指令模拟代码:
						break;
					case SLLI:
						cout << "Do SLLI " << endl;
						unsigned int imm4;
						imm4=0x0000001f & imm11_0i;
						R[rd]=R[rs1]<<imm4;
						break;
					case SHR:
						switch(imm11_0i >> 5) {
							case SRLI:
								//TODO: 补充指令模拟代码:
								break;
							case SRAI:
								cout << "Do SRAI" << endl;
								R[rd] = (rs1 & 0x10) + (rs1 >> 1);
								for(int i=1;i<(imm11_0i & 0x1F);i++){
									R[rd] = (R[rd] & 0x10) | (R[rd] >> 1);
								}break;
							default:
								cout << "ERROR: unknown (imm11_0i >> 5) in ALUR1 SHR instruction " << IR << endl;
						}
						break;
					default:
						cout << "ERROR: unknown funct3 in ALUR1 instruction " << IR << endl;
				}
				break;
			case ALUR2:
				switch(funct3) {
					case ADDSUB:
						switch(funct7) {
							case ADD:
								//TODO: 补充指令模拟代码:
								break;
							case SUB:
								//TODO: 补充指令模拟代码:
								break;
							default:
								cout << "ERROR: unknown funct7 in ALUR2 ADDSUB instruction " << IR << endl;
						}
						break;
					case SLL:
						//TODO: 补充指令模拟代码:
						break;
					case SLT:
						cout << "Do SLT " << endl;
						if(R[rs1]<R[rs2]){
							R[rd]=1;
						}else{
							R[rd]=0;
						}
						break;
					case SLTU:
						//TODO: 补充指令模拟代码:
						break;
					case XOR:
						//TODO: 补充指令模拟代码:
						break;
					case OR:
						//TODO: 补充指令模拟代码:
						break;
					case AND:
						//TODO: 补充指令模拟代码:
						break;
					case SRLA:
						switch(funct7) {
							case SRL:
								//TODO: 补充指令模拟代码:
								break;
							case SRA:
								//TODO: 补充指令模拟代码:
								break;
							default:
								cout << "ERROR: unknown funct7 in ALUR2 SRLA instruction " << IR << endl;
						}
						break;
					default:
						cout << "ERROR: unknown funct3 in ALUR2 instruction " << IR << endl;
				}
				break;
			case FENCES:
				switch(funct3) {
					case FENCE:
						//TODO: 补充指令模拟代码:
						break;
					case FENCE_I:
						//TODO: 补充指令模拟代码:
						break;
					default:
						cout << "ERROR: unknown funct3 in FENCES instruction " << IR << endl;
				}
				break;
			case CSRX:
				switch(funct3) {
					case CALLBREAK:
						switch(imm11_0i) {
							case ECALL:
								//TODO: 补充指令模拟代码:
								break;
							case EBREAK:
								//TODO: 补充指令模拟代码:
								break;
							default:
								cout << "ERROR: unknown imm11_0i in CSRX CALLBREAK instruction " << IR << endl;
						}
						break;
					case CSRRW:
						//TODO: 补充指令模拟代码:
						break;
					case CSRRS:
						//TODO: 补充指令模拟代码:
						break;
					case CSRRC:
						//TODO: 补充指令模拟代码:
						break;
					case CSRRWI:
						//TODO: 补充指令模拟代码:
						break;
					case CSRRSI:
						//TODO: 补充指令模拟代码:
						break;
					case CSRRCI:
						//TODO: 补充指令模拟代码:
						break;
					default:
						cout << "ERROR: unknown funct3 in CSRX instruction " << IR << endl;
				}
				break;
			default:
				cout << "ERROR: Unkown instruction " << IR << endl;
				break;
		}

		cout << "执行当前指令之后寄存器的内容" << endl;
		showRegs();

		cout << "继续模拟？（Y/n)" << endl;
		cin.get(c);
	}

	freeMem();

	return 0;
}

