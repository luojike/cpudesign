#include "src/helper.h"

std::vector<std::string> riscv_asm::helper::split(const std::string& input, const std::string& pattern) {
    std::vector<std::string> result;
    
    size_t current = 0;
    size_t old;
    
    do {
        old = current;
        current = input.find_first_of(pattern, old + 1);
        result.push_back(input.substr(old, current - old));
        current = input.find_first_not_of(pattern, current);
    } while (current != std::string::npos);
    
    return result;
}
