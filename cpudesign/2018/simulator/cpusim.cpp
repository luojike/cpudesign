#include <cstdint>
//#include <cstdio>
#include <iostream>

using namespace std;

// ÑÝÊ¾Ö¸Áî
#define AUIPC 0x17

// ·ÖÖ§ÀàÐÍµÄÖ¸Áî£¬ÆäÖÐBRANCHÓÃÓÚ±íÊ¾¹²Í¬µÄopcode
#define BRANCH 0x63

#define BEQ 0x0
#define BNE 0x1
#define BLT 0x4
#define BGE 0x5
#define BLTU 0x6
#define BGEU 0x7


// ×°ÔØÀàÐÍµÄÖ¸Áî£¬ÆäÖÐLOADÓÃÓÚ±íÊ¾¹²Í¬µÄopcode
#define LOAD 0x03

#define LB 0x0
#define LH 0x1
#define LW 0x2
#define LBU 0x4
#define LHU 0x5


// ±£´æÀàÐÍµÄÖ¸Áî£¬ÆäÖÐSTOREÓÃÓÚ±íÊ¾¹²Í¬µÄopcode
#define STORE 0x23

#define SB 0x0
#define SH 0x1
#define SW 0x2


// ÒÑ·ÖÅäÖ¸Áî
#define LUI 0x37
#define JAL 0x6F
#define JALR 0x67

// ÓÐÒ»¸öÔ´²Ù×÷ÊýÊÇÁ¢¼´ÊýµÄËãÊõÂß¼­ÔËËãÖ¸Áî£¬²ÉÓÃ ALUR1 ×÷Îª¹²Í¬µÄopcode·ûºÅ
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


// Ô´²Ù×÷Êý¶¼À´×ÔÓÚ¼Ä´æÆ÷µÄËãÊõÂß¼­ÔËËãÖ¸Áî£¬²ÉÓÃ ALUR2 ×÷Îª¹²Í¬µÄopcode·ûºÅ
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

// ÁíÍâ·ÖÅäµÄÖ¸Áî

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


// ÄÚ´æÄ£ÄâÆ÷
// ÄÚ´æÄ£ÄâÆ÷ÓÐ¹ØÊý¾Ý
const int WORDSIZE = sizeof(uint32_t);
unsigned int MSIZE = 4096;
char* M;

// ÄÚ´æÄ£ÄâÆ÷ÓÐ¹Øº¯Êý
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

// Õâ¸öº¯ÊýÖ±½ÓÐ´ÈëÒª²âÊÔµÄÖ¸Áî
void progMem() {
	// ´ÓµØÖ·0¿ªÊ¼Ð´Èë²âÊÔÖ¸Áî
	writeWord(0, (1 << 12) | (5 << 7) | (AUIPC));
}


// CPUÄ£ÄâÆ÷ÓÐ¹ØÊý¾Ý
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

