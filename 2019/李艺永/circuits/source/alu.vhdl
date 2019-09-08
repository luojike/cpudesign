library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.opcodes.all;

entity alu is
    port(
        i_data1 : in std_logic_vector(31 downto 0);
        i_data2 : in std_logic_vector(31 downto 0);
        i_op : in alu_op_t;
        q_res : out std_logic_vector(31 downto 0);
    );
end alu;

architecture behav of alu is
begin
    process(i_data1, i_data2, i_op) is
    begin
        case i_op is
            when ALU_ADD =>
                q_res <= std_logic_vector(signed(i_data1) + signed(i_data2));
            when ALU_SUB =>
                q_res <= std_logic_vector(signed(i_data1) - signed(i_data2));
            when ALU_SLL => -- shift-left-logical.
                q_res <= std_logic_vector(signed(i_data1) sll to_integer(signed(i_data2(5 downto 0))));
            when ALU_SLT => -- set-less-than.
                