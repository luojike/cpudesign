-- opcodes.vhdl:
-- Defines opcodes used in RV32I base instruction set.

library ieee;
use ieee.std_logic_1164.all;

package opcodes is

    -- Chapter 25, riscv-specs.pdf.
    -- Opcode length in bits.
    constant opcode_len : natural := 7;
    subtype opcode is std_logic_vector(opcode_len - 1 downto 0);

    -- Opcodes.
    constant U_LUI : opcode := "0110111";
    constant U_AUIPC : opcode := "0010111";
    constant J_JAL : opcode := "1101111";   -- Jump and link
    constant I_JALR : opcode := "1100111";  -- Jump and link register
    constant B_BR : opcode := "1100011";
    constant I_LOAD : opcode := "0000011";  -- LB, LH, LW, LBU, LHU
    constant S_STORE : opcode := "0100011"; -- SB, SH, SW
    constant I_AL : opcode := "0010011";    -- Register/Immediate and shifts: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
    constant R_R : opcode := "0110011";     -- Register/Register: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND

    -- alu_op_t type is determined by opcodes, funct3 and funct7.
    -- The purpose of this enumeration is to ignore the differences
    -- between R-type and I-type encodings, e.g., the ALU treats ADD 
    -- and ADDI as the same operation(namely ALU_ADD) regardless of 
    -- where the two operands come from.
    type alu_op_t is (
        ALU_ADD,
        ALU_SUB,
        ALU_SLL,    -- Shift left logical
        ALU_SRL,    -- Shift right logical
        ALU_SRA,    -- Shift right arithmetic
        ALU_SLT,    -- Set less than
        ALU_SLTU,   -- Set less than unsigned
        ALU_XOR,
        ALU_OR,
        ALU_AND
    );

    -- Flags for updating PC register.
    -- NORMAL: simply point the PC to next instruction.
    -- RELATIVE: PC-relative jumps.
    -- ABSOLUTE: used by JALR.
    constant NORMAL : std_logic_vector(1 downto 0) := "00";
    constant RELATIVE : std_logic_vector(1 downto 0) := "01";
    constant ABSOLUTE : std_logic_vector(1 downto 0) := "10";

end opcodes;
