#include <iostream>
#include<fstream>
#include<bitset>
using namespace std;

//文件读取示例代码
ifstream myfile("D:\\CodeBlock_program\\compiler\\example.txt");
ofstream outfile("D:\\CodeBlock_program\\compiler\\output.txt");

int change(string str)
{
    int num=0;
    while(str[num]!='\0')
    {
        num++;
    }
    num--;
    int result=0;
    int multi=1;
    for(int i=num;i>=0;i--)
    {
        result+=(str[i]-48)*multi;
        multi*=10;
    }
    return result;
}
string get_funt7(string str)
{
    if(str=="ADD"||str=="SLL"||str=="SLT"||str=="SLTU"||
       str=="XOR"||str=="SRL"||str=="OR"||str=="AND"||
       str=="SLLI"||str=="SRLI")
       return "0000000";
    else if(str=="SUB"||str=="SRAI")
        return "0100000";
    else if(str=="SRA")
        return "0100000";
    else
        return "";
}
string get_funt3(string str)
{
    if(str=="JALR"||str=="BEQ"||str=="LB"||str=="SB"||str=="ADDI"||
       str=="ADD"||str=="SUB"||str=="SH"||str=="SLLI"||str=="SLL")
        return "000";
    else if(str=="BNE"||str=="LH")
        return "001";
    else if(str=="LW"||str=="SW"||str=="SLTI"||str=="SLT")
        return "010";
    else if(str=="SLTU"||str=="SLTIU")
        return "011";
    else if(str=="BLT"||str=="LBU"||str=="XORI"||str=="ORI"||
            str=="XOR")
        return "100";
    else if(str=="BGE"||str=="LHU"||str=="SRLI"||str=="SRAI"||
            str=="SRL"||str=="SRA")
        return "101";
    else if(str=="BLTU"||str=="OR")
        return "110";
    else if(str=="BGEU"||str=="ANDI"||str=="AND")
        return "111";
    else
        return "";
}
string get_opcode(string str)
{
    if(str=="LUI")
        return "0110111";
    else if(str=="AUIPC")
        return "0010111";
    else if(str=="JAL")
        return "1101111";
    else if(str=="JALR")
        return "1100111";
    else if(str=="BEQ"||str=="BNE"||str=="BLT"||str=="BGE"||
            str=="BLTU"||str=="BGEU")
        return "1100011";
    else if(str=="LB"||str=="LH"||str=="LW"||str=="LBU"||
            str=="LHU")
        return "0000011";
    else if(str=="SB"||str=="SH"||str=="SW")
        return "0100011";
    else if(str=="ADDI"||str=="SLTI"||str=="SLTU"||str=="XORI"||
            str=="ORI"||str=="ANDI"||str=="SLLI"||str=="SRLI"||
            str=="SRAI"||str=="SLTIU")
        return "0010011";
    else if(str=="ADD"||str=="SUB"||str=="SLL"||str=="SLT"||
            str=="SLTU"||str=="XOR"||str=="SRL"||str=="OR"||
            str=="AND"||str=="SRA")
        return "0110011";

    else
        return "";
}
void decode(string str)
{
    //1首先取指令编号 XXX r1。。。
    int i_str=0;
    char ch;
    string inst_name="";
    string whole_inst="";
    int rs1=0;
    int rs2=0;
    int rd=0;
    int imm=0;
    string funct7="";
    string funct3="";
    string opcode="";
    //辨别指令名称
    while(str[i_str]!=' ')
    {
        ch=str[i_str];
        inst_name+=ch;
        i_str++;
    }
    i_str++;

    cout<<inst_name<<' ';

    funct7=get_funt7(inst_name);
    funct3=get_funt3(inst_name);
    opcode=get_opcode(inst_name);
    cout<<"f7: "<<funct7<<" f3: "<<funct3<<" opcode: "<<opcode<<' ';

    //辨别寄存器和立即数,先是rd，再是rs1，rs2
    //指令的结构：指令名称 xx，xx
    //xx称为要素element，使用一个变量num_ele记录当前要素的个数
    //通过字母和数字出现的地方判断，每当遇到逗号时重新判断。
//    string element;
    int num_ele=1;
    while(str[i_str]!='\0')
    {
        //若该字符为r（寄存器）
        if(str[i_str]=='r')
        {
            //r后面的字符是寄存器的编号
            i_str++;
            string reg_id="";

            while(str[i_str]!=','&&str[i_str]!='\0')
            {
                reg_id+=str[i_str];
                i_str++;
            }
            int reg_num=change(reg_id);
            cout<<bitset<5>(reg_num)<<' ';

            //判断寄存器出现的个数，得到指令中寄存器的五位二进制码
            if(num_ele==1) //第一个寄存器是目的寄存器rd
                rd=reg_num;
            if(num_ele==2)//第二个寄存器是源寄存器rs1
                rs1=reg_num;
            if(num_ele==3)//第三个寄存器是源寄存器rs2
                rs2=reg_num;
            //i_str++;    //跳过“,”
        }

        else if(str[i_str]>='0' && str[i_str]<='9')
        {
            //访问该立即数的每一位
            string temp="";
            while(str[i_str]!=',' && str[i_str]!='\0')
            {
                temp+=str[i_str++];
            }
            //转换成十进制
            imm=change(temp);
            if(inst_name=="ADDI"||inst_name=="SLTI"||inst_name=="SLTIU"||
            inst_name=="XORI"||inst_name=="ORI"||inst_name=="ANDI"||
            inst_name=="LB"||inst_name=="LH"||inst_name=="LW"||
            inst_name=="LBU"||inst_name=="LHU")
                cout<<"imm="<<bitset<12>(imm)<<' ';
            else if(inst_name=="SB"||inst_name=="SH"||inst_name=="SW")
            {
                int temp_front=imm>>5;
                cout<<"imm_front: "<<bitset<7>(temp_front)<<' ';
                cout<<"imm_back: "<<bitset<5>(imm)<<' ';
            }
            else if(inst_name=="BEQ"||inst_name=="BNE"||inst_name=="BLT"||
            inst_name=="BGE"||inst_name=="BLTU"||inst_name=="BGEU")
            {
                cout<<"imm(12): "<<bitset<1>(imm>>11)<<' ';
                cout<<"imm(10:5): "<<bitset<6>(imm>>5)<<' ';
                cout<<"imm(4:1): "<<bitset<4>(imm>>1)<<' ';
                cout<<"imm(11): "<<bitset<1>(imm>>11)<<' ';
            }
            else if(inst_name=="LUI"||inst_name=="AUIPC")
            {
                cout<<"imm(31:12): "<<bitset<20>(imm>>20)<<' ';
            }
            else if(inst_name=="JAL")
            {
                cout<<"imm(20): "<<bitset<1>(imm>>20)<<' ';
                cout<<"imm(10:1): "<<bitset<10>(imm>>1)<<' ';
                cout<<"imm(11): "<<bitset<1>(imm>>11)<<' ';
                cout<<"imm(19:12): "<<bitset<8>(imm>>12)<<' ';
            }
            else if(inst_name=="JALR")
            {
                cout<<"imm(11:0): "<<bitset<12>(imm)<<' ';
            }
        }
        if(str[i_str]=='\0')
            break;
        i_str++;
        num_ele++;
    }
    cout<<"rd: "<<rd<<" rs1: "<<rs1<<" rs2: "<<rs2<<endl;
    //return inst_name;
    //2处理寄存器等
    if(inst_name=="ADD"||inst_name=="SUB"||inst_name=="SLL"||
       inst_name=="SLT"||inst_name=="SLTU"||inst_name=="XOR"||
       inst_name=="SRL"||inst_name=="SRA"||inst_name=="OR"||
       inst_name=="AND")
    {
        outfile<<funct7<<bitset<5>(rs2)<<bitset<5>(rs1)<<funct3<<bitset<5>(rd)<<opcode<<endl;
    }
    else if(inst_name=="ADDI"||inst_name=="SLTI"||inst_name=="SLTIU"||
            inst_name=="XORI"||inst_name=="ORI"||inst_name=="ANDI"||
            inst_name=="LB"||inst_name=="LH"||inst_name=="LW"||
            inst_name=="LBU"||inst_name=="LHU")
    {
        outfile<<bitset<12>(imm)<<bitset<5>(rs1)<<funct3<<bitset<5>(rd)<<opcode<<endl;
    }
    else if(inst_name=="SB"||inst_name=="SH"||inst_name=="SW")
    {
        outfile<<bitset<7>(imm>>5)<<bitset<5>(rs2)<<bitset<5>(rs1)<<funct3<<bitset<5>(imm)<<opcode<<endl;
    }
    else if(inst_name=="BEQ"||inst_name=="BNE"||inst_name=="BLT"||
            inst_name=="BGE"||inst_name=="BLTU"||inst_name=="BGEU")
    {
        outfile<<bitset<1>(imm>>11)<<bitset<6>(imm>>5)<<bitset<5>(rs2)<<bitset<5>(rs1)<<funct3<<bitset<4>(imm>>1)<<bitset<1>(imm>>11)<<opcode<<endl;
    }
    else if(inst_name=="LUI"||inst_name=="AUIPC")
    {
        outfile<<bitset<20>(imm>>20)<<bitset<5>(rd)<<opcode<<endl;
    }
    else if(inst_name=="JAL")
    {
        outfile<<bitset<1>(imm>>20)<<bitset<10>(imm>>1)<<bitset<1>(imm>>11)<<bitset<8>(imm>>12)<<bitset<5>(rd)<<opcode<<endl;
    }
    else if(inst_name=="JALR")
    {
        outfile<<bitset<12>(imm)<<bitset<5>(rs1)<<funct3<<bitset<5>(rd)<<opcode<<endl;
    }
}

int main()
{


    string curr_inst;
    if(!myfile.is_open())
    {
        outfile<<"未成功打开文件"<<endl;
    }
    //解析代码
    while(getline(myfile,curr_inst))//获得一行指令
    {
        //解释其作用
        //查看说明书得到一条示例代码
        //需要明确：
        //1什么指令
        //2寄存器如何表达
        //3
        //cout<<decode(curr_inst)<<endl;
        //outfile<<decode(curr_inst)<<endl;
        decode(curr_inst);
    }

    myfile.close();
    outfile.close();
    return 0;
}
