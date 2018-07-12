#include <cstdint>
//#include <cstdio>
#include <iostream>

using namespace std;

// 婕旂ず鎸囦护
#define AUIPC 0x17

// 鍒嗘敮绫诲瀷鐨勬寚浠わ紝鍏朵腑BRANCH鐢ㄤ簬琛ㄧず鍏卞悓鐨刼pcode
#define BRANCH 0x63

#define BEQ 0x0
#define BNE 0x1
#define BLT 0x4
#define BGE 0x5
#define BLTU 0x6
#define BGEU 0x7


// 瑁呰浇绫诲瀷鐨勬寚浠わ紝鍏朵腑LOAD鐢ㄤ簬琛ㄧず鍏卞悓鐨刼pcode
#define LOAD 0x03

#define LB 0x0
#define LH 0x1
#define LW 0x2
#define LBU 0x4
#define LHU 0x5


// 淇濆瓨绫诲瀷鐨勬寚浠わ紝鍏朵腑STORE鐢ㄤ簬琛ㄧず鍏卞悓鐨刼pcode
#define STORE 0x23

#define SB 0x0
#define SH 0x1
#define SW 0x2


// 宸插垎閰嶆寚浠?
#define LUI 0x37
#define JAL 0x6F
#define JALR 0x67

// 鏈変竴涓簮鎿嶄綔鏁版槸绔嬪嵆鏁扮殑绠楁湳閫昏緫杩愮畻鎸囦护锛岄噰鐢?ALUR1 浣滀负鍏卞悓鐨刼pcode绗﹀彿
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


// 婧愭搷浣滄暟閮芥潵鑷簬瀵勫瓨鍣ㄧ殑绠楁湳閫昏緫杩愮畻鎸囦护锛岄噰鐢?ALUR2 浣滀负鍏卞悓鐨刼pcode绗﹀彿
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

// 鍙﹀鍒嗛厤鐨勬寚浠?

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


// 鍐呭瓨妯℃嫙鍣?
// 鍐呭瓨妯℃嫙鍣ㄦ湁鍏虫暟鎹?
const int WORDSIZE = sizeof(uint32_t);
unsigned int MSIZE = 4096;
char* M;

// 鍐呭瓨妯℃嫙鍣ㄦ湁鍏冲嚱鏁?
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

// 杩欎釜鍑芥暟鐩存帴鍐欏叆瑕佹祴璇曠殑鎸囦护
void progMem() {
	// 浠庡湴鍧€0寮€濮嬪啓鍏ユ祴璇曟寚浠?
	writeWord(0, (1 << 12) | (5 << 7) | (AUIPC));
}


// CPU妯℃嫙鍣ㄦ湁鍏虫暟鎹?
uint32_t PC;
uint32_t R[32];
uint32_t IR;

unsigned int opcode;
unsigned int rs1, rs2, rd;
unsigned int funct7, funct3;
unsigned int imm_temp;
unsigned int scr1,scr2;
unsigned int scr3,scr4;

// immediate values for I-type, S-type, B-type, U-type, J-type
unsigned int imm11_0i;
unsigned int imm11_5s, imm4_0s;
unsigned int imm12b, imm10_5b, imm4_1b, imm11b;
unsigned int imm31_12u;
unsigned int imm20j, imm10_1j, imm11j, imm19_12j;

