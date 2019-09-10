library ieee;
use ieee.std_logic_1164.all;
use work.opcodes.all;
use work.pc.all;

-- Entity control_unit:
-- Determin alu_op_t from funct7, funct3 and opcodes.
entity control_unit is
    port (
        -- Input.
        ir : in std_logic_vector(31 downto 0);
        pc : in std_logic_vector(31 downto 0);

        br_flag : in boolean;                       -- A flag emitted by ALU. Used for conditional branch.

        -- Output.

        res_sel : out std_logic_vector(1 downto 0); -- Result selector for rd. Selecting results among ALU, value read from mem and PC register.
        alu_op : out alu_op_t;                      -- Decoded ALU operation or used in address calculation.
        pc_off : out std_logic_vector(31 downto 0); -- Offset to add to PC register. This is wired to PC component.
        pc_mode : out std_logic_vector(1 downto 0); -- See PC entity.

        rs1 : out std_logic_vector(4 downto 0);
        rs2 : out std_logic_vector(4 downto 0);
        en_write_reg : out boolean;                 -- A flag that indicates whether to write result of ALU to register rd.
        rd : out std_logic_vector(4 downto 0);

        en_imm : out std_logic_vector(0 downto 0);  -- A flag that indicates whether [imm] is valid. Used in multiplexing between rs2 and imm.
        imm : out std_logic_vector(31 downto 0);    -- The actual immediate value(sign-extended).

        en_write_ram : out boolean;                 -- Input to en_write of mem entity.
        ld_sign_ex : out boolean;                   -- Load sign-extended?
        ld_sz : out std_logic_vector(1 downto 0);   -- Load size.
        st_sz : out std_logic_vector(1 downto 0);   -- Store size.
    );
end control_unit;

