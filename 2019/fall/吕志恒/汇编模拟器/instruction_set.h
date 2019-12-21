#pragma once

#include <string>
#include "stdint.h"
#include <unordered_map>

namespace riscv_asm {
struct instruction_set_op {
    std::string name;
    char type;
    uint32_t opcode;
};

std::unordered_map<std::string, instruction_set_op> instruction_set_op_factory();

}
