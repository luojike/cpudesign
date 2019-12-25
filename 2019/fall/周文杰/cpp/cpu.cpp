#include <cstdint>
#include <iostream>

using namespace std;

// Instructions identified by opcode  操作码标识的指令
#define AUIPC 0x17
#define LUI 0x37
#define JAL 0x6F
#define JALR 0x67


// Branches using BRANCH as the label for common opcode 使用分支作为常用操作码标签的分支
#define BRANCH 0x63

#define BEQ 0x0
#define BNE 0x1
#define BLT 0x4
#define BGE 0x5
#define BLTU 0x6
#define BGEU 0x7


// Loads using LOAD as the label for common opcode 使用LOAD作为常用操作码标签加载
#define LOAD 0x03

#define LB 0x0
#define LH 0x1
#define LW 0x2
#define LBU 0x4
#define LHU 0x5


// Stores using STORE as the label for common opcode 使用store作为常用操作码标签的存储
#define STORE 0x23

#define SB 0x0
#define SH 0x1
#define SW 0x2


// ALU ops with one immediate 有一个即时的ALU操作
#define ALUIMM 0x13

#define ADDI 0x0
#define SLTI 0x2
#define SLTIU 0x3
#define XORI 0x4
#define ORI 0x6
#define ANDI 0x7
#define SLLI 0x1

#define SHR 0x5  // common funct3 for SRLI and SRAI srli和srai的公共函数3

#define SRLI 0x0
#define SRAI 0x20


// ALU ops with all register operands  所有寄存器操作数的运算
#define ALURRR 0x33

#define ADDSUB 0x0  // common funct3 for ADD and SUB  ADD和SUB的公用函数 
#define ADD 0x0
#define SUB 0x20

#define SLL 0x1
#define SLT 0x2
#define SLTU 0x3
#define XOR 0x4
#define OR 0x6
#define AND 0x7

#define SRLA 0x5  // common funct3 for SRL and SRA     SRL和SRA的公用函数3 

#define SRL 0x0
#define SRA 0x20

// Fences using FENCES as the label for common opcode   使用围栏作为常用操作码标签的围栏

#define FENCES 0x0F
#define FENCE 0x0
#define FENCE_I 0x1

// CSR related instructions   CSR相关说明 
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
unsigned int MSize = 4096;//MSize是存储空间大小
char* M;//定义了一个字符型的指针，这个是用来指定存储空间的 
unsigned int ebreakadd = 4; 
// Functions for memory
int allocMem(uint32_t s) {//内存函数  申请内存函数，参数为申请内存的大小，通过M指针访问 
	M = new char[s];//申请了一个s大小的动态数组 
	MSize = s;//将s赋值给MSize 
    for(int i=0;i<s;i++){
    	//cout<<"zero";
    	M[i]=0;
	}
	return s;
}

void freeMem() {//删除M指向的数组 
	delete[] M;
	MSize = 0;
}

char readByte(unsigned int address) {//读出某一个地址上的Byte 参数是一个地址  通过返回值返回 
	if(address >= MSize) {//超出范围则报错 
		cout << "ERROR: Address out of range in readByte" << endl;
		return 0;
	}
	return M[address];//注意M是char类型的指针，所以这里是返回一个char类型的数据 
}

void writeByte(unsigned int address, char data) {//写一byte内容  参数是一个地址以及要写入的内容 
	if(address >= MSize) {
		cout << "ERROR: Address out of range in writeByte" << endl;
		return;
	}
	M[address] = data;//这里也是写入一个char类型的数据，1byte等于8bit等于一个char 
}

uint32_t readWord(unsigned int address) {                                //其实和读byte操作类似，不过把读出的数据转化成了32位类型，不对，是一次读1个Word即4Byte内容，而不是1byte内容 
	if(address >= MSize-WORDSIZE) {
		cout << "ERROR: Address out of range in readWord" << endl;
		return 0;
	}
	return *((uint32_t*)&(M[address]));
}

uint32_t readHalfWord(unsigned int address){//一次性读2byte内容即一半个Word内容 
	if(address >= MSize-WORDSIZE/2) {
		cout << "ERROR: Address out of range in readWord" << endl;
		return 0;
	}
	return *((uint16_t*)&(M[address]));
}

void writeWord(unsigned int address, uint32_t data) {//写4个byte内容 
	if(address >= MSize-WORDSIZE) {
		cout << "ERROR: Address out of range in writeWord" << endl;
		return;
	}
//IR是指令寄存器 
	*((uint32_t*)&(M[address])) = data;
}