architecture behav of control_unit is
    -- Sets [pc_mode].
    constant PC_normal : std_logic_vector(1 downto 0) := "00";
    constant PC_relative : std_logic_vector(1 downto 0) := "01";
    constant PC_absolute : std_logic_vector(1 downto 0) := "10";

    -- Selector values that select results among ALU, PC and RAM.
    -- Sets [res_sel].
    constant ALU_res : std_logic_vector(1 downto 0) := "00";
    constant RAM_res : std_logic_vector(1 downto 0) := "01";
    constant PC_res : std_logic_vector(1 downto 0) := "10";

    -- Selector values that select between rs2 and immediate.
    -- Sets [en_imm].
    constant EN_REG : std_logic_vector(0 downto 0) := "0";
    constant EN_IMM : std_logic_vector(0 downto 0) := "0";

    constant BYTE_SZ : std_logic_vector(1 downto 0) := "00";
    constant HALFW_SZ : std_logic_vector(1 downto 0) := "01";
    constant WRD_SZ : std_logic_vector(1 downto 0) := "10";

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
        res_sel <= ALU_res;
        rs1 <= ir(19 downto 15);
        rs2 <= ir(24 downto 20);
        rd <= ir(11 downto 7);
        alu_op <= ALU_ADD;
        imm <= (others => '0');     -- all '0'
        
        en_imm <= EN_REG;
        en_write_ram <= false;
        en_write_reg <= true;

        pc_mode <= pc_normal;

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
                -- The effective byte address is obtained by adding rs1 to the 
                -- sign-extended 12 bit offset.
                
                -- Compute address.
                alu_op <= ALU_ADD;

                -- Write result read from RAM to rd.
                res_sel <= RAM_res;

                -- Force ALU to use [imm] instead of rs2.
                en_imm <= EN_IMM;
                -- Sign-extended.
                imm(31 downto 12) <= (others => ir(31));
                -- Actual immediate.
                imm(11 downto 0) <= ir(31 downto 20);

                -- Generate mem signal.
                case funct3 is
                    when "000" =>   -- LB
                        ld_sign_ex <= true;
                        ld_sz <= BYTE_SZ;

                    when "001" =>   -- LH
                        ld_sign_ex <= true;
                        ld_sz <= HALFW_SZ;

                    when "010" =>   -- LW
                        ld_sz <= WRD_SZ;

                    when "100" =>   -- LBU
                        ld_sign_ex <= false;
                        ld_sz <= BYTE_SZ;

                    when "101" =>   -- LHU
                        ld_sign_ex <= false;
                        ld_sz <= HALFW_SZ;
                    when others =>
                        null;
                end case;

                -- Write RAM result to rd.
                -- Writing to rd takes place by default.

            -- "0100011": S-type encoding. Store to memory.
            when S_STORE =>
                -- The effective address is obtained by adding rs1 to the sign-extended
                -- [imm]. The value to store is held in rs2.
                
                alu_op <= ALU_ADD;
                en_imm <= EN_IMM;

                -- Sign-extended.
                imm(31 downto 12) <= (others => ir(31));
                -- High bits.
                imm(11 downto 5) <= ir(31 downto 25);
                -- Low bits.
                imm(4 downto 0) <= ir(7 downto 7);

                case funct3 is
                    when "000" =>   -- SB
                        st_sz <= BYTE_SZ;
                    when "001" =>   -- SH
                        st_sz <= HALFW_SZ;
                    when "010" =>   -- SW
                        st_sz <= WRD_SZ;
                end case;

                -- Write ALU result to RAM.
                en_write_ram <= true;

                -- Do not write rd since there's nothing to write.
                -- Also do not worry about res_sel at all.
                en_write_reg <= false;

            -- "1100011": B-type encoding. Conditional Branches.
            when B_BR =>
                res_sel <= PC_res;

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
                                pc_mode <= PC_relative;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;

                    when "001" =>   -- BNE
                        alu_op <= ALU_AND;

                        case br_flag is
                            when false =>
                                -- Branch taken.
                                pc_mode <= PC_relative;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;
                    
                    when "100" =>   -- BLT
                        alu_op <= ALU_SLT;
                        case br_flag is
                            when true =>
                                -- Branch taken.
                                pc_mode <= PC_relative;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;

                    when "101" =>   -- BGT
                        alu_op <= ALU_SLT;
                        case br_flag is
                            when false =>
                                -- Branch taken.
                                pc_mode <= PC_relative;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;

                    when "110" =>   -- BLTU
                        alu_op <= ALU_SLTU;
                        case br_flag is
                            when true =>
                                -- Branch taken.
                                pc_mode <= PC_relative;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;

                    when "111" =>   -- BGEU
                        alu_op <= ALU_SLTU;
                        case br_flag is
                            when false =>
                                -- Branch taken.
                                pc_mode <= PC_relative;
                            when others =>
                                -- Branch not taken.
                                pc_off <= (others => '0');
                        end case;

                    when others =>
                        pc_off <= (others => '0');
                end case;
            
                -- Write ALU result to rd.
                -- Writing to rd takes place by default.

            -- "1101111": J-type encoding. Jump And Link.
            when J_JAL =>
                -- The jump target address is formed by adding
                -- [pc_off] to the address of this jump instruction.

                -- curr PC + 4 will be written to rd.
                res_sel <= PC_res;

                pc_mode <= PC_relative;

                -- Sign-extended
                pc_off(31 downto 20) <= (others => ir(31));
                pc_off(19 downto 12) <= ir(19 downto 12);
                pc_off(11) <= ir(20);
                pc_off(10 downto 1) <= ir(30 downto 21);
                pc_off(0) <= '0';

                -- Write to rd.
                -- Writing to rd takes place by default.

            -- "1100111": I-type encoding. Jump And Link Register.
            when I_JALR =>
                -- Target address is formed by adding the signed-extended immediate
                -- to rs1.

                -- curr PC + 4 will be written to rd.
                res_sel <= PC_res;

                -- PC register will actually be updated on next rising_edge,
                -- so don't worry 'bout it.
                pc_mode <= PC_absolute;

                -- Calculating the absolute address from ALU requires selecting imm
                -- instead of rs2.
                en_imm <= EN_IMM;

                -- Sign-extended.
                imm(31 downto 12) <= (others => ir(31));
                -- The actual 12-bit immdiate.
                imm(11 downto 0) <= ir(31 downto 20);

                -- Target address = rs1 + imm
                alu_op <= ALU_ADD;

                -- The ALU result is wired to PC component directly, so don't worry 'bout it.
                
                -- Write to rd.
                -- Writing to rd takes place by default.
            -- U-type encoding.
            when U_LUI =>
                -- Places the U-immediate value in top 20 bits of rd, filling the lowest
                -- bits with 0.

                -- Set rs1 to 0.
                rs1 <= (others => '0');

                -- Force ALU to use [imm] instead of rs2.
                en_imm <= EN_IMM;
                imm(31 downto 12) <= ir(31 downto 12);
                imm(11 downto 0) <= (others => '0');

                -- Go through ALU. The result will be written to rd.
                alu_op <= ALU_ADD;

                -- Write to rd.
                -- Writing to rd takes place by default.
            when U_AUIPC =>
                -- 32-bit offset is formed from 20-bit immediate. 
                -- The target address is formed by curr pc + 32-bit offset.
                -- The target address is written to rd.

                -- The curr value of PC.
                rs1(31 downto 0) <= pc(31 downto 0);

                -- Force ALU to use [imm] instead of rs2.
                en_imm <= EN_IMM;
                imm(31 downto 12) <= ir(31 downto 12);
                imm(11 downto 0) <= (others => '0');

                alu_op <= ALU_ADD;

                -- Write to rd.
                -- Writing to rd takes place by default.
            when others =>
                null;
        end case;
    end process;
end behav;