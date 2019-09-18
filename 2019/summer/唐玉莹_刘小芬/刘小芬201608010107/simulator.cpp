#include <cstdint>
#include <stdint.h>
#include <iostream>
using namespace std;

#define LUI 0x37
#define AUIPC 0x17
#define JAL 0x6f
#define JALR 0x67

#define BRANCH 0x63
#define BEQ 0x0
#define BNE 0x1
#define BLT 0x4
#define BGE 0x5
#define BLTU 0x6
#define BGEU 0x7

#define LOADS 0x3
#define LB 0x0
#define LH 0x1
#define LW 0x2
#define LBU 0x4
#define LHU 0x5

#define STORES 0x23
#define SB 0x0
#define SH 0x1
#define SW 0x2

#define ALUI 0x13
#define ADDI 0x0
#define SLTI 0x2
#define SLTIU 0x3
#define XORI 0x4
#define ORI 0x6
#define ANDI 0x7
#define SLLI 0x1
#define SRXI 0x5
#define SRLI 0x0
#define SRAI 0x20

#define ALUR 0x33
#define AS 0x0
#define ADD 0x0
#define SUB 0x20
#define SLL 0x1
#define SLT 0x2
#define SLTU 0x3
#define XOR 0x4
#define SRX 0x5
#define SRL 0x0
#define SRA 0x20
#define OR 0x6
#define AND 0x7

// Data for memory
const int WORDSIZE = sizeof(uint32_t);
unsigned int MSize = 4096;
char* M;

int allocMem(uint32_t s) {
	M = new char[s];
	MSize = s;
	return s;
}

void freeMem() {
	delete[] M;
	MSize = 0;
}

uint32_t pc,nextpc,inst;
uint32_t R[32];
uint32_t IR;

void writeWord(unsigned int address, uint32_t data) {
	if(address >= MSize-WORDSIZE) {
		cout << "ERROR: Address out of range in writeWord" << endl;
		return;
	}
	*((uint32_t*)&(M[address])) = data;
}

