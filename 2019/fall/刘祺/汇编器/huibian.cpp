
  #include<iostream>
	#include<cstring>
	#include<map>
	#include<bitset>
	#include<fstream>
	using namespace std;
	map<string,int> opcode;
	int d[3]={0};
	void presolve(){
	opcode["LB"] = 0x03;
	opcode["LH"] = 0x03 | (1<<12);
	opcode["LW"] = 0x03 | (1<<13);
	opcode["LBU"] = 0x03 | (1<<14);
	opcode["LHU"] = 0x03 | (5<<12);
	opcode["SB"] = 0x23;
	opcode["SH"] = 0x23 | (1<<12);
	opcode["SW"] = 0x23 | (1<<13);
	opcode["ADD"] = 0x33;
	opcode["SUB"] = 0x33 | (1<<30);
	opcode["XOR"] = 0x33 | (1<<14);
	opcode["OR"] = 0x33 | (3<<13);
	opcode["AND"] = 0x33 | (8<<12);
	opcode["SLL"] = 0x33 | (1<<12);
	opcode["SRL"] = 0x33 | (5<<12);
	opcode["SRA"] = 0x33 | (5<<12) | (1<<30);
	opcode["SLT"] = 0x33 | (1<<13);
	opcode["SLTU"] = 0x33 | (3<<12);
	opcode["ADDI"] = 0x13;
	opcode["LUI"] = 0x37;
	opcode["AUIPC"] = 0x17;
	opcode["XORI"] = 0x13 | (1<<14);
	opcode["ORI"] = 0x13 | (3<<13);
	opcode["ANDI"] = 0x13 | (8<<12);
	opcode["SLLI"] = 0x13 | (1<<12);
	opcode["SRLI"] = 0x13 | (5<<12);
	opcode["SRAI"] = 0x13 | (5<<12) | (1<<30);
	opcode["SLTI"] = 0x13 | (1<<13);
	opcode["SLTIU"] = 0x13 | (3<<12);
	opcode["BEQ"] = 0x63;
	opcode["BNE"] = 0x63 | (1<<12);
	opcode["BLT"] = 0x63 | (1<<14);
	opcode["BGE"] = 0x63 | (5<<12);
	opcode["BLTU"] = 0x63 | (6<<12);
	opcode["BGEU"] = 0x63 | (7<<12);
	opcode["JAL"] = 0x6F;
	opcode["JALR"] = 0x67;
	
	}
	
	void getnum(string s){
	memset(d,0,sizeof(d))
	int j=0;
	for(int i=0;i<s.length();i++){
	if(s[i]>='0'&&s[i]<='9'){
	d[j] = d[j]*10+int(s[i]-'0');
	if(i+1<s.length()&&(s[i+1]<'0' || s[i+1]>'9')) j++;
	}
	}
	}
	void solveR(int op, int rd, int rs1, int rs2){ // 整数 ADD/SLT/SLTU/AND/OR/XOR/SLL/SRL/SUB/SRA
	}
	void solveI(int op, int rd, int rs1, int imm){ //Load,I-type,整数计算 ADDI/SLTI(U)/ANDI/ORI/XORI/SLLI/SRLI/SRAI JALR
	cout<< bitset<32>(op |(rd<<7)|(rs1<<15)|(imm<<20)) <<endl;
	}	
	void solveS(int op, int rs1,int rs2, int imm){ //S-type	
	cout<< bitset<32>(op |(rs2<<20)|(rs1<<15)| ((imm & 0xfe0)<<20) | ((imm & 0x1f)<<7)) <<endl;
	}
	void solveU(int op, int rd, int imm){ //U-type 
	cout<< bitset<32>(op | (rd<<7) | (imm<<12))<<endl;
	}	
	void solveSB(int op, int rs1, int rs2, int imm){ //S-stype和B-stype 
	cout<< bitset<32>(op | (rs2<<20) | (rs1<<15) | ((imm & (1<<11))<<20) | ((imm & 0x3f0)<<21) | ((imm & (1<<10))>>3) | ((imm & 0xf)<<8)) <<endl;
	}
	void solveUJA(int op,int rd, int imm){
	cout<< bitset<32>(op | (rd<<7) | ((imm & (1<<19))<<12) | ((imm & 0x3ff)<<21) | ((imm &(1<<10))<<10) | ((imm & 0x7f800)<<1)) <<endl;
	}
	void solveUJAR(int op,int rd,int rs1,int imm){
	cout<< bitset<32>(op | (rd<<7) | (rs1<<15) | (imm<<20))<<endl;
	}
	int main(){
	//读入输入文件 
	freopen("in.txt","r",stdin);
	
	presolve();
	string op,s;
	//将结果输入输出文件 
	//freopen("out.txt","w",stdout);
	ofstream outFile("out.dat",ios::out | ios::binary);
	while(cin>>op>>s){
	//进行译码过程(下同) 
	if(op == "ADD" | op == "SUB" | op == "XOR" | op == "OR" | op == "AND" |
	op == "SLL" | op == "SRL" | op == "SRA" | op == "SLT" | op == "SLTU"){
	getnum(s);
	//输出译码结果(下同) 
	//solveR(opcode[op],d[0],d[1],d[2]);
	outFile.write((char*)&solveR(opcode[op],d[0],d[1],d[2]),sizeof(solveR(opcode[op],d[0],d[1],d[2])));
	}
	else if(op == "ADDI" | op == "SLTI" | op == "SLTIU" | op == "XORI" | op == "JALR" |
	op == "ORI" | op == "ANDI" | op == "SLLI" | op == "SRLI" | op == "SRAI" | op == "LB" | op == "LH" | op == "LW" | op == "LBU" | op == "LHU"){
	getnum(s);
	solveI(opcode[op], d[0],d[1],d[2]);
	}
	else if(op == "SB" | op == "SH" | op == "SW"){
	getnum(s);
	solveS(opcode[op],d[0],d[1],d[2]);
	}
	else if(op == "LUI" | op == "AUIPC"){
	getnum(s);
	solveU(opcode[op],d[0],d[1]);
	}
	else if(op == "BEQ" | op == "BNE" | op == "BLT" | op == "BGE" | op == "BLTU" | op == "BGEU"){
	getnum(s);
	solveSB(opcode[op],d[0],d[1],d[2]);
	}
	else if(op == "JAL"){
	getnum(s);
	solveUJA(opcode[op],d[0],d[1]);
	}
	}
	fclose(stdin);
	outFile.close();
	//fclose(stdout);
	return 0;
	}
	
