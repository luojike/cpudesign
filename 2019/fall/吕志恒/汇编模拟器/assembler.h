#pragma once

#include <unordered_map>
#include <vector>
#include "stdint.h"
#include "src/instruction_set.h"
#include "src/helper.h"

namespace riscv_asm {
class assembler {
public:
    assembler();
    assembler(const assembler& copy) = delete;
    assembler(assembler&& move) = delete;

public:
    uint32_t assemble_single_instruction(const std::string& instr);
    std::vector<uint32_t> assemble(const std::string& input);
private:
    uint32_t parse_register(const std::string& reg);
    uint32_t parse_immediate(const std::string& imm);
    uint32_t build_R_Type(std::vector<std::string>& input);
    uint32_t build_I_Type(std::vector<std::string>& input);
    uint32_t build_S_Type(std::vector<std::string>& input);
    uint32_t build_B_Type(std::vector<std::string>& input);
    uint32_t build_U_Type(std::vector<std::string>& input);
    uint32_t build_J_Type(std::vector<std::string>& input);
    
    //N and W are not official types
    //N: no arguments
    //W: words
    uint32_t build_N_Type(std::vector<std::string>& input);
    uint32_t build_W_Type(std::vector<std::string>& input);

    uint32_t m_currentAddress;
    std::unordered_map<std::string, uint32_t> m_symbolTable;
    std::unordered_map<std::string, instruction_set_op> m_instructionSet;
};
}