void progMem() {
	// Write starts with PC at 0
//	writeWord(0, (0xfffff << 12) | (2 << 7) | (LUI));//0xfffff137
//	writeWord(0, (1 << 12) | (5 << 7) | (AUIPC));//0x1297   
//	writeWord(0, (1 << 31) |(1 << 23) |(1 << 22) |(1 << 12) | (7 << 7) | (JAL));//1 0000000110 0 00000001 00111 1101111,0x80c013ef,1 00000001 0 0000000110 0
//	writeWord(0,(0x400)<<20|(1<<15)|(4<<7)|(JALR));//0100 0000 0000 0000 1000 0010 0110 0111,0x40008267
//	writeWord(0, (0x0<<25) | (2<<20) | (2<<15) | (BEQ<<12) | (0x8<<7) | (BRANCH));//0000 0000 0010 0001 0000 0100 0110 0011,0x210463,0000000001000
//	writeWord(0, (0x0<<25) | (2<<20) | (0<<15) | (BNE<<12) | (0x8<<7) | (BRANCH));//0000 0000 0010 0000 0001 0100 0110 0011,0x201463,0000000001000
//	writeWord(0, (0x0<<25) | (2<<20) | (0<<15) | (BLT<<12) | (0x8<<7) | (BRANCH));//0000 0000 0010 0000 0100 0100 0110 0011,0x204463,0000000001000
//	writeWord(0, (0x0<<25) | (2<<20) | (0<<15) | (BGE<<12) | (0x8<<7) | (BRANCH));//0000 0000 0010 0000 0101 0100 0110 0011,0x205463,0000000001000
//	writeWord(0, (1<<31)|(0<<25)|(8<<20)|(0<<15)|(BLTU<<12)|(0<<11)|(0<<7)|(BRANCH));//1000 0000 1000 0000 0110 0000 0110 0011,0x80806063,1000000000000
//	writeWord(0, (0x0<<25) | (4<<20) | (1<<15) | (BGEU<<12) | (0x8<<7) | (BRANCH));//0000 0000 0100 0000 1111 0100 0110 0011,0x40f463,0000000001000
//	writeWord(0, (0x400<<20) | (0<<15) | (LB<<12) | (3<<7) | (LOADS));//0100 0000 0000 0000 0000 0001 1000 0011,0x40000183,0x400
//	writeWord(0, (0x400<<20) | (0<<15) | (LH<<12) | (3<<7) | (LOADS));//0100 0000 0000 0000 0001 0001 1000 0011,0x40001183,0x400
//	writeWord(0, (0x400<<20) | (0<<15) | (LW<<12) | (3<<7) | (LOADS));//0100 0000 0000 0000 0010 0001 1000 0011,0x40002183,0x400
//	writeWord(4, (0x400<<20) | (0<<15) | (LBU<<12) | (3<<7) | (LOADS));//0100 0000 0000 0000 0100 0001 1000 0011,0x40004183,0x400
//	writeWord(4, (0x400<<20) | (0<<15) | (LHU<<12) | (3<<7) | (LOADS));//0100 0000 0000 0000 0101 0001 1000 0011,0x40005183,0x400
//	writeWord(0, (0x20<<25) | (5<<20) | (0<<15) | (SB << 12) | (0 << 7) | (STORES));//0100 0000 0101 0000 0000 0000 0010 0011,0x40500023,010000000000
//	writeWord(0, (0x20<<25) | (7<<20) | (0<<15) | (SH << 12) | (9 << 7) | (STORES));//0100 0000 0111 0000 0001 0100 1010 0011,0x407014a3,010000001001
//	writeWord(0, (0x20<<25) | (8<<20) | (0<<15) | (SW << 12) | (0 << 7) | (STORES));//0100 0000 1000 0000 0010 0000 0010 0011,0x40802023,010000000000	
//	writeWord(0, (0x8<<20) | (3<<15) | (ADDI<<12) | (8<<7) | (ALUI));//0000 0000 1000 0001 1000 0100 0001 0011,0x818413,0x8
//	writeWord(0, (0x8<<20) | (3<<15) | (SLTI<<12) | (8<<7) | (ALUI));//0000 0000 1000 0001 1010 0100 0001 0011,0x81a413,0x8
//	writeWord(0, (0x8<<20) | (3<<15) | (SLTIU<<12) | (8<<7) | (ALUI));//0000 0000 1000 0001 1011 0100 0001 0011,0x81b413,0x8
//	writeWord(0, (0x100<<20) | (3<<15) | (XORI << 12) | (9 << 7) | (ALUI));//0001 0000 0000 0001 1100 0100 1001 0011,0x1001c413,0x100
//	writeWord(0, (0x400<<20) | (2<<15) | (ORI<<12) | (4<<7) | (ALUI));//0100 0000 0000 0001 0110 0010 0001 0011,0x40016213,0x400
//	writeWord(0, (0x100<<20) | (3<<15) | (ANDI << 12) | (9 << 7) | (ALUI));//0001 0000 0000 0001 1111 0100 1001 0011,0x1001f493,0x100
//	writeWord(0, (0x8<<20) | (3<<15) | (SLLI<<12) | (8<<7) | (ALUI));//0000 0000 1000 0001 1001 0100 0001 0011,0x819413,shamt=8
//	writeWord(0, (SRLI<<25) | (0x2<<20) | (0x2<<15) | (SRXI<<12) | (9<<7) | (ALUI));//0000 0000 0010 0001 0101 0100 1001 0011,0x215493,shamt=2
//	writeWord(0, (SRAI<<25) | (0x2<<20) | (0x2<<15) | (SRXI<<12) | (9<<7) | (ALUI));//0100 0000 0010 0001 0101 0100 1001 0011,0x40215493,shamt=2
//	writeWord(0, (ADD<<25) | (3<<20) | (1<<15) | (AS << 12) | (10 << 7) | (ALUR));//0000 0000 0011 0000 1000 0101 0011 0011,0x308533,
//	writeWord(0, (SUB<<25) | (4<<20) | (2<<15) | (AS << 12) | (9 << 7) | (ALUR));//0100 0000 0100 0001 0000 0100 1011 0011,0x404104b3
//	writeWord(0, (0x5<<25) | (4<<20) | (2<<15) | (SLL << 12) | (9 << 7) | (ALUR));//0000 1010 0100 0001 0001 0100 1011 0011,0xa4114b3
//	writeWord(0, (0x5<<25) | (4<<20) | (2<<15) | (SLT << 12) | (9 << 7) | (ALUR));//0000 1010 0100 0001 0010 0100 1011 0011,0xa4124b3
//	writeWord(0, (0x5<<25) | (4<<20) | (2<<15) | (SLTU << 12) | (9 << 7) | (ALUR));//0000 1010 0100 0001 0011 0100 1011 0011,0xa4134b3
//	writeWord(0, (0x5<<25) | (4<<20) | (2<<15) | (XOR << 12) | (9 << 7) | (ALUR));//0000 1010 0100 0001 0100 0100 1011 0011,0xa4144b3
//	writeWord(0, (SRL<<25) | (4<<20) | (2<<15) | (SRX << 12) | (9 << 7) | (ALUR));//0000 0000 0100 0001 0101 0100 1011 0011,0x4154b3
//	writeWord(0, (SRA<<25) | (4<<20) | (2<<15) | (SRX << 12) | (9 << 7) | (ALUR));//0100 0000 0100 0001 0101 0100 1011 0011,0x404154b3
//	writeWord(0, (0x5<<25) | (4<<20) | (2<<15) | (OR << 12) | (9 << 7) | (ALUR));//0000 1010 0100 0001 0110 0100 1011 0011,0xa4164b3
	writeWord(0, (0x5<<25) | (4<<20) | (2<<15) | (AND << 12) | (9 << 7) | (ALUR));//0000 1010 0100 0001 0111 0100 1011 0011,0xa4174b3
}

