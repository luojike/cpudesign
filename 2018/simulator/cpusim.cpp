#include <cstdint>
#include <iostream>

using namespace std;

// Instructions identified by opcode
#define AUIPC 0x17
#define LUI 0x37
#define JAL 0x6F
#define JALR 0x67


// Branches using BRANCH as the label for common opcode
#define BRANCH 0x63

#define BEQ 0x0
#define BNE 0x1
#define BLT 0x4
#define BGE 0x5
#define BLTU 0x6
#define BGEU 0x7


// Loads using LOAD as the label for common opcode
#define LOAD 0x03

#define LB 0x0
#define LH 0x1
#define LW 0x2
#define LBU 0x4
#define LHU 0x5


// Stores using STORE as the label for common opcode
#define STORE 0x23

#define SB 0x0
#define SH 0x1
#define SW 0x2


// ALU ops with one immediate
#define ALUIMM 0x13

#define ADDI 0x0
#define SLTI 0x2
#define SLTIU 0x3
#define XORI 0x4
#define ORI 0x6
#define ANDI 0x7
#define SLLI 0x1

#define SHR 0x5  // common funct3 for SRLI and SRAI

#define SRLI 0x0
#define SRAI 0x20


// ALU ops with all register operands
#define ALURRR 0x33

#define ADDSUB 0x0  // common funct3 for ADD and SUB
#define ADD 0x0
#define SUB 0x20

#define SLL 0x1
#define SLT 0x2
#define SLTU 0x3
#define XOR 0x4
#define OR 0x6
#define AND 0x7

#define SRLA 0x5  // common funct3 for SRL and SRA

#define SRL 0x0
#define SRA 0x20

// Fences using FENCES as the label for common opcode

#define FENCES 0x0F
#define FENCE 0x0
#define FENCE_I 0x1

// CSR related instructions
#define CSRX 0x73

#define CALLBREAK 0x0  // common funct3 for ECALL and EBREAK
#define ECALL 0x0
#define EBREAK 0x1

#define CSRRW 0x1
#define CSRRS 0x2
#define CSRRC 0x3
#define CSRRWI 0x5
#define CSRRSI 0x6
#define CSRRCI 0x7


// Data for memory
const int WORDSIZE = sizeof(uint32_t);
unsigned int MSize = 4096;
char* M;

// Functions for memory
int allocMem(uint32_t s) {
	M = new char[s];
	MSize = s;

	return s;
}

void freeMem() {
	delete[] M;
	MSize = 0;
}

char readByte(unsigned int address) {
	if(address >= MSize) {
		cout << "ERROR: Address out of range in readByte" << endl;
		return 0;
	}

	return M[address];
}

void writeByte(unsigned int address, char data) {
	if(address >= MSize) {
		cout << "ERROR: Address out of range in writeByte" << endl;
		return;
	}

	M[address] = data;
}

uint32_t readWord(unsigned int address) {
	if(address >= MSize-WORDSIZE) {
		cout << "ERROR: Address out of range in readWord" << endl;
		return 0;
	}

	return *((uint32_t*)&(M[address]));
}

uint32_t readHalfWord(unsigned int address){
	if(address >= MSize-WORDSIZE/2) {
		cout << "ERROR: Address out of range in readWord" << endl;
		return 0;
	}

	return *((uint16_t*)&(M[address]));
}

void writeWord(unsigned int address, uint32_t data) {
	if(address >= MSize-WORDSIZE) {
		cout << "ERROR: Address out of range in writeWord" << endl;
		return;
	}

	*((uint32_t*)&(M[address])) = data;
}

void writeHalfWord(unsigned int address, uint32_t data) {
	if(address >= MSize-WORDSIZE/2) {
		cout << "ERROR: Address out of range in writeWord" << endl;
		return;
	}

	*((uint16_t*)&(M[address])) = data;
}