// CPUÄ£ÄâÆ÷ÓÐ¹Øº¯Êý
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
		cout << "Ö´ÐÐµ±Ç°Ö¸ÁîÖ®Ç°¼Ä´æÆ÷µÄÄÚÈÝ" << endl;
		showRegs();

		IR = readWord(PC);
		PC = PC + WORDSIZE;

		decode(IR);

		switch(opcode) {
			case LUI:
				//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
				break;
			case AUIPC:
				cout << "Do AUIPC" << endl;
				R[rd] = PC + (imm31_12u << 12);
				break;
			case JAL:
				//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
				break;
			case JALR:
				//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
				break;
			case BRANCH:
				switch(funct3) {
					case BEQ:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						cout << "DO BLTU" << endl;
						unsigned int scr1 =R[rs1];
						unsigned int scr2 = R[rs2];
						unsigned int imm_temp;
						if(scr1==scr2){
							imm_temp=imm12b<<12|imm11b<<11|imm10_5b<<5|imm4_1b<<1;
						}else {
							PC=PC+imm_temp;
						}
						break;
					case BNE:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case BLT:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case BGE:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case BLTU:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case BGEU:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					default:
						cout << "ERROR: Unknown funct3 in BRANCH instruction " << IR << endl;
				}
				break;
			case LOAD:
				switch(funct3) {
					case LB:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						cout << "DO LB" << endl;
						int unsigned data,imm_temp;
						char data;
						imm_temp= imm11_0i>>11; 
						if(imm_temp==1){
							imm_temp = imm11_0i|0xfffff000;
						}else {
							imm_temp= (0|imm11_0i);
						}
						data = writeByte(imm_temp);
						R[rs1]=data;
						break;
					case LH:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case LW:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case LBU:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case LHU:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					default:
						cout << "ERROR: Unknown funct3 in LOAD instruction " << IR << endl;
				}
				break;
			case STORE:
				switch(funct3) {
					case SB:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case SH:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case SW:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						cout << "DO SW" << endl;
						unsigned int imm_temp;
						char d;
						d=R[rs2]&oxffffffff;
						unsigned int a;
						imm_temp=imm11_5s<<5|imm4_0s;
						if(imm11_5s & 0x800) {
							imm_temp = 0xffff0000|imm11_5<<5|imm4_0s;
						}
						a=R[rs1]+imm_temp;
						writeByte(a,d);
						break;
					default:
						cout << "ERROR: Unknown funct3 in STORE instruction " << IR << endl;
				}
				break;
			case ALUR1:
				switch(funct3) {
					case ADDI:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case SLTI:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case SLTIU:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case XORI:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case ORI:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case ANDI:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						cout << "DO ANDI"<<endl;
						unsigned int re3,imm3;
						imm3=imm11_0i>>11;
						if(imm3==1){
							re3=(0xfffff000|imm11_0i);
						}else{
							re3=(0|imm11_0i);	
						}
						R[rd]=R[rs1]&re3;
						break;
					case SLLI:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case SHR:
						switch(imm11_0i >> 5) {
							case SRLI:
								//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
								break;
							case SRAI:
								//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
								break;
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
								//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
								break;
							case SUB:
								//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
								break;
							default:
								cout << "ERROR: unknown funct7 in ALUR2 ADDSUB instruction " << IR << endl;
						}
						break;
					case SLL:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						cout << "DO SLL" << endl;
						unsigned int rsTransform;
						rsTransform = R[rs1]&0x1f;
						R[rs2] << rsTransform;
						break;
					case SLT:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case SLTU:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case XOR:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case OR:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case AND:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case SRLA:
						switch(funct7) {
							case SRL:
								//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
								break;
							case SRA:
								//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
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
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case FENCE_I:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						cout<<"nop"<<endl;
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
								//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
								break;
							case EBREAK:
								//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
								break;
							default:
								cout << "ERROR: unknown imm11_0i in CSRX CALLBREAK instruction " << IR << endl;
						}
						break;
					case CSRRW:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case CSRRS:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						{	
						uint32_t temp=imm11j&0x00000fff;
						rd=(temp|rs1)&0x1f;
						break;
						}
					case CSRRC:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case CSRRWI:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						{	
							uint32_t temp=imm11j;
							uint32_t zmm=rs1&0x000001f;
							if(rd!=0x0)
							{	
								rd=temp&0x1f;
							}
							imm11j=zmm&0xfff;
							break;
						}
					case CSRRSI:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						break;
					case CSRRCI:
						//TODO: ²¹³äÖ¸ÁîÄ£Äâ´úÂë:
						{	
							uint32_t temp=imm11j;
							uint32_t zmm=!(rs1&0x1f);
							rd=(temp&zmm);
							break;
						}
					default:
						cout << "ERROR: unknown funct3 in CSRX instruction " << IR << endl;
				}
				break;
			default:
				cout << "ERROR: Unkown instruction " << IR << endl;
				break;
		}

		cout << "Ö´ÐÐµ±Ç°Ö¸ÁîÖ®ºó¼Ä´æÆ÷µÄÄÚÈÝ" << endl;
		showRegs();

		cout << "¼ÌÐøÄ£Äâ£¿£¨Y/n)" << endl;
		cin.get(c);
	}

	freeMem();

	return 0;
}


