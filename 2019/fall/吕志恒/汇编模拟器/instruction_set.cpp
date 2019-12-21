#include "src/instruction_set.h"

#include <vector>

std::unordered_map<std::string, riscv_asm::instruction_set_op> riscv_asm::instruction_set_op_factory() {
    std::unordered_map<std::string, instruction_set_op> result;
    
    std::vector<instruction_set_op> data = {
        {"ecall",  'N', 0x00000073},
        {"ebreak",  'N', 0x00100073},   
        
        {"add",  'R', 0x00000033},
        {"sub",  'R', 0x40000033},
        {"sll",  'R', 0x00001033},
        {"slt",  'R', 0x00002033},
        {"sltu", 'R', 0x00003033},
        {"xor",  'R', 0x00004033},
        {"srl",  'R', 0x00005033},
        {"sra",  'R', 0x40005033},
        {"or",   'R', 0x00006033},
        {"and",  'R', 0x00007033},
        
        {"addi",  'I', 0x00000013},
        {"slti",  'I', 0x00002013},
        {"sltiu", 'I', 0x00003013},
        {"xori",  'I', 0x00004013},
        {"ori",   'I', 0x00006013},
        {"andi",  'I', 0x00007013},
        
        {"sb", 'S', 0x00000023},
        {"sh", 'S', 0x00001023},
        {"sw", 'S', 0x00002023},
        
        {"lb",  'I', 0x00000003},
        {"lh",  'I', 0x00001003},
        {"lw",  'I', 0x00002003},        
        {"lbu", 'I', 0x00004003},
        {"lhu", 'I', 0x00005003},
        
        {"beq",  'B', 0x00000063},
        {"bne",  'B', 0x00001063},
        {"blt",  'B', 0x00004063},
        {"bge",  'B', 0x00005063},
        {"bltu", 'B', 0x00006063},
        {"bgeu", 'B', 0x00007063},
        
        {"jalr", 'I', 0x00000067},
        
        {"jal", 'J', 0x0000006F},
        
        {"lui",   'U', 0x00000037},
        {"auipc", 'U', 0x00000017},
        
        {".word",  'W', 0x00000000}
    };
    
    for (instruction_set_op& instr : data) {
        result[instr.name] = instr;
    }    
    
    return result;
}