unsigned int opcode,rd,funct3,rs1,rs2,funct7;
unsigned int imm20j,imm19_12j,imm11j,imm10_1j,imm12br,imm11br,imm10_5br,
			imm4_1br,imm11_5s,imm4_0s,shamt;

void decode(uint32_t inst){
	opcode=inst&0x7f;
	rd=(inst>>7)&0x1f;
	funct3=(inst>>12)&0x7;
	rs1=(inst>>15)&0x1f;
	rs2=(inst>>20)&0x1f;
	funct7=(inst>>25)&0x7f;
	
	imm20j=(((uint32_t)inst)>>31)<<20;
	imm19_12j=((uint32_t)inst>>12);
	imm11j=((inst>>20)&1)<<11;
	imm10_1j=((inst>>21)&0x3ff)<<1;//JAL imm
	 
	imm12br=(inst>>31)<<12;
	imm11br=((inst>>7)&1)<<11;
	imm10_5br=((inst>>25)&0x3f)<<5;
	imm4_1br=((inst>>8)&0xf)<<1;//BRANCH imm
	
	imm11_5s=(inst>>25)<<5;
	imm4_0s=(inst>>7)&0x1f;//STORES imm
	
	shamt=rs2;//SLLI SRLI SRAI
	
}
char readByte(unsigned int address) {
	if(address >= MSize) {
		cout << "ERROR: Address out of range in readByte" << endl;
		return 0;
	}

	return M[address];
}

void writeHalfWord(unsigned int address, uint32_t data) {
	if(address >= MSize-WORDSIZE/2) {
		cout << "ERROR: Address out of range in writeWord" << endl;
		return;
	}

	*((uint16_t*)&(M[address])) = data;
}

void showRegs() {
	cout << "PC=0x" << std::hex << pc << " " << "IR=0x" << std::hex << IR << endl;

	for(int i=0; i<32; i++) {
		cout << "R[" << i << "]=0x" << std::hex << R[i] << " ";
	}
	cout << endl;
}

