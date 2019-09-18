#include<iostream>
#include<stdint.h>
using namespace std;

#define LUI 	0x37
#define ALUPC 	0x17
#define JAL 	0x6f
#define JALR 	0x67
#define BType  	0x63
#define LType	0x03
#define SType	0x23
#define IType	0x13
#define RType	0x33

#define BEQ 	0
#define BNE 	1
#define BLT 	4
#define BGE 	5
#define BLTU 	6
#define BGEU 	7


#define LB		0
#define LH		1
#define LW		2
#define LBU		4
#define LHU		5


#define SB		0
#define SH		1
#define SW		2


#define ADDI	0
#define	SLTI	2
#define	SLTIU	3
#define	XORI	4
#define	ORI		6
#define	ANDI	7
#define SLLI	1
#define SRL_AI	5

#define SRLI	0
#define SRAI	0x20


#define ADD_SUB 0
#define SLL		1
#define SLT		2
#define SLTU	3
#define XOR		4
#define SRL_SRA	5
#define OR		6
#define AND		7

#define ADD		0
#define SUB		0x20
#define SRL		0
#define SRA		0x20


uint32_t Msize=0;
const int wordsize = sizeof(uint32_t);


int allocMem(uint32_t s){
	M=new char[s];
	Msize=s;
	return s;
}

void freeMem(){
	delete[] M;
	Msize=0;
}


int32_t ReadByte(uint32_t addr,bool flag){
	if(addr>=Msize) {
		cout<<"ERROR:地址范围超出内存容量"<<endl;
		return 0;
	}
	if(flag==1)
		return M[addr];
	else
		return (unsigned char)M[addr];
}

void WriteByte(uint32_t addr,char data){
	if(addr>=Msize) {
		cout<<"ERROR:地址范围超出内存容量"<<endl;
		return;
	}
	M[addr]=data;
}

int32_t Read2Byte(uint32_t addr,bool flag){
	if(addr>=Msize-wordsize/2) {
		cout<<"ERROR:地址范围超出内存容量"<<endl;
		return 0;
	}
	if (flag==1) //返回有符号的
		return *((int16_t*)&(M[addr]));
	else
		return *((uint16_t*)&(M[addr]));
}

void Write2Byte(uint32_t addr,uint32_t data){ /
	if(addr>=Msize-wordsize/2) {
		cout<<"ERROR:地址范围超出内存容量"<<endl;
		return;
	}
	*((uint16_t*)&(M[addr]))=data;
}
int32_t ReadWord(uint32_t addr){
	if(addr>=Msize-wordsize) {
		cout<<"ERROR:地址范围超出内存容量"<<endl;
		return 0;
	}
	return *((int32_t*)&(M[addr]));
}

void WriteWord(uint32_t addr,uint32_t data){
	if(addr>=Msize-wordsize) {
		cout<<"ERROR:地址范围超出内存容量"<<endl;
		return;
	}
	*((uint32_t*)&(M[addr]))=data;
}


uint32_t R[33];
uint32_t PC,nextPC,IR;

unsigned int opcode;
unsigned int r1,r2,rd;

unsigned int func3;
unsigned int func7;



unsigned int imm31_12U;
unsigned int imm31_12U_0;

unsigned int imm31J;
unsigned int imm30_21J;
unsigned int imm20J;
unsigned int imm19_12J;
unsigned int imm_sign_31_12J;


unsigned int imm31_20JR;


unsigned int imm31B;
unsigned int imm30_25B;
unsigned int imm11_8B;
unsigned int imm7B;
unsigned int imm_sign_31_25B_11_7B;


unsigned int imm31_20L;


unsigned int imm31S;
unsigned int imm30_25S;
unsigned int imm11_7S;
unsigned int imm_sign_31_25S_11_7S;

int imm_sign_31_20I;
unsigned int shamt;


