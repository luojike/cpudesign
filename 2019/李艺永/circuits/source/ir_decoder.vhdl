library ieee;
use ieee.std_logic_1164.all;
use work.opcodes.all;
use work.pc.all;

-- Entity ir_decoder:
-- Determin alu_op_t from funct7, funct3 and opcodes.
entity ir_decoder is
    port (
        -- Input.
        ir : in std_logic_vector(31 downto 0);
        pc : in std_logic_vector(31 downto 0);

        br_flag : in boolean;   -- A flag emitted by ALU. Used for conditional branch.

        -- Output.

        op_t : out std_logic_vector(1 downto 0);    -- Operation type. See constant OP_XXX in archiecture body.
        alu_op : out alu_op_t;                      -- Used only when [op_t] is OP_ALU;
        pc_off : out std_logic_vector(31 downto 0); -- Used only when [op_t] is OP_PC;
        br_mode : out std_logic_vector(1 downto 0); -- Used only when [op_t] is OP_PC;

        rs1 : out std_logic_vector(4 downto 0);
        rs2 : out std_logic_vector(4 downto 0);
        en_write_reg : out boolean;     -- Indicates whether to write to rd resgiter.
        rd : out std_logic_vector(4 downto 0);

        -- Whether [imm] is used as output. 
        -- We've chosen to use a vector here because this value
        -- will be input to a multiplexer.
        en_imm : out std_logic_vector(0 downto 0);
        imm : out std_logic_vector(31 downto 0);

        en_write_ram : out boolean;
    );
end ir_decoder;