int main(int argc, char const *argv[]) {
	allocMem(4096);
	progMem();
	
	pc=0;
	
	char c = 'Y';
	while(c != 'n') {
	cout << "Registers bofore executing the instruction @0x" << std::hex << pc << endl;
	showRegs();

	IR = *((uint32_t*)&(M[pc]));
	nextpc = pc + WORDSIZE;

	decode(IR);
	switch(opcode) {
		case LUI:
			cout<<"Do LUI:"<<endl;
			R[rd]=(unsigned int)(IR&0xfffff000);
			break;
		case AUIPC:
			cout<<"Do AUIPC:"<<endl;
			R[rd]=pc+(unsigned int)(IR&0xfffff000);
			break;
		case JAL:
			cout<<"Do JAL:"<<endl;
			R[rd]=pc+4;
			nextpc=pc+((int)(imm20j|imm19_12j|imm11j|imm10_1j))*2;
			break;
		case JALR:
			cout<<"Do JALR:"<<endl;
			pc=R[rs1]+(int)(IR>>20);
			R[rd]=pc+4;
			break;
		case BRANCH:
			switch(funct3) {
				case BEQ:
					cout<<"Do BEQ:"<<endl;
					if(R[rs1]==R[rs2])
						nextpc=pc+((int)(imm12br|imm11br|imm10_5br|imm4_1br))*2;
					break;
				case BNE:
					cout<<"Do BNE:"<<endl;
					//R[rs1]=3;
					if(R[rs1]!=R[rs2])
						nextpc=pc+((int)(imm12br|imm11br|imm10_5br|imm4_1br))*2;
					break;
				case BLT:
					cout<<"Do BLT:"<<endl;
					//R[rs2]=3; 
					if((int)R[rs1]<(int)R[rs2])
						nextpc=pc+((int)(imm12br|imm11br|imm10_5br|imm4_1br))*2;
					break;
				case BGE:
					cout<<"Do BGE:"<<endl;
					//R[rs1]=3;
					if((int)R[rs1]>(int)R[rs2])
						nextpc=pc+((int)(imm12br|imm11br|imm10_5br|imm4_1br))*2;
					break;
				case BLTU:
					cout<<"Do BLTU:"<<endl;
					//R[rs2]=3;
					if(R[rs1]<R[rs2])
						nextpc=pc+((unsigned int)(imm12br|imm11br|imm10_5br|imm4_1br))*2;
					break;
				case BGEU:
					cout<<"Do BGEU:"<<endl;
					//R[rs1]=3;
					if(R[rs1]>R[rs2])
						nextpc=pc+((unsigned int)(imm12br|imm11br|imm10_5br|imm4_1br))*2;
					break;
			}
			break;
		case LOADS:
			switch(funct3) {
				case LB:{
					cout<<"Do LB:"<<endl;
					unsigned int x=R[rs1]+(int)(IR>>20);
					//M[x]=5;
					//M[x]=129;
					uint8_t j=M[x];
					if((j>>7)==1)
						R[rd]=0xffffff00|j;
					else
						R[rd]=0x000000ff&j;
					break;
				}
				case LH:{
					cout<<"Do LH:"<<endl;
					unsigned int x=R[rs1]+(int)(IR>>20);
					//M[x]=-1;
					int16_t j=M[x];
					if((j>>15)==1)
						R[rd]=0xffff0000|j;
					else
						R[rd]=0x0000ffff&j;
					break;
				}
				case LW:{
					cout<<"Do LW:"<<endl;
					unsigned int x=R[rs1]+(int)(IR>>20);
					//M[x]=-1;
					uint32_t j=M[x];
					if((j>>31)==1)
						R[rd]=0x00000000|j;
					else
						R[rd]=0xffffffff&j;	
					break;
				}
				case LBU:{
					cout<<"Do LBU:"<<endl;
					unsigned int x=R[rs1]+(int)(IR>>20);
					//M[x]=129;
					uint8_t j=M[x];
					R[rd]=0x000000ff&j;
					break;
				}
				case LHU:{
					cout<<"Do LHU:"<<endl;
					unsigned int x=R[rs1]+(int)(IR>>20);
					//M[x]=129;
					uint32_t j=*((uint16_t*)&M[x]);	
					R[rd]=0x0000ffff&j;
					break;
				}
			}
			break;
		case STORES:
			switch(funct3) {
				case SB:{
					cout<<"Do SB:"<<endl;
					unsigned int x=R[rs1]+(int)(imm11_5s|imm4_0s);
					uint32_t data=(R[rs2]&0xff);
					M[x]=data;
					break;
				}
				case SH:{
					cout<<"Do SH:"<<endl;
					unsigned int x=R[rs1]+(int)(imm11_5s|imm4_0s);
					uint16_t data=R[rs2]&0xffff;
					*((uint32_t*)&M[x])=data;
					break;
				}
				case SW:{
					cout<<"Do SW:"<<endl;
					unsigned int j=R[rs1]+(int)(imm11_5s|imm4_0s);
					cout<<j<<endl; 
					uint32_t data=R[rs2]&0xffffffff;
					cout<<data<<endl;
					writeWord(j,data);
					break;
				}
			}
			break;
		case ALUI:
			switch(funct3) {
				case ADDI:
					cout<<"Do ADDI:"<<endl;
					R[rd]=R[rs1]+(int)(IR>>20);
					break;
				case SLTI:
					cout<<"Do SLTI:"<<endl;
					if(R[rs1]<(int)(IR>>20))
						R[rd]=1;
					else
						R[rd]=0;
					break;
				case SLTIU:
					cout<<"Do SLTIU:"<<endl;
					if(R[rs1]<(unsigned int)(IR>>20))
						R[rd]=1;
					else
						R[rd]=0;
					break;
				case XORI:
					cout<<"Do XORI:"<<endl;
					R[rd]=R[rs1]^((int)(IR>>20));
					break;
				case ORI:
					cout<<"Do ORI:"<<endl;
					R[rd]=R[rs1]|((int)(IR>>20));
					break;
				case ANDI:
					cout<<"Do ANDI:"<<endl;
					//R[rs1]=0x100;
					R[rd]=R[rs1]&((int)(IR>>20));
					break;
				case SLLI:
					cout<<"Do SLLI:"<<endl;
					//R[rs1]=1;
					R[rd]=R[rs1]<<shamt;
					break;
				case SRXI:
					switch(funct7) {
						case SRLI:
							cout<<"Do SRLI:"<<endl;
							//R[rs1]=17;
							R[rd]=R[rs1]>>shamt;
							break;
						case SRAI:
							cout<<"Do SRAI:"<<endl;
							//R[rs1]=-17;
							R[rd]=((int)R[rs1])>>shamt;
							break;
					}
					break;
			}
			break;
		case ALUR:
			switch(funct3) {
				case AS:
					switch(funct7) {
						case ADD:
							cout<<"Do ADD:"<<endl;
							//R[rs1]=1;
							//R[rs2]=3;
							R[rd]=R[rs1]+R[rs2];
							break;
						case SUB:
							cout<<"Do SUB:"<<endl;
							R[rs1]=3;
							R[rs2]=1;
							R[rd]=R[rs1]-R[rs2];
							break;
					}
					break;
				case SLL:
					cout<<"Do SLL:"<<endl;
					//R[rs1]=1;
					//R[rs2]=0xf3;//10011,19
					R[rd]=R[rs1]<<(unsigned int)(R[rs2]&0x1f);
					break;
				case SLT:
					cout<<"Do SLT:"<<endl;
					//R[rs1]=1;
					//R[rs2]=2;
					if((int)R[rs1]<(int)R[rs2])
						R[rd]=1;
					break;
				case SLTU:
					cout<<"Do SLTU:"<<endl;
					//R[rs1]=1;
					//R[rs2]=2;
					if(R[rs1]<(unsigned int)R[rs2])
						R[rd]=1;
					break;
				case XOR:
					cout<<"Do XOR:"<<endl;
					//R[rs1]=1;
					//R[rs2]=2;
					R[rd]=R[rs1]^R[rs2];
					break;
				case SRX:
					switch(funct7) {
						case SRL:
							cout<<"Do SRL:"<<endl;
							R[rd]=R[rs1]>>(R[rs2]&0x1f);
							break;
						case SRA:
							cout<<"Do SRA:"<<endl;
							R[rd]=(int)R[rs1]>>(R[rs2]&0x1f);
							break;
					}
					break;
				case OR:
					cout<<"Do OR:"<<endl;
					R[rd]=R[rs1]|R[rs2];
					break;
				case AND:
					cout<<"Do AND:"<<endl;
					R[rd]=R[rs1]&R[rs2];
					break;
			}
			break;
	}
	pc = nextpc;
	cout << "Registers after executing the instruction" << endl;
	showRegs();
	cout << "Continue simulation (Y/n)? [Y]" << endl;
	cin>>c;
}
	freeMem();
	return 0;
}