void Program(){
	/*U类指令*/
	WriteWord(0,(0x12345<<12)|(1<<7)|(LUI));
	WriteWord(4,(0x2<<12)|(2<<7)|(ALUPC));
	/*J类指令*/
	WriteWord(8,(0<<31)|(4<<21)|(0<<20)|(0<<12)|(3<<7)|(JAL));
	WriteWord(16,(12<<20)|(5<<15)|(0<<12)|(4<<7)|(JALR));
	/*B类指令*/

	WriteWord(24,(0<<31)|(0<<25)|(6<<20)|(5<<15)|(0<<12)|(4<<8)|(0<<7)|(BType));

	WriteWord(32,(0<<31)|(0<<25)|(6<<20)|(3<<15)|(1<<12)|(6<<8)|(0<<7)|(BType));

	WriteWord(44,(0<<31)|(0<<25)|(3<<20)|(6<<15)|(4<<12)|(4<<8)|(0<<7)|(BType));

	WriteWord(52,(0<<31)|(0<<25)|(6<<20)|(3<<15)|(5<<12)|(4<<8)|(0<<7)|(BType));

	WriteWord(60,(0<<31)|(0<<25)|(3<<20)|(6<<15)|(6<<12)|(4<<8)|(0<<7)|(BType));

	WriteWord(68,(0<<31)|(0<<25)|(6<<20)|(3<<15)|(7<<12)|(4<<8)|(0<<7)|(BType));

	/*L类指令*/
	M[1024]=0xfe;
	M[1025]=0xf6;
	M[1026]=0x34;
	M[1027]=0x12;

	WriteWord(76,(1012<<20)|(3<<15)|(0<<12)|(5<<7)|(LType));

	WriteWord(80,(1012<<20)|(3<<15)|(1<<12)|(6<<7)|(LType));

	WriteWord(84,(1012<<20)|(3<<15)|(2<<12)|(7<<7)|(LType));

	WriteWord(88,(1012<<20)|(3<<15)|(4<<12)|(8<<7)|(LType));

	WriteWord(92,(1012<<20)|(3<<15)|(5<<12)|(9<<7)|(LType));


	WriteWord(96,(0x10<<25)|(7<<20)|(11<<15)|(0<<12)|(0<7)|(SType));
	WriteWord(100,(0x10<<25)|(7<<20)|(11<<15)|(1<<12)|(0<7)|(SType));
	WriteWord(104,(0x10<<25)|(7<<20)|(11<<15)|(2<<12)|(0<7)|(SType));

	/*I类指令*/
	WriteWord(108,(0xfff<<20)|(3<<15)|(0<<12)|(10<<7)|(IType));
	WriteWord(112,(0xfff<<20)|(3<<15)|(2<<12)|(11<<7)|(IType));
	WriteWord(116,(0xfff<<20)|(3<<15)|(3<<12)|(12<<7)|(IType));
	WriteWord(120,(0xff3<<20)|(7<<15)|(4<<12)|(13<<7)|(IType));
	WriteWord(124,(0xf01<<20)|(2<<15)|(6<<12)|(14<<7)|(IType));
	WriteWord(128,(0xf4<<20)|(2<<15)|(7<<12)|(15<<7)|(IType));

	//移位
	WriteWord(132,(0<<25)|(4<<20)|(6<<15)|(1<<12)|(16<<7)|(IType));
	WriteWord(136,(0<<25)|(4<<20)|(6<<15)|(5<<12)|(17<<7)|(IType));
	WriteWord(140,(0x20<<25)|(4<<20)|(6<<15)|(5<<12)|(18<<7)|(IType));

	/*R类指令*/
	WriteWord(144,(0<<25)|(10<<20)|(3<<15)|(0<<12)|(19<<7)|(RType));
	WriteWord(148,(0x20<<25)|(3<<20)|(10<<15)|(0<<12)|(20<<7)|(RType));
	WriteWord(152,(0<<25)|(6<<20)|(7<<15)|(1<<12)|(21<<7)|(RType));
	WriteWord(156,(0<<25)|(7<<20)|(5<<15)|(2<<12)|(22<<7)|(RType));
	WriteWord(160,(0<<25)|(5<<20)|(7<<15)|(3<<12)|(23<<7)|(RType));

	WriteWord(164,(0<<25)|(3<<20)|(4<<15)|(4<<12)|(24<<7)|(RType));
	WriteWord(168,(0<<25)|(6<<20)|(21<<15)|(5<<12)|(25<<7)|(RType));
	WriteWord(172,(0x20<<25)|(6<<20)|(21<<15)|(5<<12)|(26<<7)|(RType));
	WriteWord(176,(0<<25)|(1<<20)|(2<<15)|(6<<12)|(27<<7)|(RType));
	WriteWord(180,(0<<25)|(1<<20)|(17<<15)|(7<<12)|(28<<7)|(RType));
void Decode(unsigned int IR){
	opcode= IR & 0x7f;
	rd= (IR>>7)& 0x1f;
	r1=	(IR>>15)&0x1f;
	r2= (IR>>20)&0x1f;
	func3=(IR>>12)&0x7;
	func7=(IR>>25)&0x7f;

	imm31_12U = (IR>>12)& 0xfffff;

	imm31J=(IR>>31) & 1;
	imm30_21J=(IR>>21) & 0x3ff;
	imm20J=(IR>>20) &1;
	imm19_12J=(IR>>12) & 0xff;

	imm31_20JR=IR>>20;
	/*B类指令*/
	imm31B=imm31J;
	imm30_25B=(IR>>25)& 0x3f;
	imm11_8B=(IR>>8)&0xf;
	imm7B=(IR>>7)&0x1;
	/*L类指令*/
	imm31_20L=IR>>20;
	/*S类指令*/
	imm31S=imm31J;
	imm30_25S=(IR>>25)&0x3f;
	imm11_7S=(IR>>7) & 0x1f;
	/*I类指令*/
	imm_sign_31_20I=(int)IR>>20;
	shamt=(IR>>20)&0x1f;

	imm31_12U_0 = imm31_12U<<12;
	imm_sign_31_12J=(imm31J<<20)&0xfff0000|(imm19_12J<<12)|(imm20J<<11)|(imm30_21J);
	imm_sign_31_25B_11_7B=(imm31B<<12)&0xffff000|(imm7B<<11)|(imm30_25B<<5)|(imm11_8B);
	imm_sign_31_25S_11_7S=(imm31S<<12)&0xffff000|(imm30_25S<<5)|imm11_7S;

}

void showRegs(){
	cout<<"PC=0x"<<hex<<PC<<"  "<<"IR=0x"<<IR<<endl;
	cout<<"32个寄存器值(16进制)分别为："<<endl;
	for(int i=1;i<33;i++){
		cout<<"R["<<dec<<i<<"]="<<hex<<R[i]<<'\t';
	}

	cout<<endl;
}

int main(){
	allocMem(4096);
	PC=0;
	Program();
	char Do='y';
	while(Do=='y'){

		cout<<"-----------------在执行指令前PC=0x"<<PC<<"--------------------"<<endl;
		showRegs();
		cout<<endl;
		IR=ReadWord(PC);
		nextPC=PC+wordsize;

		Decode(IR) ;
		switch(opcode){
			case LUI:{
				cout<<"执行LUI指令:将立即数作为高20位，低12位用0填充，结果放进rd寄存器"<<endl;
				R[rd]=imm31_12U_0;
				break;
			}
			case ALUPC:{
				cout<<"执行ALUPC指令：将立即数作为高20位，低12位用0填充，结果加上此时PC值放入rd寄存器，PC值本身不变"<<endl;
				R[rd]=imm31_12U_0+PC;
				break;
			}
			case JAL:{
				cout<<"执行JAL指令：将立即数有符号扩展*2+pc作为新的pc值，并将原pc+4放进rd寄存器"<<endl;
				R[rd]=PC+4;
				nextPC=PC+imm_sign_31_12J*2;
				break;
			}
			case JALR:{
				cout<<"执行JALR指令：将指令高12位作为立即数有符号扩展*2+r1作为新的pc值，并将原pc+4放进rd"<<endl;
				R[rd]=PC+4;
				nextPC=R[r1]+imm31_20JR*2;
				break;
			}
			case BType:{
				switch(func3){
					case BEQ:{
						cout<<"执行BEQ指令：如果r1里值=r2里值，将立即数有符号填充高20位*2+PC作为PC值"<<endl;
						if(R[r1]==R[r2]) {
							nextPC=PC+imm_sign_31_25B_11_7B*2;
						}
						break;
					}
					case BNE:{
						cout<<"执行BNE指令：如果r1里值!=r2里值，将立即数有符号填充高20位*2+PC作为PC值"<<endl;
						if(R[r1]!=R[r2]) {
							nextPC=PC+imm_sign_31_25B_11_7B*2;
						}
						break;
					}
					case BLT:{
						cout<<"执行BLT指令：进行有符号比较,如果r1里值<r2里值，将立即数有符号填充高20位*2+PC作为PC值"<<endl;
						if((int)R[r1]<(int)R[r2]) {
							nextPC=PC+imm_sign_31_25B_11_7B*2;
						}
						break;
					}
					case BGE:{
						cout<<"执行BGE指令：进行有符号比较,如果r1里值>r2里值，将立即数有符号填充高20位*2+PC作为PC值"<<endl;
						if((int)R[r1]>(int)R[r2]) {
							nextPC=PC+imm_sign_31_25B_11_7B*2;
						}
						break;
					}
					case BLTU:{
						cout<<"执行BLTU指令：进行无符号比较,如果r1里值<r2里值，将立即数有符号填充高20位*2+PC作为PC值"<<endl;
						if(R[r1]<R[r2]) {
							nextPC=PC+imm_sign_31_25B_11_7B*2;
						}
						break;
					}
					case BGEU:{
						cout<<"执行BGEU指令：进行无符号比较,如果r1里值>r2里值，将立即数有符号填充高20位*2+PC作为PC值"<<endl;
						if(R[r1]>R[r2]) {
							nextPC=PC+imm_sign_31_25B_11_7B*2;
						}
						break;
					}
						default:
						cout << "ERROR: Unknown funct3 in BRANCH instruction " << IR << endl;
				}
				break;
			}
			case LType:{
				switch(func3){
					case LB:{
						cout<<"执行LB指令：将指令高12位作为立即数有符号扩展+r1寄存器的值，作为地址，读取存储器相应地址中的字节并扩展到32位放在rd寄存器"<<endl;
						R[rd]=(int)ReadByte(R[r1]+imm31_20L,1);
						break;
					}
					case LH:{
						cout<<"执行LH指令：将指令高12位作为立即数有符号扩展+r1寄存器的值，作为地址，读取存储器相应地址中的2个字节并扩展到32位放在rd寄存器"<<endl;
						R[rd]=(int)Read2Byte(R[r1]+imm31_20L,1);
						break;
					}
					case LW:{
						cout<<"执行LW指令：将指令高12位作为立即数有符号扩展+r1寄存器的值，作为地址，读取存储器相应地址中的4个字节放在rd寄存器"<<endl;
						R[rd]=ReadWord(R[r1]+imm31_20L);
						break;
					}
					case LBU:{
						cout<<"执行LBU指令：将指令高12位作为立即数有符号扩展+r1寄存器的值，作为地址，读取存储器相应地址中的字节并无符号扩展到32位放在rd寄存器"<<endl;
						R[rd]=(uint32_t)ReadByte(R[r1]+imm31_20L,0);
						break;
					}
					case LHU:{
						cout<<"执行LHU指令：将指令高12位作为立即数有符号扩展+r1寄存器的值，作为地址，读取存储器相应地址中的2个字节并无符号扩展到32位放在rd寄存器"<<endl;
						R[rd]=(uint32_t)Read2Byte(R[r1]+imm31_20L,0);
						break;
					}
					default:
						cout<<"分支功能码不属于L型"<<endl;
						break;
				}
				break;
			}
			case SType:{
				switch(func3){
					case SB:{
						cout<<"执行SB指令：将立即数有符号扩展32位与r1寄存器相加，作为存储器地址，将r2寄存器中值低8位存进存储器"<<endl;
						WriteByte(R[r1]+imm_sign_31_25S_11_7S,(R[r2]&0xff));
						cout<<"执行指令后相应内存值为0x"<<ReadByte(512,0)<<endl;//便于测试
						break;
					}
					case SH:{
						cout<<"执行SH指令：将立即数有符号扩展32位与r1寄存器相加，作为存储器地址，将r2寄存器中值低16位存进存储器"<<endl;
						Write2Byte(R[r1]+imm_sign_31_25S_11_7S,(R[r2]&0xffff));
						cout<<"执行指令后相应内存值为0x"<<Read2Byte(512,0)<<endl;//便于测试
						break;
					}
					case SW:{
						cout<<"执行SW指令：将立即数有符号扩展32位与r1寄存器相加，作为存储器地址，将r2寄存器中值存进存储器"<<endl;
						WriteWord(R[r1]+imm_sign_31_25S_11_7S,R[r2]);
						cout<<"执行指令后相应内存值为0x"<<ReadWord(512)<<endl;//便于测试
						break;
					}
					default:
						cout<<"分支码不属于S型"<<endl;
						break;
				}
				break;
			}
			case IType:{
				switch(func3){
					case ADDI:{
						cout<<"执行ADDI指令:将立即数符号扩展与r1相加，若有溢出省略高位，保留低32位放进rd中"<<endl;
						R[rd]=(R[r1]+imm_sign_31_20I)&0xffffffff;
						break;
					}
					case SLTI:{
						cout<<"执行SLTI指令:进行有符号比较，如果r1<imm(有符号扩展)，rd=1"<<endl;
						if((int)R[r1]<imm_sign_31_20I)
							R[rd]=1;
						break;
					}
					case SLTIU:{
						cout<<"执行SLTIU指令:进行无符号比较，如果r1<imm(有符号扩展)，rd=1"<<endl;
						if((unsigned int)R[r1]<imm_sign_31_20I)
							R[rd]=1;
						break;
					}
					case XORI:{
						cout<<"执行XORI指令:进行异或操作，rd=r1^imm(符号扩展到32位)"<<endl;
						R[rd]=R[r1]^imm_sign_31_20I;
						break;
					}
					case ORI:{
						cout<<"执行ORI指令:进行或操作，rd=r1|imm(符号扩展到32位)"<<endl;
						R[rd]=R[r1]|imm_sign_31_20I;
						break;
					}
					case ANDI:{
						cout<<"执行ANDI指令:进行与操作，rd=r1&imm(符号扩展到32位)"<<endl;
						R[rd]=R[r1]&imm_sign_31_20I;
						break;
					}
					case SLLI:{
						cout<<"执行SLLI指令：进行左移操作，后面填充0，rd=r1<<shamt"<<endl;
						R[rd]=R[r1]<<shamt;
						break;
					}
					case SRL_AI:{
						switch(func7){
							case SRLI:{
								cout<<"执行SRLI指令：进行逻辑右移操作，前面填充0，rd=r1>>shamt"<<endl;
								R[rd]=R[r1]>>shamt;
								break;
							}
							case SRAI:{
								cout<<"执行SRAI指令：进行算数右移操作，前面填充最高位，rd=r1>>shamt"<<endl;
								R[rd]=(int)R[r1]>>shamt;
								break;
							}
							default:
								cout<<"func7功能码错误"<<endl;
								break;
						}
						break;
					}
					default:
						cout<<"功能分支码错误不属于I类指令"<<endl;
						break;
				}
				break;
			}
			case RType:{
				switch(func3){
					case ADD_SUB:{
						switch(func7){
							case ADD:{
								cout<<"执行ADD指令：rd=r1+r2，取低32位，忽略溢出"<<endl;
								R[rd]=R[r1]+R[r2];
								break;
							}
							case SUB:{
								cout<<"执行SUB指令：rd=r1-r2，取低32位，忽略溢出"<<endl;
								R[rd]=R[r1]-R[r2];
								break;
							}
							default:
								cout<<"func7错误"<<endl;
								break;
						}
						break;
					}
					case SLL:{
						cout<<"执行SLL指令：r1向左移动 r2值的低5位次，将结果放在rd中"<<endl;
						R[rd]=R[r1]<<(R[r2]&0x1f);
						break;
					}
					case SLT:{
						cout<<"执行SLT指令：有符号比较，如果r1<r2,将1写入rd中"<<endl;
						if((int)R[r1]<(int)R[r2])
							R[rd]=1;
						break;
					}
					case SLTU:{
						cout<<"执行SLTU指令：无符号比较，如果r1<r2,将1写入rd中"<<endl;
						if((unsigned int)R[r1]<R[r2])
							R[rd]=1;
						break;
					}
					case XOR:{
						cout<<"执行XOR指令：rd=r1^r2"<<endl;
						R[rd]=R[r1]^R[r2];
						break;
					}
					case SRL_SRA:{
						switch(func7){
							case SRL:{
								cout<<"执行SRL指令：r1右移r2低5位次，高位补0"<<endl;
								R[rd]=R[r1]>>(R[r2]&0x1f);
								break;
							}
							case SRA:{
								cout<<"执行SRA指令：r1右移r2低5位次，高位补符号位"<<endl;
								R[rd]=(int)R[r1]>>(R[r2]&0x1f);
								break;
							}
							default:
								cout<<"SRL_SRA的func7错误"<<endl;
								break;
						}
						break;
					}
					case OR:{
						cout<<"执行OR指令：rd=r1|r2"<<endl;
						R[rd]=R[r1]|R[r2];
						break;
					}
					case AND:{
						cout<<"执行AND指令：rd=r1&r2"<<endl;
						R[rd]=R[r1]&R[r2];
						break;
					}
					default:
						cout<<"不是I类指令"<<endl;
						break;
				}
				break;
			}
			default:
				cout<<"操作码不存在"<<endl;
				break;
		}

		PC=nextPC;

		cout<<"----------------执行指令后寄存器的值--------------------"<<endl;
		showRegs();
		cout<<"******************************"<<endl;
		cout<<"是否继续执行指令？(y/n)"<<endl;
		cin>>Do;
		cout<<endl;
	}
	freeMem();
	return 0;
}