// CPU妯℃嫙鍣ㄦ湁鍏冲嚱鏁?
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
		cout << "鎵ц褰撳墠鎸囦护涔嬪墠瀵勫瓨鍣ㄧ殑鍐呭" << endl;
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
				cout << "Do JAL" << endl;
                imm_temp=imm20j<<20|imm19_12j<<12|imm11j<<11|imm10_1j<<1;
                R[rd]=PC;
				if(imm20j==1){
                    PC = PC+(0xffe00000|imm20j<<20|imm19_12j<<12|imm11j<<11|imm10_1j<<1);	
				}
				else
				    PC = PC+imm_temp;
				break;
			case JALR:
				unsigned int imm_temp;
				imm_temp=imm20j<<20|imm19_12j<<12|imm11j<<11|imm10_1j<<1;
				R[rd]=PC;
				if(imm20j==1){
					PC=R[rs1]+(0xffe00000|imm19_12j<<12|imm11j<<1|imm10_1j<<1);
				}
				else
					PC=R[rs1]+(imm_temp);
				break;
			case BRANCH:
				switch(funct3) {
					case BEQ:
<<<<<<< HEAD
						//TODO: 补充指令模拟代码:
						cout << "DO BLTU" << endl;
						unsigned int scr1 =R[rs1];
						unsigned int scr2 = R[rs2];
						unsigned int imm_temp;
						if(scr1==scr2){
							imm_temp=imm12b<<12|imm11b<<11|imm10_5b<<5|imm4_1b<<1;
						}else {
							PC=PC+imm_temp;
						}
=======
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
>>>>>>> 0552259fb2951aa7fcf17469fbca82b933bd6820
						break;
					case BNE:
						cout << "Do BNE " << endl;
						if(R[rs1]==R[rs2]){
							PC += ((imm12b<<12) | (imm11b<<11) | (imm10_5b<<5) | (imm4_1b<<1));
						}
						break;
					case BLT:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case BGE:
						cout << "Do BGE" << endl;
						if(R[rs1]>=R[rs2])
							PC = PC + ((imm12b << 12) | (imm11b << 11) | (imm10_5b << 5) | (imm4_1b << 1));
						break;
					case BLTU:
						cout << "Do BLTU" << endl;
					    scr1=R[rs1];
                        scr2=R[rs2];  	
                	    if(scr1<scr2){
                		   imm_temp=imm12b<<12|imm11b<<11|imm10_5b<<5|imm4_1b<<1;
                		   if(imm12b==1){
                	          PC=PC+(0xffffe000|imm_temp);
				            }
				        else
				           PC=PC+imm_temp;
					    }
						break;
					case BGEU:
						cout<<"Do BGEU"<<endl;
						 scr3=R[rs1];
						 scr4=R[rs2];
						unsigned int imm_temp;
						if(scr3<scr4){
							imm_temp=imm12b<<12|imm11b<<11|imm10_5b<<5|imm4_1b<<1;
							if(imm12b==1){
								PC=PC+(0xffffe000|imm_temp);
							}
						}
						break;
					default:
						cout << "ERROR: Unknown funct3 in BRANCH instruction " << IR << endl;
				}
				break;
			case LOAD:
				switch(funct3) {
					case LB:
<<<<<<< HEAD
						//TODO: 补充指令模拟代码:
						cout << "DO LB" << endl;
						int unsigned data,imm_temp;
						char data;
						imm_temp = imm11_0i|oxff000000;
						data = writeByte(imm11_0i,imm_temp)
						R[rs1]=data;
=======
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
>>>>>>> 0552259fb2951aa7fcf17469fbca82b933bd6820
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
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case LBU:
						cout << "Do LBU" << endl;
						R[rd] = R[imm11_0i + R[rs1]] & 0x07;
						break;
					case LHU:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					default:
						cout << "ERROR: Unknown funct3 in LOAD instruction " << IR << endl;
				}
				break;
			case STORE:
				switch(funct3) {
					case SB:
						cout << "Do SB" << endl;
            		    char d;
					    d=R[rs2] & 0xff;
            		    unsigned int a;
					    imm_temp=imm11_5s<<5|imm4_0s;
            		    if(imm11_5s & 0x800){
            		    	imm_temp=0xfffff000|imm11_5s<<5|imm4_0s;
					    }
					    a = R[rs1] + imm_temp;
            		    writeByte(a, d);
						break;
					case SH:
						cout<<"Do SH"<<endl;
						unsigned int imm_temp;
						char j;
						j=R[rs2]&0xffff;
						unsigned int x;
						imm_temp=imm11_5s<<5|imm4_0s;
						if(imm11_5s& 0x800){
							imm_temp=0xfffff000|imm11_5s<<5|imm4_0s;
						}
						x=R[rs1]+imm_temp;
						writeByte(x,j);
						break;
					case SW:
<<<<<<< HEAD
						//TODO: 补充指令模拟代码:
						cout << "DO SW" << endl;
						unsigned int imm_temp;
						char d;
						d=R[rs2]&oxffffffff;
						unsigned int a;
						imm_temp=imm11_5s<<5|imm4_0s;
						if(imm11_5s & 0x800) {
							imm_temp = 0xffff000|imm11_5<<5|imm4_0s;
						}
						a=R[rs1]+imm_temp;
						writeByte(a,d);
=======
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
>>>>>>> 0552259fb2951aa7fcf17469fbca82b933bd6820
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
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case SLTIU:
						cout << "Do SLTIU" << endl;
						if(R[rs1]<imm11_0i)
							R[rd] = 1;
						else
							R[rd] = 0;
						break;
					case XORI:
						cout << "Do XORI" << endl;
                        imm_temp = imm11_0i;
                	    if(imm11_0i & 0x800) {
                		    imm_temp = imm_temp | 0xfffff000;
					    }
                        R[rd]=(imm_temp)^R[rs1];
						break;
					case ORI:
						cout<<"Do ORI"<<endl;
						unsigned int re223,imm223;
						imm223=imm11_0i>>11;
						if(imm223==1){
						re223=(0xfffff000  | imm11_0i);
						}else{
						re223=(0 | imm11_0i);
						}
						R[rd]=R[rs1]|re223;
						break;
					case ANDI:
<<<<<<< HEAD
						//TODO: 补充指令模拟代码:
						cout << "DO ANDI"<<endl;
						unsigned int re3,imm3;
						imm3=imm11_0i>>11;
						if(imm3==1){
							re3=(0xfffff000|imm11_0i);
						}else{
							re3=(0|imm11_0i);	
						}
						R[rd]=R[rs1]&re3;
=======
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
>>>>>>> 0552259fb2951aa7fcf17469fbca82b933bd6820
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
								//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
								break;
							case SRAI:
								cout << "Do SRAI" << endl;
								R[rd] = (R[rs1] & 0x10) + (R[rs1] >> 1);
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
								cout << "Do ADD" << endl;
								R[rd]=R[rs1]+R[rs2];
								break;
							case SUB:
								cout<<" Do SUB"<<endl;
			                	R[rd]=R[rs1]-R[rs2];
								break;
							default:
								cout << "ERROR: unknown funct7 in ALUR2 ADDSUB instruction " << IR << endl;
						}
						break;
					case SLL:
