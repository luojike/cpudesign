#pragma once

#include <vector>
#include <string>

namespace riscv_asm {
    namespace helper {
        std::vector<std::string> split(const std::string& input, const std::string& pattern);
    }
}