// Write memory with instructions to test
void progMem() {
	// Write starts with PC at 0
	writeWord(0, (0xfffff << 12) | (2 << 7) | (LUI));
	writeWord(4, (1 << 12) | (5 << 7) | (AUIPC));
	writeWord(8, (0x20<<25) | (5<<20) | (0<<15) | (SW << 12) | (0 << 7) | (STORE));
	writeWord(12, (0x400<<20) | (0<<15) | (LB<<12) | (3<<7) | (LOAD));
	writeWord(16, (0x400<<20) | (0<<15) | (LBU<<12) | (7<<7) | (LOAD));
	writeWord(20, (0x0<<25) | (2<<20) | (0<<15) | (BGE<<12) | (0x8<<7) | (BRANCH));
	writeWord(28, (0x8<<20) | (3<<15) | (SLTIU<<12) | (8<<7) | (ALUIMM));
	writeWord(32, (SRAI<<25) | (0x2<<20) | (0x2<<15) | (SHR<<12) | (9<<7) | (ALUIMM));
	
	writeWord(36,(0x400)<<20|(1<<15)|(JALR<<12)|(4<<7)|(JALR));
	writeWord(40, (0x20<<25) | (7<<20) | (0<<15) | (SH << 12) | (9 << 7) | (STORE));
	writeWord(44, (0x0<<25) | (4<<20) | (1<<15) | (BGEU<<12) | (0x8<<7) | (BRANCH));
	writeWord(48, (0x400<<20) | (2<<15) | (ORI<<12) | (4<<7) | (ALUIMM));
	writeWord(52, (SUB<<25) | (4<<20) | (2<<15) | (SUB << 12) | (9 << 7) | (ALURRR));
	
	writeWord(56, (1<<31) |(0<<25) | (8<<20) | (0<<15) | (BLTU << 12) | (0 << 11) |(0 << 7) | (BRANCH));
	writeWord(60, (0x20<<25) | (8<<20) | (0<<15) | (SB << 12) | (0 << 7) | (STORE));
	writeWord(64, (0x100<<20) | (3<<15) | (XORI << 12) | (9 << 7) | (ALUIMM));
	writeWord(68, (ADD<<25) | (3<<20) | (1<<15) | (ADDSUB << 12) | (10 << 7) | (ALURRR));
	writeWord(72, (1 << 31) |(1 << 23) |(1 << 22) |(1 << 12) | (7 << 7) | (JAL));
	
	writeWord(0, 0x0013ab73);// CSRRS
	writeWord(4, 0x0013db73);//CSRRWI
	writeWord(8, 0x0013fb73);//CSRRCI
	writeWord(12, 0x0000100f);//FENCE_I
	writeWord(16, 0x00100073);//EBREAK,默认跳转到pc为4的位置
}

// ============================================================================


// data for CPU
uint32_t PC, NextPC;
uint32_t R[32];
uint32_t IR;

unsigned int opcode;
unsigned int rs1, rs2, rd;
unsigned int funct7, funct3;
unsigned int shamt;
unsigned int pred, succ;
unsigned int csr, zimm;

// immediate values for I-type, S-type, B-type, U-type, J-type
unsigned int imm11_0i;
unsigned int imm11_5s, imm4_0s;
unsigned int imm12b, imm10_5b, imm4_1b, imm11b;
unsigned int imm31_12u;
unsigned int imm20j, imm10_1j, imm11j, imm19_12j;

unsigned int imm_temp;
unsigned int src1,src2;


unsigned int Imm11_0ItypeZeroExtended;
int Imm11_0ItypeSignExtended;
int Imm11_0StypeSignExtended;
unsigned int Imm12_1BtypeZeroExtended;
int Imm12_1BtypeSignExtended;
unsigned int Imm31_12UtypeZeroFilled;
int Imm20_1JtypeSignExtended;
int Imm20_1JtypeZeroExtended;

// Functions for CPU
void decode(uint32_t instruction) {
	// Extract all bit fields from instruction
	opcode = instruction & 0x7F;
	rd = (instruction & 0x0F80) >> 7;
	rs1 = (instruction & 0xF8000) >> 15;
	zimm = rs1;
	rs2 = (instruction & 0x1F00000) >> 20;
	shamt = rs2;
	funct3 = (instruction & 0x7000) >> 12;
	funct7 = instruction >> 25;
	imm11_0i = ((int32_t)instruction) >> 20;
	csr = instruction >> 20;
	imm11_5s = ((int32_t)instruction) >> 25;
	imm4_0s = (instruction >> 7) & 0x01F;
	imm12b = ((int32_t)instruction) >> 31;
	imm10_5b = (instruction >> 25) & 0x3F;
	imm4_1b = (instruction & 0x0F00) >> 8;
	imm11b = (instruction & 0x080) >> 7;
	imm31_12u = instruction >> 12;
	imm20j = ((int32_t)instruction) >> 31;
	imm10_1j = (instruction >> 21) & 0x3FF;
	imm11j = (instruction >> 20) & 1;
	imm19_12j = (instruction >> 12) & 0x0FF;
	pred = (instruction >> 24) & 0x0F;
	succ = (instruction >> 20) & 0x0F;

	// ========================================================================
	// Get values of rs1 and rs2
	src1 = R[rs1];
	src2 = R[rs2];

	// Immediate values
	Imm11_0ItypeZeroExtended = imm11_0i & 0x0FFF;
	Imm11_0ItypeSignExtended = imm11_0i;

	Imm11_0StypeSignExtended = (imm11_5s << 5) | imm4_0s;

	Imm12_1BtypeZeroExtended = imm12b & 0x00001000 | (imm11b << 11) | (imm10_5b << 5) | (imm4_1b << 1);
	Imm12_1BtypeSignExtended = imm12b & 0xFFFFF000 | (imm11b << 11) | (imm10_5b << 5) | (imm4_1b << 1);

	Imm31_12UtypeZeroFilled = instruction & 0xFFFFF000;

	Imm20_1JtypeSignExtended = (imm20j & 0xFFF00000) | (imm19_12j << 12) | (imm11j << 11) | (imm10_1j << 1);
	Imm20_1JtypeZeroExtended = (imm20j & 0x00100000) | (imm19_12j << 12) | (imm11j << 11) | (imm10_1j << 1);
	// ========================================================================
}

