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
    constant J_JAL : opcode := "1101111";
    constant I_JALR : opcode := "1100111";
    constant B_BR : opcode := "1100011";
    constant I_LOAD : opcode := "0000011";  -- LB, LH, LW, LBU, LHU
    constant S_STORE : opcode := "0100011"; -- SB, SH, SW
    constant I_AL : opcode := "0010011";    -- Arithmetic or logical: ADDI, SLTI, SLTIU, XORI, ORI, ANDI
    constant R_I : opcode := "0010011";     -- SLLI, SRLI, SRAI
    constant R_R : opcode := "0110011";     -- ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND

end opcodes;