architecture behav of ir_decoder is
    -- Types of the operations.
    constant OP_ALU : std_logic_vector(1 downto 0) := "00";
    constant OP_RAM : std_logic_vector(1 downto 0) := "01";
    constant OP_PC : std_logic_vector(1 downto 0) := "10";

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
        -- Some "default" values.
        op_t <= OP_ALU;
        rs1 <= ir(19 downto 15);
        rs2 <= ir(24 downto 20);
        rd <= ir(11 downto 7);
        alu_op <= ALU_ADD;
        imm <= (others => '0');     -- all '0'
        
        en_imm <= EN_REG;
        en_write_ram <= false;
        en_write_reg <= false;

        br_mode <= NORMAL;

        case opc is
            -- "0010011": I-type encoding. Arithmetic and Logical operations.
            when I_AL =>
                en_imm <= EN_IMM;
                -- Set alu_op.
                case funct3 is
                    when "000" =>
                        alu_op <= ALU_ADD;
                    when "001" =>
                        alu_op <= ALU_SLL;
                    when "010" =>
                        alu_op <= ALU_SLT;
                    when "011" =>
                        alu_op <= ALU_SLTU;
                    when "100" =>
                        alu_op <= ALU_XOR;
                    when "101" =>
                        -- Check the upper bits of imm
                        case funct7 is
                            when "0000000" =>
                                alu_op <= ALU_SRL;
                            when others =>
                                alu_op <= ALU_SRA;
                    when "110" =>
                        alu_op <= ALU_OR;
                    when "111" =>
                        alu_op <= ALU_ADD;
                end case;

                -- Set immdiate.
                -- To save some code, we do it again.
                case funct3 is
                    -- When alu_op is a shift operation.
                    when "001" | "101" =>
                        -- Sign-extended.
                        imm(31 downto 12) <= (others => ir(31));
                        -- This range should be "0000000" or "0100000"
                        imm(11 downto 5) <= ir(31 downto 25);
                        -- The actual shift amount.
                        imm(4 downto 0) <= ir(24 downto 20);
                    when others =>
                        -- Sign-extended.
                        imm(31 downto 12) <= (others => ir(31));
                        -- The actual shift amount.
                        imm(4 downto 0) <= ir(24 downto 20);
                end case;

            -- "0110011": R-type encoding. Arithmetic and Logical operations.
            when R_R =>
                case funct3 is
                    when "000" =>
                        case funct7 is
                            when "0000000" =>
                                alu_op <= ALU_ADD;
                            when others =>
                                alu_op <= ALU_SUB;
                        end case;

                    when "001" =>
                        alu_op <= ALU_SLL;  -- Shift Left Logical.
                    
                    when "010" =>
                        alu_op <= ALU_SLT;  -- Set Less Than.
                    
                    when "011" =>
                        alu_op <= ALU_SLTU; -- Set Less Than Unsigned.

                    when "100" =>
                        alu_op <= ALU_XOR;

                    when "101" =>
                        case funct7 is
                            when "0000000" =>
                                alu_op <= ALU_SRL;
                            when others =>
                                alu_op <= ALU_SRA;
                        end case;

                    when "110" =>
                        alu_op <= ALU_OR;
                    when "111" =>
                        alu_op <= ALU_AND;

                end case;
            -- "0000011": I-type encoding. Load from memory.
            when I_LOAD =>
                op_t <= OP_RAM;
                en_imm <= EN_IMM;

                -- Sign-extended.
                imm(31 downto 12) <= (others => ir(31));
                -- Actual immediate.
                imm(11 downto 0) <= ir(31 downto 20);

            -- "0100011": S-type encoding. Store to memory.
            when S_STORE =>
                op_t <= OP_RAM;
                en_imm <= EN_IMM;
                en_write_ram <= true;
                en_write_reg <= false;

                -- Sign-extended.
                imm(31 downto 12) <= (others => ir(31));
                -- High bits.
                imm(11 downto 5) <= ir(31 downto 25);
                -- Low bits.
                imm(4 downto 0) <= ir(7 downto 7);

            -- "1100011": B-type encoding. Conditional Branch.
            when B_BR =>
                op_t <= OP_PC;

                -- Sign-extended.
                pc_off(31 downto 12) <= (others => ir(31));
                pc_off(11) <= ir(7);
                pc_off(10 downto 5) <= ir(30 downto 25);
                pc_off(4 downto 1) <= ir(12 downto 8);
                pc_off(0) <= '0';

                case funct3 is
                    when "000" =>   -- BEQ
                        -- We'll have to rely on the result on ALU_AND.
                        alu_op <= ALU_AND;

                        case br_flag is
                            when true =>
                                -- Branch taken.
                                br_mode <= RELATIVE;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;

                    when "001" =>   -- BNE
                        alu_op <= ALU_AND;

                        case br_flag is
                            when false =>
                                -- Branch taken.
                                br_mode <= RELATIVE;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;
                    
                    when "100" =>   -- BLT
                        alu_op <= ALU_SLT;
                        case br_flag is
                            when true =>
                                -- Branch taken.
                                br_mode <= RELATIVE;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;

                    when "101" =>   -- BGT
                        alu_op <= ALU_SLT;
                        case br_flag is
                            when false =>
                                -- Branch taken.
                                br_mode <= RELATIVE;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;

                    when "110" =>   -- BLTU
                        alu_op <= ALU_SLTU;
                        case br_flag is
                            when true =>
                                -- Branch taken.
                                br_mode <= RELATIVE;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;

                    when "111" =>   -- BGEU
                        alu_op <= ALU_SLTU;
                        case br_flag is
                            when false =>
                                -- Branch taken.
                                br_mode <= RELATIVE;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;

                    when others =>
                        pc_off <= (others => '0');
                end case;
            
            -- "1101111": J-type encoding. Jump And Link.
            when J_JAL =>
                -- Operation type must be OP_PC.
                op_t <= OP_PC;
                -- PC-relative
                br_mode <= RELATIVE;
                
                -- Sign-extended
                pc_off(31 downto 20) <= (others => ir(31));
                pc_off(19 downto 12) <= ir(19 downto 12);
                pc_off(11) <= ir(20);
                pc_off(10 downto 1) <= ir(30 downto 21);
                pc_off(0) <= '0';

            -- "1100111": I-type encoding. Jump And Link Register.
            when I_JALR =>
                -- Force the ALU to use pc register as rs1.
                op_t <= OP_PC;
                -- Force the ALU to use [imm] instead of rs2.
                en_imm <= EN_IMM;

                -- Target address is formed by adding the signed-extended immediate
                -- to rs1.

                -- Sign-extended.
                imm(31 downto 12) <= (others => ir(31));
                -- The actual 12-bit immdiate.
                imm(11 downto 0) <= ir(31 downto 20);

                -- Force the ALU to compute the target address.
                alu_op <= ALU_ADD;
                -- PC-absolute jump.
                pc_mode <= ABSOLUTE;

                -- TODO: ensure current pc value + 4 is written to rd.
            -- U-type encoding.
            when U_LUI =>
                -- Places the U-immediate value in top 20 bits of rd, filling the lowest
                -- bits with 0.

                -- Force ALU to use [imm] instead of rs2.
                en_imm <= EN_IMM;
                imm(31 downto 12) <= ir(31 downto 12);
                imm(11 downto 0) <= (others => '0');

                -- Set rs1 to 0.
                rs1 <= (others => '0');

                -- Go through ALU. The result will be written to
                -- rd.
                alu_op <= ALU_ADD;

            when U_AUIPC =>
    end process;
end behav;