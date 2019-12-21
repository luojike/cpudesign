#include "src/assembler.h"

#include <iostream>

riscv_asm::assembler::assembler() {
    m_instructionSet = instruction_set_op_factory();
}

uint32_t riscv_asm::assembler::assemble_single_instruction(const std::string& instr) {
    auto parsedInstr = helper::split(instr, " ,");
    if (!parsedInstr.empty()) {
        auto op = m_instructionSet.find(parsedInstr[0]);
        if (op == m_instructionSet.end()) {
            return 0;
        }

        switch (op->second.type) {
        case 'N':
            return build_N_Type(parsedInstr);
        case 'R':
            return build_R_Type(parsedInstr);
        case 'I':
            return build_I_Type(parsedInstr);
        case 'S':
            return build_S_Type(parsedInstr);
        case 'B':
            return build_B_Type(parsedInstr);
        case 'U':
            return build_U_Type(parsedInstr);
        case 'J':
            return build_J_Type(parsedInstr);
        case 'W':
            return build_W_Type(parsedInstr);
        default:
            return 0;
        }
    }
}

std::vector<uint32_t> riscv_asm::assembler::assemble(const std::string& input) {
    std::vector<uint32_t> result;
    auto lines = helper::split(input, ";\n");
    m_currentAddress = 0;

    for (auto& line : lines) {
        auto symbol = line.find(":");
        if (symbol != std::string::npos) {
            m_symbolTable[line.substr(0, symbol)] = m_currentAddress;

            if (line.find_first_not_of(" ;\n\t") != std::string::npos) {
                result.push_back(assemble_single_instruction(line.substr(symbol + 1)));
                m_currentAddress += 4;
            }
        } else {
            result.push_back(assemble_single_instruction(line));
            m_currentAddress += 4;
        }

    }

    return result;
}

uint32_t riscv_asm::assembler::parse_register(const std::string& reg) {
    //only x-style
    if (reg.length() < 2) {
        return 0;
    }

    return reg[1] - 48;
}

uint32_t riscv_asm::assembler::parse_immediate(const std::string& imm) {
    auto symbol = m_symbolTable.find(imm);
    if (symbol != m_symbolTable.end()) {
        return symbol->second - m_currentAddress;
    } else {
        return std::stoul(imm, 0, 0);
    }
}

uint32_t riscv_asm::assembler::build_R_Type(std::vector<std::string>& input) {
    if (input.size() < 4) {
        return 0;
    }

    return
        parse_register(input[1]) << 7 |
        parse_register(input[2]) << 15 |
        parse_register(input[3]) << 20 |
        m_instructionSet[input[0]].opcode;
}

uint32_t riscv_asm::assembler::build_I_Type(std::vector<std::string>& input) {
    if (input.size() < 4) {
        return 0;
    }

    return
        parse_register(input[1]) << 7 |
        parse_register(input[2]) << 15 |
        parse_immediate(input[3]) << 20 |
        m_instructionSet[input[0]].opcode;
}

uint32_t riscv_asm::assembler::build_S_Type(std::vector<std::string>& input) {
    if (input.size() < 4) {
        return 0;
    }

    uint32_t imm = parse_immediate(input[3]);

    return
        (imm & 0x1F) << 7 |
        parse_register(input[1]) << 15 |
        parse_register(input[2]) << 20 |
        ((imm & 0xFE0) >> 5) << 25 |
        m_instructionSet[input[0]].opcode;
}

uint32_t riscv_asm::assembler::build_B_Type(std::vector<std::string>& input) {
    if (input.size() < 4) {
        return 0;
    }

    uint32_t imm = parse_immediate(input[3]);

    return
        ((imm & 0x1E) | ((imm >> 11) & 1)) << 7 |
        parse_register(input[1]) << 15 |
        parse_register(input[2]) << 20 |
        ((((imm & 0x1000) >> 1) | (imm & 0x7E0)) >> 5) << 25 |
        m_instructionSet[input[0]].opcode;
}

uint32_t riscv_asm::assembler::build_U_Type(std::vector<std::string>& input) {
    if (input.size() < 3) {
        return 0;
    }

    return
        parse_register(input[1]) << 7 |
        parse_immediate(input[2]) << 12 |
        m_instructionSet[input[0]].opcode;
}

uint32_t riscv_asm::assembler::build_J_Type(std::vector<std::string>& input) {
    if (input.size() < 3) {
        return 0;
    }
    uint32_t imm = parse_immediate(input[2]);

    return
        parse_register(input[1]) << 7 |
        (
            (imm & 0x7FE) << 8 |

            (imm & 0x800) >> 3 |

            (imm & 0xFF000) >> 12 |

            (imm & 0x100000) >> 1
        ) << 12 |

        m_instructionSet[input[0]].opcode;
}

uint32_t riscv_asm::assembler::build_N_Type(std::vector<std::string>& input) {
    return m_instructionSet[input[0]].opcode;
}

uint32_t riscv_asm::assembler::build_W_Type(std::vector<std::string>& input) {
    if (input.size() < 2) {
        return 0;
    }

    return parse_immediate(input[1]);
}