void writeHalfWord(unsigned int address, uint32_t data) {//写半个word的内容 
	if(address >= MSize-WORDSIZE/2) {
		cout << "ERROR: Address out of range in writeWord" << endl;
		return;
	}
	*((uint16_t*)&(M[address])) = data;
}

// Write memory with instructions to test
void m_progMem(){
	writeWord(0, (0x666 << 12) | (2 << 7) | (LUI));//指令功能在第2个寄存器写入0x666
	writeWord(4, (1 << 12) | (3 << 7) | (AUIPC));//指令功能在第3个寄存器中写入PC+0x1000
	writeWord(8, (0x66 << 12) | (5 << 7) | (LUI));//指令功能在第5个寄存器写入6
	writeWord(12, (0x0<<25) | (5<<20) | (0<<15) | (SW << 12) | (0x1a << 7) | (STORE));//向(0号寄存器的值加上0x1a)地址写入5号寄存器中的值 
	writeWord(16, (0x10<<20) | (0<<15) | (LBU<<12) | (4<<7) | (LOAD));//读取0x10地址上的1byte取最后8位写入4号寄存器 
	writeWord(20, (0x0<<25) | (2<<20) | (0<<15) | (BGE<<12) | (0x8<<7) | (BRANCH));//判断0号寄存器和2号寄存器值的大小，如果大于等于则修改NextPC为 PC + Imm12_1BtypeSignExtended;
} 


// ============================================================================


//data for CPU   CPU中的数据 
uint32_t PC, NextPC;
uint32_t R[32];
uint32_t IR;  //在真实的pc中是指令寄存器，用来保存真实的指令 

unsigned int opcode;   //操作码 
unsigned int rs1, rs2, rd;   //三个寄存器
unsigned int funct7, funct3;   //用来标记funct7还是funct3 
unsigned int shamt;            
unsigned int pred, succ;
unsigned int csr, zimm;

// immediate values for I-type, S-type, B-type, U-type, J-type  五种不同类型的立即数，可以从后缀看出 
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
void decode(uint32_t instruction) {//decode是译码的意思，RV32I指令4个字节 
	// Extract all bit fields from instruction  从指令中提取所有位字段 
	opcode = instruction & 0x7F;//获取低7位，即0~6位 
	rd = (instruction & 0x0F80) >> 7;//获取从低至高第7~11位
	rs1 = (instruction & 0xF8000) >> 15;//获取第15~19位，得到第一个寄存器 
	zimm = rs1;//zimm是我们定义的一个unsigned int，把rs1赋值给了它 
	rs2 = (instruction & 0x1F00000) >> 20;//获取第20~24位，得到第二个寄存器 
	shamt = rs2;//shamt是我们定义的一个unsigned int， 把rs2赋值给了它 
	funct3 = (instruction & 0x7000) >> 12;//获取第12~14位 
	funct7 = instruction >> 25;//获取25~31位? 
	imm11_0i = ((int32_t)instruction) >> 20;//转化成有符号的再移动，对应着Itype类型的地址 
	csr = instruction >> 20;//获取20~31位，应该与上面的imm11_0i差不多，不过是无符号类型的 
	imm11_5s = ((int32_t)instruction) >> 25;//获取第25~31位数据，对应着Stype类型的地址 
	imm4_0s = (instruction >> 7) & 0x01F;//获取第7~11位数据，对应Stype类型的地址 
	imm12b = ((int32_t)instruction) >> 31;//获取第31位数据，对应Btype类型的地址 
	imm10_5b = (instruction >> 25) & 0x3F;//获取第25~30位数据，对应Btype类型的地址 
	imm4_1b = (instruction & 0x0F00) >> 8;//第8~11位，对应Btype类型的地址 
	imm11b = (instruction & 0x080) >> 7;//第7位，对应Btype类型的地址 
	imm31_12u = instruction >> 12;//第12~31位，对应Utype类型的地址 
	imm20j = ((int32_t)instruction) >> 31;//第31位，对应jtype类型的地址 
	imm10_1j = (instruction >> 21) & 0x3FF;//第21~31位，对应jtype类型的地址 
	imm11j = (instruction >> 20) & 1;//第20位，对应jtype类型的地址 
	imm19_12j = (instruction >> 12) & 0x0FF;//第12到19位，对应jtype类型的地址 
	pred = (instruction >> 24) & 0x0F;
	succ = (instruction >> 20) & 0x0F;

	// ========================================================================
	// Get values of rs1 and rs2  获取寄存器的值 
	src1 = R[rs1];
	src2 = R[rs2];

	// Immediate values   立即数值 
	Imm11_0ItypeZeroExtended = imm11_0i & 0x0FFF;//因为总共有12位，去掉符号位扩展，这个是Itype的立即数 
	Imm11_0ItypeSignExtended = imm11_0i;

	Imm11_0StypeSignExtended = (imm11_5s << 5) | imm4_0s;//这个是Stype的立即数 

	Imm12_1BtypeZeroExtended = imm12b & 0x00001000 | (imm11b << 11) | (imm10_5b << 5) | (imm4_1b << 1);//这个是Btype的立即数 
	Imm12_1BtypeSignExtended = imm12b & 0xFFFFF000 | (imm11b << 11) | (imm10_5b << 5) | (imm4_1b << 1);

	Imm31_12UtypeZeroFilled = instruction & 0xFFFFF000;//这个是Utype的立即数 

	Imm20_1JtypeSignExtended = (imm20j & 0xFFF00000) | (imm19_12j << 12) | (imm11j << 11) | (imm10_1j << 1);//这个是Jtype的立即数  
	Imm20_1JtypeZeroExtended = (imm20j & 0x00100000) | (imm19_12j << 12) | (imm11j << 11) | (imm10_1j << 1);
	// ========================================================================
}

