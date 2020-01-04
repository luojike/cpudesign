
# -*- coding: UTF-8 -*-
from head import*

def R_type(op,rd,rs1,rs2):
    return "{0:032b}".format(op|(rd<<7)|(rs1<<15)|(rs2<<20))

def I_type(op,rd,rs1,imm):
    return "{0:032b}".format(op|(rd<<7)|(rs1<<15)|(imm<<20))

def S_type(op,rs1,rs2,imm):
    return "{0:032b}".format(op|(rs1<<15)|(rs2<<20)|((imm&0xfe0)<<20)|((imm&0x1f)<<7))

def U_type(op,rd,imm):
    return "{0:032b}".format(op|(rd<<7)|(imm<<12))

def SB_type(op,rs1,rs2,imm):
    return "{0:032b}".format(op|(rs1<<15)|(rs2<<20)|((imm&(1<<11))<<20)|((imm&0x3f0)<<21)|((imm&(1<<10))>>3)|((imm&0xf)<<8))

def UJA_type(op,rd,imm):
    return "{0:032b}".format(op|(rd<<7)|((imm&(1<<19))<<12)|((imm&0x3ff)<<21)|((imm&(1<<10))<<10)|((imm&0x7f800)<<1))

def UJAR_type(op,rd,rs1,imm):
    return "{0:032b}".format(op|(rd<<7)|(rs1<<15)|(imm<<20))

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
        with open("output.txt","a") as t:
            if op in list1:
                t.write(R_type(opcode[op],d[0],d[1],d[2])+'\n')
            elif op in list2:
                t.write(I_type(opcode[op],d[0],d[1],d[2])+'\n')
            elif op in list3:
                t.write(S_type(opcode[op],d[0],d[1],d[2])+'\n')
            elif op in list4:
                t.write(U_type(opcode[op],d[0],d[1])+'\n')
            elif op in list5:
                t.write(SB_type(opcode[op],d[0],d[1],d[2])+'\n')
            elif op in list6:
                t.write(UJA_type(opcode[op],d[0],d[1])+'\n')

if __name__=="__main__":
    main()