void showRegs() {
	cout << "PC=0x" << std::hex << PC << " " << "IR=0x" << std::hex << IR << endl;

	for(int i=0; i<32; i++) {
		cout << "R[" << i << "]=0x" << std::hex << R[i] << " ";
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
		cout << "Registers bofore executing the instruction @0x" << std::hex << PC << endl;
		showRegs();

		IR = readWord(PC);
		NextPC = PC + WORDSIZE;

		decode(IR);

		switch(opcode) {
			case LUI:
				cout << "Do LUI" << endl;
				R[rd] = Imm31_12UtypeZeroFilled;
				break;
			case AUIPC:
				cout << "Do AUIPC" << endl;
				cout << "PC = " << PC << endl;
				cout << "Imm31_12UtypeZeroFilled = " << Imm31_12UtypeZeroFilled << endl;
				R[rd] = PC + Imm31_12UtypeZeroFilled;
				break;
			case JAL:
				cout << "Do JAL" << endl;
				R[rd]=PC+4;
				NextPC = PC+ Imm20_1JtypeSignExtended;    
				break;
			case JALR:
				cout << "DO JALR" << endl;
				R[rd]=PC+4;
				NextPC=R[rs1]+Imm20_1JtypeSignExtended;
				break;
			case BRANCH:
				switch(funct3) {
					case BEQ:
						cout << "DO BEQ" << endl;
						if(src1==src2){
							NextPC = PC + Imm12_1BtypeSignExtended;
						}
						break;
					case BNE:
						cout << "Do BNE " << endl;
						if(src1!=src2){
							NextPC = PC + Imm12_1BtypeSignExtended;
						}
						break;
					case BLT:
						cout << "Do BLT" << endl;
						if((int)src1<(int)src2){
							NextPC = PC + Imm12_1BtypeSignExtended;
						}
						break;
					case BGE:
						cout << "Do BGE" << endl;
						if((int)src1 >= (int)src2)
							NextPC = PC + Imm12_1BtypeSignExtended;
						break;
					case BLTU:
						cout << "Do BLTU" << endl;
						if(src1<src2){
							NextPC=PC+Imm12_1BtypeSignExtended;
						}
						break;
					case BGEU:
						cout<<"Do BGEU"<<endl;

						if(src1>=src2){
							NextPC=PC+Imm12_1BtypeSignExtended;
						}    
						break;
					default:
						cout << "ERROR: Unknown funct3 in BRANCH instruction " << IR << endl;
				}
				break;
			case LOAD:
				switch(funct3) {
					case LB:
						cout << "DO LB" << endl;
						unsigned int LB_LH,LB_LH_UP;
						cout << "LB Address is: " << src1+Imm11_0ItypeSignExtended << endl;
						LB_LH=readByte(src1+Imm11_0ItypeSignExtended);
						LB_LH_UP=LB_LH>>7;
						if(LB_LH_UP==1){
							LB_LH=0xffffff00 & LB_LH;
						}else{
							LB_LH=0x000000ff & LB_LH;
						}
						R[rd]=LB_LH; 
						break;
					case LH:
						cout << "Do LH " << endl;
						unsigned int temp_LH,temp_LH_UP;
						temp_LH=readHalfWord(src1+Imm11_0ItypeSignExtended);
						temp_LH_UP=temp_LH>>15;
						if(temp_LH_UP==1){
							temp_LH=0xffff0000 | temp_LH;
						}else{
							temp_LH=0x0000ffff & temp_LH;
						}
						R[rd]=temp_LH; 
						break;
					case LW:
						cout << "Do LW" << endl;
						unsigned int temp_LW,temp_LW_UP;
						temp_LW=readByte(src1+Imm11_0ItypeSignExtended);
						temp_LW_UP=temp_LW>>31;
						if(temp_LW_UP==1){
							temp_LW=0x00000000 | temp_LW;
						}else{
							temp_LW=0xffffffff & temp_LW;
						}
						R[rd]=temp_LW;
						break;
					case LBU:
						cout << "Do LBU" << endl;
						R[rd] = readByte(Imm11_0ItypeSignExtended + src1) & 0x000000ff;
						break;
					case LHU:
						cout << "Do LHU" << endl;
						R[rd] = readByte(Imm11_0ItypeSignExtended + src1) & 0x0000ffff;
						break;
					default:
						cout << "ERROR: Unknown funct3 in LOAD instruction " << IR << endl;
				}
				break;
			case STORE:
				switch(funct3) {
					case SB:
						cout << "Do SB" << endl;
						char sb_d1;
						unsigned int sb_a1;
						sb_d1=R[rs2] & 0xff;
						sb_a1 = R[rs1] +Imm11_0StypeSignExtended;
						writeByte(sb_a1, sb_d1);
						break;
					case SH:
						cout<<"Do SH"<<endl;
						uint16_t j;
						j=R[rs2]&0xffff;
						unsigned int x;
						x = R[rs1] + Imm11_0StypeSignExtended;
						writeHalfWord(x,j);
						break;
					case SW:
						cout << "DO SW" << endl;
						//unsigned int imm_temp;
						uint32_t _swData;
						_swData=R[rs2] & 0xffffffff;
						unsigned int _swR;
						_swR = R[rs1] + Imm11_0StypeSignExtended;
						cout << "SW Addr and Data are: " << _swR << ", " << _swData << endl;
						writeWord(_swR, _swData);
						break;
					default:
						cout << "ERROR: Unknown funct3 in STORE instruction " << IR << endl;
				}
				break;
			case ALUIMM:
				switch(funct3) {
					case ADDI:
						cout <<    "Do ADDI" << endl;
						R[rd]=src1+Imm11_0ItypeSignExtended;
						break;
					case SLTI:
						cout << "Do SLTI" << endl;
						if(src1<Imm11_0ItypeSignExtended)
							R[rd] = 1;
						else
							R[rd] = 0;
						break;
					case SLTIU:
						cout << "Do SLTIU" << endl;
						if(src1<(unsigned int)Imm11_0ItypeSignExtended)
							R[rd] = 1;
						else
							R[rd] = 0;
						break;
					case XORI:
						cout << "Do XORI" << endl;
						R[rd]=(Imm11_0ItypeSignExtended)^R[rs1];
						break;
					case ORI:
						cout<<"Do ORI"<<endl;
						R[rd]=R[rs1]|Imm11_0ItypeSignExtended;
						break;
					case ANDI:
						cout << "DO ANDI"<<endl;
						R[rd]=R[rs1]&Imm11_0ItypeSignExtended;
						break;
					case SLLI:
						cout << "Do SLLI " << endl;
						R[rd]=src1<<shamt;
						break;
					case SHR:
						switch(funct7) {
							case SRLI:
								cout << "Do SRLI" << endl;
								R[rd]=src1>>shamt;
								break;
							case SRAI:
								cout << "Do SRAI" << endl;
								R[rd] = ((int)src1) >> shamt;
								break;
							default:
								cout << "ERROR: Unknown (imm11_0i >> 5) in ALUIMM SHR instruction " << IR << endl;
						}
						break;
					default:
						cout << "ERROR: Unknown funct3 in ALUIMM instruction " << IR << endl;
				}
				break;
			case ALURRR:
				switch(funct3) {
					case ADDSUB:
						switch(funct7) {
							case ADD:
								cout << "Do ADD" << endl;
								R[rd]=R[rs1]+R[rs2];
								break;
							case SUB:
								cout<<" Do SUB"<<endl;
								R[rd]=R[rs1]-R[rs2];
								break;
							default:
								cout << "ERROR: Unknown funct7 in ALURRR ADDSUB instruction " << IR << endl;
						}
						break;
					case SLL:
						cout<<"DO SLL"<<endl;
						unsigned int rsTransform;
						rsTransform=R[rs2]&0x1f;
						R[rd]=R[rs1]<<rsTransform; 
						break;
					case SLT:
						cout << "Do SLT " << endl;
						if((int)src1<(int)src2){
							R[rd]=1;
						}else{
							R[rd]=0;
						}
						break;
					case SLTU:
						cout << "Do SLTU" << endl;
						if(src2!=0){
							R[rd]=1;
						}else{
							R[rd]=0;
						}
						break;
					case XOR:
						cout << "Do XOR " << endl;
						R[rd]=R[rs1]^R[rs2];
						break;
					case OR:
						cout << "Do OR" << endl;
								R[rd]=R[rs1]|R[rs2];
							break;
					case AND:
						cout << "Do AND" << endl;
								R[rd]=R[rs1]&R[rs2];
						break;

					case SRLA:
						switch(funct7) {
							case SRL:
				           cout<<"DO SRL"<<endl;
                                           R[rd]=R[rs1]>>R[rs2];
								break;
							case SRA:
								  cout<<"DO SRA"<<endl;
								  R[rd]=(int)src1>>src2;
								break;
							default:
								cout << "ERROR: Unknown funct7 in ALURRR SRLA instruction " << IR << endl;
						}
						break;
					default:
						cout << "ERROR: Unknown funct3 in ALURRR instruction " << IR << endl;
				}
				break;
			case FENCES:
				switch(funct3) {
					case FENCE:
						cout<<"Do FENCE"<<endl;
						cout<<"FENCE,nop"<<endl;
						break;
					case FENCE_I:
						//TODO: Fill code for the instruction here
						cout<<"fence_i,nop"<<endl;
						break;
					default:
						cout << "ERROR: Unknown funct3 in FENCES instruction " << IR << endl;
				}
				break;
			case CSRX:
				switch(funct3) {
					case CALLBREAK:
						switch(Imm11_0ItypeZeroExtended) {
							case ECALL:
								cout<<"Do ECALL"<<endl;
								R[rd]=PC+4;
								break;
							case EBREAK:
								{//TODO: Fill code for the instruction here
									PC = ebreakadd;
									cout << "do ebreak and pc jumps to :" << ebreakadd << endl;
									break;
								}
							default:
								cout << "ERROR: Unknown imm11_0i in CSRX CALLBREAK instruction " << IR << endl;
						}
						break;
					case CSRRW:
						cout<<"Do CSRRW"<<endl;
						R[rd] = src2 & 0x00000fff;
						R[rs2] = src1;
						break;
					case CSRRS:
						//TODO: Fill code for the instruction here
						{
						    uint32_t temp = readWord(rs2)&0x00000fff;
							uint32_t temp1 = rs1 & 0x000fffff;
							writeWord(rd,(temp|temp1));
							cout << "do CSRRS and the result is :" << "rd="<<readWord(rd)<<endl;
							break;
						}
					case CSRRC:
						cout<<"Do CSRRC"<<endl;
						R[rd] = src2 & 0x00000fff;
						R[rs2] = ~src1 & src2;
						break;
					case CSRRWI:
						//TODO: Fill code for the instruction here
						{	
						    if (rd == 0) break;
							else
							{
								uint32_t zmm = imm11j& 0x000001f;
								uint32_t tem = readWord(rs2) & 0x00000fff;
								writeWord(rd, tem);
								writeWord(rs2, zmm);
								cout << "do CSRRWI and the result is :" << "rd=" << readWord(rd) << endl;
								break;
							}
						}
					case CSRRSI:
						cout<<"Do CSRRSI"<<endl;
						R[rd] = src2 & 0x00000fff;
						R[rs2] = (zimm&0x0000001f) | src2;
						break;
					case CSRRCI:
						//TODO: Fill code for the instruction here
						{	uint32_t zmm = imm11j & 0x000001f;
							uint32_t tem = readWord(rs2) & 0x00000fff;
							if (readWord(rd) != 0)
							{
								writeWord(rs2, zmm | tem);
							}
							cout << "do CSRRCI and the result is :" << "rd=" << readWord(rd) << endl;
							break;
						}
					default:
						cout << "ERROR: Unknown funct3 in CSRX instruction " << IR << endl;
				}
				break;
			default:
				cout << "ERROR: Unkown instruction " << IR << endl;
				break;
		}

		// Update PC
		PC = NextPC;

		cout << "Registers after executing the instruction" << endl;
		showRegs();

		cout << "Continue simulation (Y/n)? [Y]" << endl;
		cin.get(c);
	}

	freeMem();

	return 0;
}


