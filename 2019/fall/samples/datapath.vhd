library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_simple is
	port(
		clk: in std_logic;
		reset: in std_logic;
		inst_addr: out std_logic_vector(31 downto 0);  -- 指令地址
		inst: in std_logic_vector(31 downto 0);	
		inst_read: out std_logic;
		data_addr: out std_logic_vector(31 downto 0);  -- 数据地址
		data: inout std_logic_vector(31 downto 0);
		data_read: out std_logic;
		data_write: out std_logic
	    );
end entity;

architecture cpu_simple_behav of cpu_simple is
	-- utype instructions, using opcode
	constant rtype_lui: std_logic_vector(6 downto 0) := B"0110111";
	constant rtype_auipc: std_logic_vector(6 downto 0) := B"0010111";

	-- jtype
	constant jtype_jal: std_logic_vector(6 downto 0) := B"1101111";
	
	-- itype load instructions, using opcode, funct3
	constant itype_load: std_logic_vector(6 downto 0) := B"0000011";
	constant itype_lb: std_logic_vector(2 downto 0) := B"000";
	constant itype_lh: std_logic_vector(2 downto 0) := B"001";
	constant itype_lw: std_logic_vector(2 downto 0) := B"010";
	constant itype_lbu: std_logic_vector(2 downto 0) := B"100";
	constant itype_lhu: std_logic_vector(2 downto 0) := B"101";
	
	-- rtype alu operations, using opcode, funct3, funct7
	constant rtype_alu: std_logic_vector(6 downto 0) := B"0110011";
	constant rtype_addsub: std_logic_vector(2 downto 0) := B"000";
	constant rtype_add: std_logic_vector(6 downto 0) := B"0000000";
	constant rtype_sub: std_logic_vector(6 downto 0) := B"0100000";
	constant rtype_sll: std_logic_vector(2 downto 0) := B"001";
	constant rtype_slt: std_logic_vector(2 downto 0) := B"010";
	constant rtype_sltu: std_logic_vector(2 downto 0) := B"011";
	constant rtype_xor: std_logic_vector(2 downto 0) := B"100";
	constant rtype_srlsra: std_logic_vector(2 downto 0) := B"101";
	constant rtype_srl: std_logic_vector(6 downto 0) := B"0000000";
	constant rtype_sra: std_logic_vector(6 downto 0) := B"0100000";
	constant rtype_or: std_logic_vector(2 downto 0) := B"110";
	constant rtype_and: std_logic_vector(2 downto 0) := B"111";

	-- btype branches, using opcode, funct3
	constant btype_branch: std_logic_vector(6 downto 0) := B"1100011";
	constant btype_beq: std_logic_vector(2 downto 0) := B"000";
	constant btype_bne: std_logic_vector(2 downto 0) := B"001";
	constant btype_blt: std_logic_vector(2 downto 0) := B"100";
	constant btype_bge: std_logic_vector(2 downto 0) := B"101";
	constant btype_bltu: std_logic_vector(2 downto 0) := B"110";
	constant btype_bgeu: std_logic_vector(2 downto 0) := B"111";

	type regfile is array(natural range<>) of std_logic_vector(31 downto 0);
	signal regs: regfile(31 downto 0);

	signal rd_write: std_logic;
	signal rd_data: std_logic_vector(31 downto 0);

	signal opcode: std_logic_vector(6 downto 0);

	signal rd: std_logic_vector(4 downto 0);
	signal rs1: std_logic_vector(4 downto 0);
	signal rs2: std_logic_vector(4 downto 0);

	signal rs1_data: std_logic_vector(4 downto 0);
	signal rs2_data: std_logic_vector(4 downto 0);

	signal funct3: std_logic_vector(2 downto 0);
	signal funct7: std_logic_vector(6 downto 0);

	signal jal_imm20_1: std_logic_vector(20 downto 1);
	signal jal_offset: std_logic_vector(31 downto 0);

	signal utype_imm31_12: std_logic_vector(31 downto 12);

	signal itype_imm11_0: std_logic_vector(11 downto 0);

	signal btype_imm12_1: std_logic_vector(12 downto 1);

	signal rtype_alu_result: std_logic_vector(31 downto 0);

	signal pc: std_logic_vector(31 downto 0);
	signal ir: std_logic_vector(31 downto 0);

	signal next_pc: std_logic_vector(31 downto 0);

	signal load_addr: std_logic_vector(31 downto 0);
	signal store_addr: std_logic_vector(31 downto 0);

	signal branch_target: std_logic_vector(31 downto 0);
	signal branch_taken: boolean;

	function bool2logic32(b: boolean) return std_logic_vector(31 downto 0) is
	begin
		if b then
			return X"00000001";
		else
			return X"00000000";
		end if;
	end;

	function signext8to32(b: std_logic_vector(7 downto 0)) return std_logic_vector(31 downto 0) is
		variable t: std_logic_vector(31 downto 0);
	begin
		t(7 downto 0) <= b;
		t(31 downto 8) <= (others=>b(7));
		return t;
	end;

	function signext16to32(h: std_logic_vector(15 downto 0)) return std_logic_vector(31 downto 0) is
		variable t: std_logic_vector(31 downto 0);
	begin
		t(15 downto 0) <= h;
		t(31 downto 16) <= (others=>h(15));
		return t;
	end;
  
  function signext(x: std_logic_vector, n: integer) return std_logic_vector is
    variable t: std_logic_vector;
  begin
    t(n-1 downto x'length) <= x'high;
    t(x'length-1 downto 0) <= x;
    return t;
  end;
  
  function unsignext(x: std_logic_vector, n: integer) return std_logic_vector is
    variable t: std_logic_vector;
  begin
    t(n-1 downto x'length) <= '0';
    t(x'length-1 downto 0) <= x;
    return t;
  end;
  
begin

        -- PC寄存器的更新
        pcplus4 <= pc+4;
      
        next_pc <= pcplus4 when pcsel='0' else
                   branch_target;

	pc_update: process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset='1') then
				pc <= X"00000000";  -- 当reset信号有效时，pc被重置为0
			else
				pc <= next_pc;
			end if;
		end if;
	end process pc_update;
      
        -- 从指令存储器取指
	inst_addr <= pc;  -- 取指地址
	inst_read <= '1' when reset = '0' else '0';  -- 当reset无效时发出指令读取信号;
	ir <= inst;  -- 当前指令
      
        -- 译码
      	opcode <= ir(6 downto 0);
	rd <= ir(11 downto 7);
	rs1 <= ir(19 downto 15);
	rs2 <= ir(24 downto 20);

	funct3 <= ir(14 downto 12);
	funct7 <= ir(31 downto 25);

	jal_imm20_1 <= ir(31) & ir(19 downto 12) & ir(20) & ir(30 downto 21);
	jal_offset(20 downto 0) <= jal_imm20_1 & '0';
	jal_offset(31 downto 21) <= (others=>jal_imm20_1(20));

	utype_imm31_12 <= ir(31 downto 12);

	itype_imm11_0 <= ir(31 downto 20);

	btype_imm12_1 <= ir(31) & ir(7) & ir(30 downto 25) & ir(11 downto 8);

        -- 从寄存器组读取操作数
	rs1_data <= regs(to_integer(unsigned(rs1)));
	rs2_data <= regs(to_integer(unsigned(rs2)));

        -- 分支比较
        b_eq <= '1' when rs1_data = rs2_data else '0';
        b_lt <= '1' when rs1_data < rs2_data else '0';
      
        -- 生成立即数
        itype_imm_signed <= signext(itype_imm11_0, 32);
        itype_imm_unsigned <= unsignext(itype_imm11_0, 32);
      
        itype_imm <= itype_imm_signext when imm_sel = '0' else
                     itype_imm_unsignext;
      
        -- 算术逻辑运算
        src1 <= rs1_data when src1_sel = '00' else
                pcplus4;
        src2 <= rs2_data when src2_sel = '00' else
                imm;
	alu_result <= src1+src2 when alu_sel = '000' else
                      src1-src2 when alu_sel = '001' else
                      src1+src2;

	-- 访问数据存储器
	-- store_addr <= ...
	data_addr <= load_addr when opcode=itype_load else
		     store_addr;
	data_read <= '1' when opcode=itype_load else '0';  -- 当reset无效时发出指令读取信号;
	-- data_write <= ...
	load_data <= data when funct3=itype_lw else
		     signext8to32(data(7 downto 0)) when funct3=itype_lb else
		     signext16to32(data(15 downto 0)) when funct3=itype_lh else
		     X"000000" & data(7 downto 0) when funct3=itype_lbu else
		     X"0000" & data(15 downto 0) when funct3=itype_lhu else
		     X"00000000";
	-- data <= ...

	-- 写回
	rd_data <= alu_result when wb_sel = '0' else
                   data;
	
	-- R-type ALU operations
	rtype_alu_result <= std_logic_vector(signed(rs1_data) + signed(rs2_data)) when funct3 = rtype_addsub and funct7 = rtype_add else
			    std_logic_vector(signed(rs1_data) - signed(rs2_data)) when funct3 = rtype_addsub and funct7 = rtype_sub else
			    rs1_data sll to_integer(unsigned(rs2_data)) when funct3 = rtype_sll else
			    bool2logic32(signed(rs1_data) < signed(rs2_data)) when funct3 = rtype_slt else
			    bool2logic32(unsigned(rs1_data) < unsigned(rs2_data)) when funct3 = rtype_sltu else
			    rs1_data xor rs2_data when funct3 = rtype_xor else
			    rs1_data srl to_integer(unsigned(rs2_data)) when funct3 = rtype_srlsra and funct7 = rtype_srl else
			    rs1_data sra to_integer(unsigned(rs2_data)) when funct3 = rtype_srlsra and funct7 = rtype_sra else
			    rs1_data or rs2_data when funct3 = rtype_or else
			    rs1_data and rs2_data when funct3 = rtype_and else
			    X"00000000";  -- default ALU result

	rd_data <= rtype_alu_result when opcode = rtype_alu else
		   unsigned(pc)+4 when opcode=jtype_jal else
		   utype_imm31_12 & X"000" when opcode = utype_lui else
		   std_logic_vector(unsigned(utype_imm31_12 & X"000") + unsigned(pc)) when opcode=utype_auipc else
		   load_data when opcode=itype_load else
		   -- ......
		   X"00000000";  -- default rd data

	rd_write <= opcode=rtype_alu or opcode=utype_lui or opcode=utype_auipc or opcode=jtype_jal or opcode=itype_load;

	-- 分支指令
	branch_target(13 downto 0) <= btype_imm12_1 & '0' & '0';
	branch_target(31 downto 14) <= ( others => btype_imm12_1(12) );

	branch_taken <= rs1_data = rs2_data when funct3 = btype_beq else
			rs1_data /= rs2_data when funct3 = btype_bne else
			signed(rs1_data) < signed(rs2_data) when funct3 = btype_blt else
			signed(rs1_data) >= signed(rs2_data) when funct3 = btype_bge else
			unsigned(rs1_data) < unsigned(rs2_data) when funct3 = btype_bltu else
			unsigned(rs1_data) >= unsigned(rs2_data) when funct3 = btype_bgeu else
			false;


	-- 下一条指令地址
	next_pc <= branch_target when opcode = btype_branch and branch_taken else
		   std_logic_vector(unsigned(pc)+unsigned(jal_offset)) when opcode=jtype_jal else
		   std_logic_vector(unsigned(pc) + 4); -- 需补充其它情况


	-- ...... (其它组合逻辑)


	-- 时序逻辑部分


	-- regs
	reg_update: process(clk)
		variable i: integer;
		variable k: integer;
	begin
		i := to_integer(unsigned(rd));

		if(rising_edge(clk)) then
			if(reset='1') then
				-- reset all regs to 0 except reg[0]
				for k in 1 to 31 loop
					regs(k) <= X"00000000";  -- reset to 0
				end loop;	

			elsif(rd_write='1' and i /= 0) then

				regs(i) <= rd_data;

			end if;
		end if;
	end process reg_update;

-- ...... (其它时序逻辑)

end;
