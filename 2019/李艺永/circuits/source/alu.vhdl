library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opcodes.all;

-- Entity alu:
-- Performs arithmetic and logical calculation.
entity alu is
    port(
        i_data1 : in std_logic_vector(31 downto 0); -- data in rs1
        i_data2 : in std_logic_vector(31 downto 0); -- data in rs2 or immediate.
        i_op : in alu_op_t;
        q_res : out std_logic_vector(31 downto 0);
    );
end alu;

architecture behav of alu is
begin
    process(i_data1, i_data2, i_op) is
    begin
        case i_op is
            -- Addition/Subtraction.
            when ALU_ADD => -- ADD and ADDI.
                q_res <= std_logic_vector(signed(i_data1) + signed(i_data2));
            when ALU_SUB => -- SUB and SUBI.
                q_res <= std_logic_vector(signed(i_data1) - signed(i_data2));

            -- Shifts
            -- Shift amount is held in the lower 5 bits of i_data2.
            when ALU_SLL => -- SLL and SLLI.
                q_res <= std_logic_vector(signed(i_data1) sll to_integer(signed(i_data2(5 downto 0))));
            when ALU_SRA => --SRA and SRAI.
                q_res <= std_logic_vector(signed(i_data1) sra to_integer(signed(i_data2(5 downto 0))));
            when ALU_SRL => -- SRL and SRLI.
                q_res <= std_logic_vector(signed(i_data1) srl to_integer(signed(i_data2(5 downto 0))));

            when ALU_SLT => -- set-less-than.
                if signed(i_data1) < signed(i_data2) then
                    result(0) <= '1';
                else
                    result(0) <= '0';
                end if;
                -- Fill the higher bits to 0.
                q_res(31 downto 1) <= (others => '0');

            when ALU_SLTU => --set-less-than unsigned.
                -- Pseudo-op SNEZ rd, rs
                if unsigned(i_data1) = 0 and unsigned(i_data2) = 0 then
                    result(0) <= '0';
                else
                    if unsigned(i_data1) < unsigned(i_data2) then
                        result(0) <= '1';
                    else
                        result(0) <= '0';
                    end if;
                end if;
                -- Fill the higher bits to 0.
                q_res(31 downto 1) <= (others => '0');

            -- Bitwise logical operations.
            when ALU_OR =>
                q_res <= std_logic_vector(signed(i_data1) or signed(i_data2));
            when ALU_XOR =>
                q_res <= std_logic_vector(signed(i_data1) xor signed(i_data2));
            when ALU_AND =>
                q_res <= std_logic_vector(signed(i_data1) and signed(i_data2));
        end case;
    end process;
end behav;