void show32Mess(){
	cout << endl << endl;
	for(int i=0; i<32; i++) {                                                                          //打印32个寄存器的值 
	    char tp = M[i];                                                                                //cout<<(int)tp<<endl;
		cout << "M[" << i << "]=0x"  << ((unsigned int)tp&0x000000ff)<<" ";
	}
	cout << endl << endl;
}

void showRegs() {                                                                                      //用来打印寄存器的值，总共有32个寄存器,寄存器保存在R数组里 
                                                                                                       //打印pc的值 
	cout << "PC=0x" << std::hex << PC << " " << "IR=0x" << std::hex << IR << endl;
    show32Mess();
	for(int i=0; i<32; i++) {                                                                          //打印32个寄存器的值 
		cout << "R[" << i << "]=0x" << std::hex << R[i] << " ";
	}
	cout << endl<<endl;
}




int main(int argc, char const *argv[]) {
	/* code */
	allocMem(4096);//申请4096byte大小的空间 ,即M指向一个4096byte大小的空间，然后s赋值为4096 
	m_progMem();//应该是对内存进行一些初始化的操作吧，执行了一堆对申请空间进行写入的操作，详细的可以看函数实现 

	PC = 0;//pc初始为0 

	char c = 'Y';//初始化c为Y，应该是用来判断程序结束的吧 

	while(c != 'n') {
		cout << "Registers bofore executing the instruction @0x" << std::hex << PC << endl;
		showRegs();                                                                              //每次循环显示一下寄存器 
		IR = readWord(PC);                                                                       //读取pc对应的指令，一个指令是一个Word，即4byte 
		NextPC = PC + WORDSIZE;                                                                  //赋值下一个PC 
		decode(IR);                                                                              //解析指令 
		switch(opcode) {                                                                         //这个是在decode时的低7位的值，是操作码 
			case LUI:                                                                            // 执行的操作load upper imm，其实应该是加载指令吧 
				cout << "Do LUI" << endl;
				R[rd] = Imm31_12UtypeZeroFilled;                                                 //这里rd是decode取出来的值，是IR中高20位的值，这里使用的Utype指令，取的是 
				break;
			case AUIPC:                                                                          //0x17用于建立PC相对地址，使用U型格式，用0填充最低的12位， 将该偏移量添加到AUIPC指令的地址，然后将结果放入寄存器
				cout << "Do AUIPC" << endl;
				cout << "PC = " << PC << endl;
				cout << "Imm31_12UtypeZeroFilled = " << Imm31_12UtypeZeroFilled << endl;
				R[rd] = PC + Imm31_12UtypeZeroFilled;
				break;
			case JAL:                                                                              //0x6F,无条件跳转 
				cout << "Do JAL" << endl;
				R[rd]=PC+4;
				NextPC = PC+ Imm20_1JtypeSignExtended;    
				break;
			case JALR:                                                                             //0x67,无条件跳转，直接跳转指令，无条件跳转到由寄存器rs1指定的指令，并将下一条指令的地址保存到寄存器rd中 
				cout << "DO JALR" << endl;
				R[rd]=PC+4;
				NextPC=R[rs1]+Imm20_1JtypeSignExtended;
				break;
			case BRANCH://0x63分支指令 所有的BRANCH指令都用的是B类型格式，这条指令立即数就是代表偏移量 
				switch(funct3) {
					case BEQ://0x0当src1和src2寄存器相等的时候执行 
						cout << "DO BEQ" << endl;
						if(src1==src2){
							NextPC = PC + Imm12_1BtypeSignExtended;
						}
						break;
					case BNE://0x1当src1和src2寄存器不相等的时候执行 
						cout << "Do BNE " << endl;
						if(src1!=src2){
							NextPC = PC + Imm12_1BtypeSignExtended;
						}
						break;
					case BLT://0x4有符号比较当src1<src2时执行 
						cout << "Do BLT" << endl;
						if((int)src1<(int)src2){
							NextPC = PC + Imm12_1BtypeSignExtended;
						}
						break;
					case BGE://0x5有符号比较当src1>=src2时执行 
						cout << "Do BGE" << endl;
						cout<<"src1为 "<<src1<<endl;
						cout<<"src2为 "<<src2<<endl;
						cout<<"imm为 "<<Imm12_1BtypeSignExtended<<endl; 
						if((int)src1 >= (int)src2)
							NextPC = PC + Imm12_1BtypeSignExtended;
						break;
					case BLTU://0x6
						cout << "Do BLTU" << endl;
						if(src1<src2){
							NextPC=PC+Imm12_1BtypeSignExtended;
						}
						break;
					case BGEU://0x7
						cout<<"Do BGEU"<<endl;

						if(src1>=src2){
							NextPC=PC+Imm12_1BtypeSignExtended;
						}    
						break;
					default://找不到相应的指令 
						cout << "ERROR: Unknown funct3 in BRANCH instruction " << IR << endl;
				}
				break;
			case LOAD://0x03 LOAD被编码为I类型  Loads copy a value from memory to register rd
			/*The LW instruction loads a 32-bit value from memory into rd. LH loads a 16-bit value from memory,
then sign-extends to 32-bits before storing in rd. LHU loads a 16-bit value from memory but then
zero extends to 32-bits before storing in rd. LB and LBU are defined analogously for 8-bit values.*/ 
				switch(funct3) {
					case LB://加载一个byte 
						cout << "DO LB" << endl;
						unsigned int LB_LH,LB_LH_UP;
						cout << "LB Address is: " << src1+Imm11_0ItypeSignExtended << endl;
						LB_LH=readByte(src1+Imm11_0ItypeSignExtended);
						LB_LH_UP=LB_LH>>7;
						if(LB_LH_UP==1){//符号位扩展 
							//LB_LH=0xffffff00 & LB_LH;
							LB_LH=0xffffff00 | LB_LH;							
						}else{
							LB_LH=0x000000ff & LB_LH;
						}
						R[rd]=LB_LH; 
						break;
					case LH://
						cout << "Do LH" << endl;
						unsigned int temp_LH,temp_LH_UP;
						temp_LH=readHalfWord(src1+Imm11_0ItypeSignExtended);//Itype只有一个源src1 
						temp_LH_UP=temp_LH>>15;
						if(temp_LH_UP==1){//执行符号位扩展 
							temp_LH=0xffff0000 | temp_LH;
						}else{
							temp_LH=0x0000ffff & temp_LH;
						}
						R[rd]=temp_LH; 
						break;
					case LW:
						cout << "Do LW" << endl;
						unsigned int temp_LW,temp_LW_UP;
						temp_LW=readByte(src1+Imm11_0ItypeSignExtended);//这里为什么要用readByte 
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
					default://没有找到指令 
						cout << "ERROR: Unknown funct3 in LOAD instruction " << IR << endl;
				}
				break;
			case STORE://STORE指令 STORE被编码为S类型  Stores copy the value in register rs2 to memory. Stype有sr1和sr2 
			/*
			The SW, SH, and SB instructions store 32-bit, 16-bit, and 8-bit values from the low bits of registerrs2 to memory.
			*/ 
				switch(funct3) {//sr1指明了地址，sr2指明了保存的值 
					case SB:
						cout << "Do SB" << endl;
						char sb_d1;
						unsigned int sb_a1;
						sb_d1=R[rs2] & 0xff;//最多只能写8位 
						sb_a1 = R[rs1] +Imm11_0StypeSignExtended;
						writeByte(sb_a1, sb_d1);
						break;
					case SH:
						cout<<"Do SH"<<endl;
						uint16_t j;
						j=R[rs2]&0xffff;//最多只能写16位 
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
			case ALUIMM://ALUIMM指令 
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
								R[rd]=src1>>shamt;//这里的shamt是从sr2取出的数据 
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
			case ALURRR://ALURRR指令 
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
						rsTransform=R[rs2]&0x1f;//最多左移32位 
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
					case AND://与指令 
						cout << "Do AND" << endl;
								R[rd]=R[rs1]&R[rs2];
						break;

					case SRLA://右移指令 
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
			case FENCES://FENCES指令 
				switch(funct3) {
					case FENCE:
						//TODO: Fill code for the instruction here
						break;
					case FENCE_I:
						//TODO: Fill code for the instruction here
						cout<<"this is test IR "<<IR<<endl;
						cout<<"fence_i,nop"<<endl;
						break;
					default:
						cout << "ERROR: Unknown funct3 in FENCES instruction " << IR << endl;
				}
				break;
			case CSRX://CSRX指令  Itype
			//cout << "this is EBREAK !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"<<endl; 						
				switch(funct3) {
					case CALLBREAK:
						switch(Imm11_0ItypeZeroExtended) {
							case ECALL:
								//TODO: Fill code for the instruction here
								break;
							case EBREAK:
								{//TODO: Fill code for the instruction here
								    //cout << "this is EBREAK !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"<<endl; 
									NextPC = ebreakadd;
									cout << "do ebreak and pc jumps to :" << ebreakadd << endl;
									break;
								}
							default:
								cout << "ERROR: Unknown imm11_0i in CSRX CALLBREAK instruction " << IR << endl;
						}
						break;
					case CSRRW://The CSRRW (Atomic Read/Write CSR) instruction atomically swaps values in the CSRs and integer registers
						/*CSRRW指令读取旧的CSR的值，把它0扩展后写入整数寄存器rd，rs1的初始值写入CSR中，如果rd为0，则说明不能对CSR做任何操作*/
						//TODO: Fill code for the instruction here
						break;
					case CSRRS:
						/*CSRRS读取CSR中的值，0扩展，然后将其写入到整型寄存器rd，rs1的初始值被当做一个位掩码指定要在CSR中要设置的位位置，如果csr位可写，rs1中的任何高位都将导致在csr中设置相应的位。csr中的其他位不受影响（尽管csr在写入时可能会产生副作用）。*/ 
						//TODO: Fill code for the instruction here
						{
						    uint32_t temp = readWord(rs2)&0x00000fff;
							uint32_t temp1 = rs1 & 0x000fffff;
//							cout<<"temp值为0x"<<temp<<endl;
//							cout<<"temp1值为0x"<<temp1<<endl;
//							cout<<"rd的值为0x"<<rd<<endl;
//							cout<<"写入rd的值为0x"<<(temp|temp1)<<endl; 
							writeWord(rd,(temp|temp1));
							cout << "do CSRRS and the result is :" << "rd="<<readWord(rd)<<endl;
							break;
						}
					case CSRRC://队友CSRRS和CSRRC，如果rs1==x0，则指令不会写CSR寄存器 
						/*读取CSR的值，0扩展，写入rd寄存器，整数寄存器rs1中的初始值被视为指定要在csr中清除的位位置的位掩码。如果CSR位是可写的，那么RS1中的任何高位都会导致相应的位在CSR中被清除。CSR中的其他位不受影响。*/ 
						//TODO: Fill code for the instruction here
						break;
					case CSRRWI:
						//TODO: Fill code for the instruction here
						{	
						    if (rd == 0) break;
							else
							{
								uint32_t zmm = imm11j& 0x000001f;
								uint32_t tem = readWord(rs2) & 0x00000fff;
//								cout<<"rd的值为0x"<<rd<<endl;
//								cout<<"rs2的值为0x"<<rs2<<endl;
//								cout<<"zmm的值为0x"<<zmm<<endl;
//								cout<<"tem的值为0x"<<tem<<endl; 
								writeWord(rd, tem);
								writeWord(rs2, zmm);
								cout << "do CSRRWI and the result is :" << "rd=" << readWord(rd) << endl;
								break;
							}
						}
					case CSRRSI:
						//TODO: Fill code for the instruction here
						break;
					case CSRRCI:
						//TODO: Fill code for the instruction here
						{	
						    uint32_t zmm = imm11j & 0x000001f;
							uint32_t tem = readWord(rs2) & 0x00000fff;
							if (readWord(rd) != 0)
							{
//								cout<<"rd的值为0x"<<rd<<endl;
//								cout<<"rs2的值为0x"<<rs2<<endl;
//								cout<<"zmm的值为0x"<<zmm<<endl;
//								cout<<"tem的值为0x"<<tem<<endl; 
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

		//Update PC
		PC = NextPC;

		cout << "Registers after executing the instruction" << endl;
		showRegs();
		cout << "Continue simulation (Y/n)? [Y]" << endl;
		cin.get(c);	
		getchar();
	}

	freeMem();

	return 0;
}
