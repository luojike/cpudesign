/*
    designed by 蒋林钰 at 2019.07.04
    输入的所有测试指令在in.txt文件里
    请一同下载运行
*/
#include <bits/stdc++.h>
using namespace std;
map<string,int> opcode;
int d[3]={0};
void presolve(){
    //LOAD STORE指令
    opcode["lb"] = 0x03;
    opcode["lh"] = 0x03 | (1<<12);
    opcode["lw"] = 0x03 | (1<<13);
    opcode["lbu"] = 0x03 | (1<<14);
    opcode["lhu"] = 0x03 | (5<<12);

    opcode["sb"] = 0x23;
    opcode["sh"] = 0x23 | (1<<12);
    opcode["sw"] = 0x23 | (1<<13);

    //整数运算指令
    opcode["add"] = 0x33;
    opcode["sub"] = 0x33 | (1<<30);
    opcode["xor"] = 0x33 | (1<<14);
    opcode["or"] = 0x33 | (3<<13);
    opcode["and"] = 0x33 | (8<<12);
    opcode["SLL"] = 0x33 | (1<<12);
    opcode["SRL"] = 0x33 | (5<<12);
    opcode["SRA"] = 0x33 | (5<<12) | (1<<30);
    opcode["slt"] = 0x33 | (1<<13);
    opcode["sltu"] = 0x33 | (3<<12);


    opcode["addi"] = 0x13;
    opcode["lui"] = 0x37;
    opcode["auipc"] = 0x17;
    opcode["xori"] = 0x13 | (1<<14);
    opcode["ori"] = 0x13 | (3<<13);
    opcode["andi"] = 0x13 | (8<<12);
    opcode["SLLI"] = 0x13 | (1<<12);
    opcode["SRLI"] = 0x13 | (5<<12);
    opcode["SRAI"] = 0x13 | (5<<12) | (1<<30);
    opcode["slti"] = 0x13 | (1<<13);
    opcode["sltiu"] = 0x13 | (3<<12);

    //控制指令
    opcode["beq"] = 0x63;
    opcode["bne"] = 0x63 | (1<<12);
    opcode["blt"] = 0x63 | (1<<14);
    opcode["bge"] = 0x63 | (5<<12);
    opcode["bltu"] = 0x63 | (6<<12);
    opcode["bgeu"] = 0x63 | (7<<12);
    opcode["JAL"] = 0x6F;
    opcode["JALR"] = 0x67;

}

void getnum(string s){
    memset(d,0,sizeof(d));
    int j=0;
    for(int i=0;i<s.length();i++){
        if(s[i]>='0'&&s[i]<='9'){
            d[j] = d[j]*10+int(s[i]-'0');
            if(i+1<s.length()&&(s[i+1]<'0' || s[i+1]>'9')) j++;
        }
    }
}
void solveR(int op, int rd, int rs1, int rs2){ // 整数 ADD/SLT/SLTU/AND/OR/XOR/SLL/SRL/SUB/SRA
    cout<< bitset<32>(op |(rd<<7)|(rs2<<20)|(rs1<<15)) <<endl;
}

void solveI(int op, int rd, int rs1, int imm){ //Load 整数计算 ADDI/SLTI(U)/ANDI/ORI/XORI/SLLI/SRLI/SRAI JALR
    cout<< bitset<32>(op |(rd<<7)|(rs1<<15)|(imm<<20)) <<endl;
}

void solveS(int op, int rs1,int rs2, int imm){ //Store
//    cout<< bitset<32>((imm & 0xfe0)<<20) << endl << bitset<32>((imm & 0x1f)<<7) <<endl;
    cout<< bitset<32>(op |(rs2<<20)|(rs1<<15)| ((imm & 0xfe0)<<20) | ((imm & 0x1f)<<7)) <<endl;
}

void solveU(int op, int rd, int imm){
    cout<< bitset<32>(op | (rd<<7) | (imm<<12))<<endl;
}

void solveSB(int op, int rs1, int rs2, int imm){
//    cout<<bitset<32>(imm)<<endl;
//    cout<< bitset<32>(((imm & 0x3f0)<<21)) << endl << bitset<32>(((imm & 0xf)<<8)) <<endl;
    cout<< bitset<32>(op | (rs2<<20) | (rs1<<15) | ((imm & (1<<11))<<20) | ((imm & 0x3f0)<<21) | ((imm & (1<<10))>>3) | ((imm & 0xf)<<8)) <<endl;
}

void solveUJA(int op,int rd, int imm){
//    cout<< bitset<32> ((imm & 0x3ff)<<21) <<endl;
    cout<< bitset<32>(op | (rd<<7) | ((imm & (1<<19))<<12) | ((imm & 0x3ff)<<21) | ((imm &(1<<10))<<10) | ((imm & 0x7f800)<<1)) <<endl;
}

void solveUJAR(int op,int rd,int rs1,int imm){
    cout<< bitset<32>(op | (rd<<7) | (rs1<<15) | (imm<<20))<<endl;
}
int main(){
    freopen("in.txt","r",stdin);
    presolve();
    string op,s;

    while(cin>>op>>s){
        if(op == "add" | op == "sub" | op == "xor" | op == "or" | op == "and" |
           op == "SLL" | op == "SRL" | op == "SRA" | op == "slt" | op == "sltu"){
                getnum(s);
//                printf("%d %d %d\n",d[0],d[1],d[2]);
                solveR(opcode[op],d[0],d[1],d[2]);
        }
        else if(op == "addi" | op == "slti" | op == "sltiu" | op == "xori" | op == "JALR" |
                op == "ori" | op == "andi" | op == "SLLI" | op == "SRLI" | op == "SRAI" | op == "lb" | op == "lh" | op == "lw" | op == "lbu" | op == "lhu"){
                getnum(s);
//                printf("%d %d %d\n",d[0],d[1],d[2]);
                solveI(opcode[op], d[0],d[1],d[2]);
        }
        else if(op == "sb" | op == "sh" | op == "sw"){
            getnum(s);
//            printf("%d %d %d\n",d[0],d[1],d[2]);
            solveS(opcode[op],d[0],d[1],d[2]);
        }
        else if(op == "lui" | op == "auipc"){
            getnum(s);
//            printf("%d %d %d\n",d[0],d[1],d[2]);
            solveU(opcode[op],d[0],d[1]);
        }
        else if(op == "beq" | op == "bne" | op == "blt" | op == "bge" | op == "bltu" | op == "bgeu"){
            getnum(s);
            solveSB(opcode[op],d[0],d[1],d[2]);
        }
        else if(op == "JAL"){
            getnum(s);
            solveUJA(opcode[op],d[0],d[1]);
        }
    }


    return 0;
}
