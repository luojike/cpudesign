library ieee;
use ieee.std_logic_1164.all;
use work.opcodes.all;

-- Subtype that represents a RISCV word.
subtype word is std_logic_vector(31 downto 0);
-- Subtype that represents register index, ranging from 0 to 2^5 - 1.
subtype reg_idx is std_logic_vector(4 downto 0);

-- Used for opcode decoding.
entity ir_decoder is
    port (
        -- Input.
        ir : in word;
        pc : in word;

        -- Output.
        rs1 : out reg_idx;
        rs2 : out reg_idx;
        rd : out reg_idx;

        alu_op : out alu_op_t;

        -- Whether [imm] is used as output. 
        -- We've chosen to use a vector here because this value
        -- will be input to a multiplexer.
        en_imm : out std_logic_vector(0 downto 0);
        imm : out word;

        ctnl_register : out std_logic_vector(1 downto 0);
        en_write_reg : out boolean;
        en_write_ram : out boolean;
    );
end ir_decoder;

architecture behav of decode is
    -- Values for en_imm
    constant EN_REG : std_logic_vector(0 downto 0) := "0";
    constant EN_IMM : std_logic_vector(0 downto 0) := "0";

    signal opc : opcode;
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
begin

    -- Extract fields.
    opc <= ir(6 downto 0);
    funct3 <= ir(14 downto 12);
    funct7 <= ir(31 downto 25);

    process(ir, funct3, funct7, opc)
    begin
        rs1 <= ir(19 downto 15);
        rs2 <= ir(24 downto 20);
        rd <= ir(11 downto 7);
        alu_op <= ALU_ADD;
        imm <= (others => '0');     -- all '0'
        
        en_imm <= EN_REG;
        en_write_ram <= false;
        en_write_reg <= false;

        case opc is
            when I_AL =>
                -- Enable immediate instead of rs2
                en_imm <= EN_IMM;
                en_write_ram <= false;
    
    end process;
end behav;