<<<<<<< HEAD
						//TODO: 补充指令模拟代码:
						cout<<"DO SLL"<<endl;
						unsigned int rsTransform;
						rsTransform=R[rs1]&0x1f;
						R[rs2]<<rsTransform;
=======
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
>>>>>>> 0552259fb2951aa7fcf17469fbca82b933bd6820
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
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case XOR:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case OR:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case AND:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case SRLA:
						switch(funct7) {
							case SRL:
								//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
								break;
							case SRA:
								//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
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
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case FENCE_I:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
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
								//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
								break;
							case EBREAK:
								//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
								break;
							default:
								cout << "ERROR: unknown imm11_0i in CSRX CALLBREAK instruction " << IR << endl;
						}
						break;
					case CSRRW:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case CSRRS:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case CSRRC:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case CSRRWI:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case CSRRSI:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					case CSRRCI:
						//TODO: 琛ュ厖鎸囦护妯℃嫙浠ｇ爜:
						break;
					default:
						cout << "ERROR: unknown funct3 in CSRX instruction " << IR << endl;
				}
				break;
			default:
				cout << "ERROR: Unkown instruction " << IR << endl;
				break;
		}

		cout << "鎵ц褰撳墠鎸囦护涔嬪悗瀵勫瓨鍣ㄧ殑鍐呭" << endl;
		showRegs();

		cout << "缁х画妯℃嫙锛燂紙Y/n)" << endl;
		cin.get(c);
	}

	freeMem();

	return 0;
}


