# -*- coding: UTF-8 -*-
opcode = {
    "LUI":0x37,
    "AUIPC":0x17,
    "JAL":0x6F,
    "JALR":0x67,
    
    "BEQ":0x63,
    "BNE":0x63|(1<<12),
    "BLT":0x63|(4<<12),
    "BGE":0x63|(5<<12),
    "BLTU":0x63|(6<<12),
    "BGEU":0x63|(7<<12),
        
    #LOAD STORE指令
    "LB":0x03,
    "LH":0x03|(1<<12),
    "LW":0x03|(2<<12),
    "LBU":0x03|(4<<12),
    "LHU":0x03|(5<<12),
    
    "SB":0x23,
    "SH":0x23|(1<<12),
    "SW":0x23|(2<<12),
    
    "ADDI":0x13,
    "SLTI":0x13|(2<<12),
    "SLTIU":0x13|(3<<12),
    "XORI":0x13|(4<<12),
    "ORI":0x13|(6<<12),
    "ANDI":0x13|(7<<12),
    "SLLI":0x13|(1<<12),  
    "SRLI":0x13|(5<<12),
    "SRAI":0x13|(5<<12)|(1<<30),
    
    #整数运算指令
    "ADD":0x33,
    "SUB":0x33|(1<<30),
    "SLL":0x33|(1<<12),
    "SLT":0x33|(2<<12),
    "SLTU":0x33|(3<<12),
    "XOR":0x33|(4<<12),
    "OR":0x33|(6<<12),
    "AND":0x33|(7<<12),
    "SRL":0x33|(5<<12),
    "SRA":0x33|(5<<12)|(1<<30),
    
    "FENCE":0x0F,
    "FENCE_I":0x0F|(1<<12),
    
    "ECALL":0x73,
    "EBREAK":0x73|(1<<20),
    "CSRRW":0x73|(1<<12),
    "CSRRS":0x73|(2<<12),
    "CSRRC":0x73|(3<<12),
    "CSRRWI":0x73|(5<<12),
    "CSRRSI":0x73|(6<<12),
    "CSRRCI":0x73|(7<<12)
}

def R_type(op,rd,rs1,rs2):
    print("{0:032b}".format(op|(rd<<7)|(rs1<<15)|(rs2<<20)))

def I_type(op,rd,rs1,imm):
    print("{0:032b}".format(op|(rd<<7)|(rs1<<15)|(imm<<20)))

def S_type(op,rs1,rs2,imm):
    print("{0:032b}".format(op|(rs1<<15)|(rs2<<20)|((imm&0xfe0)<<20)|((imm&0x1f)<<7)))

def U_type(op,rd,imm):
    print("{0:032b}".format(op|(rd<<7)|(imm<<12)))

def SB_type(op,rs1,rs2,imm):
    print("{0:032b}".format(op|(rs1<<15)|(rs2<<20)|((imm&(1<<11))<<20)|((imm&0x3f0)<<21)|((imm&(1<<10))>>3)|((imm&0xf)<<8)))

def UJA_type(op,rd,imm):
    print("{0:032b}".format(op|(rd<<7)|((imm&(1<<19))<<12)|((imm&0x3ff)<<21)|((imm&(1<<10))<<10)|((imm&0x7f800)<<1)))

def UJAR_type(op,rd,rs1,imm):
    print("{0:032b}".format(op|(rd<<7)|(rs1<<15)|(imm<<20)))

d = []
def getnum(s):
    d = [0 for i in range(3)]
    j=0
    for i in range(len(s)):
        if s[i]>='0' and s[i]<='9':
            d[j]=d[j]*10+int(s[i])
            if i+1<len(s) and (s[i+1]<'0' or s[i+1]>'9'):
                j=j+1
        i=i+1
    return d

def main():
    f=open('input.txt','r')
    list1=["ADD","SUB","XOR","OR","AND","SLL","SRL","SRA","SLT","SLTU"]
    list2=["ADDI","SLTI","SLTIU","XORI","JALR","ORI","ANDI","SLLI","SRLI","SRAI","LB","LH","LW","LBU","LHU"]
    list3=["SB","SH","SW"]
    list4=["LUI","AUIPC"]
    list5=["BEQ","BNE","BLT","BGE","BLTU","BGEU"]
    list6=["JAL"]
    while True:
        line=f.readline()
        if len(line)==0:
            f.close()
            break
        line=line.strip('\n')
        line=line.split()
        op=line[0]
        s=line[1]
        d=getnum(s)
        if op in list1:
            R_type(opcode[op],d[0],d[1],d[2])
        elif op in list2:
            I_type(opcode[op],d[0],d[1],d[2])
        elif op in list3:
            S_type(opcode[op],d[0],d[1],d[2])
        elif op in list4:
            U_type(opcode[op],d[0],d[1])
        elif op in list5:
            SB_type(opcode[op],d[0],d[1],d[2])
        elif op in list6:
            UJA_type(opcode[op],d[0],d[1])

if __name__=="__main__":
    main()
