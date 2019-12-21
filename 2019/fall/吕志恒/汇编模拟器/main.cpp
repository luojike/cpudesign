
#include <iostream>
#include "src/assembler.h"

int main(int argc, char **argv) {
    std::string input = 
        "add x1, x0, x0;"
        "addi x2, x0, 10;"
        "loop:"
        "addi x1, x1, 1;"
        "blt x1, x2, loop;"
        "lui x6, 0x20;"
        "addi x1, x0, 0xFF;"
        "sw x1, x6, -4;"
        "lw x3, x6, -4;"
        "lh x4, x6, -4;"
        "lb x5, x6, -4;"
        
        "end:"
        "jal x0, end;"
    ;
    
    riscv_asm::assembler asmConverter;
    
    auto code = asmConverter.assemble(input);
    
    for (uint32_t c : code) {
        std::cout << std::hex << c << std::endl;
    }

    return 0;
}
