library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
entity grg is 
	port(
	clk: in std_logic;
	load: in std_logic;
	store: in std_logic;
	lui: in std_logic;
	auipc: in std_logic;
	ri: in std_logic;
	rr: in std_logic;
	jal: in std_logic;
	jalr: in std_logic;
	be : in std_logic;
	funct3: in std_logic_vector(2 downto 0);
	rs1: in std_logic_vector(4 downto 0);
	rs2: in std_logic_vector(4 downto 0);
	rd: in std_logic_vector(4 downto 0);
	mem: in std_logic_vector(31 downto 0);
	imm: in std_logic_vector(11 downto 0);
	imm1: in std_logic_vector(19 downto 0);
	q: in std_logic_vector(7 downto 0);
	src1: out std_logic_vector(31 downto 0);
	src2: out std_logic_vector(31 downto 0);
	outa: out std_logic_vector(31 downto 0);
	wrimem: out std_logic_vector(31 downto 0);
	jum: out std_logic_vector(7 downto 0);
	jud: out std_logic
	);
end grg;
architecture behav of grg is
	type regfile is array(31 downto 0) of std_logic_vector(31 downto 0);
	signal regs:regfile;
	signal lo:std_logic:='0';
	signal srcc1:std_logic_vector(31 downto 0);
	signal srcc2:std_logic_vector(31 downto 0);
	signal tem1:bit_vector(31 downto 0);
	signal count:integer range 0 to 31;
	signal count1:integer range 0 to 31;
	begin
        srcc1<= regs(to_integer(unsigned(rs1)));
		src1 <= srcc1;
		outa <= regs(1);
		srcc2<= regs(to_integer(unsigned(rs2)));
		src2 <= srcc2;
		tem1 <=to_bitvector(srcc1);
		count<=to_integer(unsigned(imm(4 downto 0)));
		count1 <= to_integer(unsigned(rs2));
		process(clk)
		variable mem1:std_logic_vector(7 downto 0);
		variable tem:std_logic_vector(31 downto 0);
		variable mem2:std_logic_vector(15 downto 0);
		variable imm2:signed(31 downto 0);
		variable tem2:bit_vector(31 downto 0);
		variable tem3:std_logic_vector(7 downto 0);
		begin
			if(clk'event and clk='1') then		    
			    if(load='1') then
			    case lo is
			    when '0'=>
			    lo<='1';
			    when '1'=>
			    lo<='0';
			    end case;
			    if(lo='1') then
			    case funct3 is
			    when "000"=>--LB
			    mem1:=mem(7 downto 0);
			    tem:=std_logic_vector(resize(signed(mem1), tem'LENGTH));
			    regs(to_integer(unsigned(rd)))<=tem;
			    when "001"=>--LH
			    mem2:=mem(15 downto 0);
			    tem:=std_logic_vector(resize(signed(mem2), tem'LENGTH));
			    regs(to_integer(unsigned(rd)))<=tem;
			    when "010"=>--LW
			    regs(to_integer(unsigned(rd)))<=mem;
			    when "100"=>--LBU
			    mem1:=mem(7 downto 0);
			    regs(to_integer(unsigned(rd)))<="000000000000000000000000"&mem1;
			    when "101"=>--LHU
			    mem2:=mem(15 downto 0);
			    regs(to_integer(unsigned(rd)))<="0000000000000000"&mem2;
			    when others=>
			    end case;
			    end if;
			    elsif(store='1') then
			    case lo is
			    when '0'=>
			    lo<='1';
			    when '1'=>
			    lo<='0';
			    end case;
			    if(lo='0') then
			    case funct3 is
			    when "000"=>--SB
			    mem1:=srcc2(7 downto 0);
			    wrimem<="000000000000000000000000"&mem1;
			    when "001"=>--SH
			    mem2:=srcc2(15 downto 0);
			    wrimem<="0000000000000000"&mem2;
			    when "010"=>--SW
			    wrimem<=srcc2;
			    when others=>
			    wrimem<=(others=>'Z');
			    end case;
			    end if;
			    elsif(lui='1') then--LUI
			    regs(to_integer(unsigned(rd)))<=imm1&"000000000000";
			    elsif(auipc='1') then--AUIPC
			    tem:=imm1&"000000000000";
			    regs(to_integer(unsigned(rd)))<=imm1&"000000000000";
			    jum<=tem(7 downto 0);
			    elsif(ri='1') then
			    case funct3 is
			    when "000"=>--ADDI
			    regs(to_integer(unsigned(rd)))<=(imm+srcc1);
			    when "010"=>--SLTI
			    imm2:=resize(signed(imm), imm2'length);   
                if(signed(srcc1)<imm2) then
                regs(to_integer(unsigned(rd)))<=(others=>'1');
                else
                regs(to_integer(unsigned(rd)))<=(others=>'0');
                end if;
                when "011"=>--SLTIU
                if(srcc1<"00000000000000000000"&imm) then
                regs(to_integer(unsigned(rd)))<=(others=>'1');
                else
                regs(to_integer(unsigned(rd)))<=(others=>'0');
                end if;
                when "100"=>--XORI
                imm2:=resize(signed(imm), imm2'length);
                regs(to_integer(unsigned(rd)))<=(srcc1 xor std_logic_vector(imm2));
                when "110"=>--ORI
                imm2:=resize(signed(imm), imm2'length);
                regs(to_integer(unsigned(rd)))<=(srcc1 or std_logic_vector(imm2));
                when "111"=>--ANDI
                imm2:=resize(signed(imm), imm2'length);
                regs(to_integer(unsigned(rd)))<=(srcc1 and std_logic_vector(imm2));
                when "001"=>--SLLI
                tem2:=tem1 sll count;
                regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
                when "101"=>
                if(imm(11 downto 5)="0000000") then--SRLI
                tem2:=tem1 srl count;
                regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
                else--SRAI
                tem2:=tem1 sra count;
                regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
                end if;
                end case;
                elsif(rr='1') then
			    case funct3 is
			    when "000"=>
			    if(imm(11 downto 5)="0000000") then--ADD
			    regs(to_integer(unsigned(rd)))<=std_logic_vector(signed(srcc1)+signed(srcc2))(31 downto 0);
			    else--SUB
			    regs(to_integer(unsigned(rd)))<=std_logic_vector(signed(srcc1)-signed(srcc2))(31 downto 0);
			    end if;
			    when "001"=>--SLL
			    tem2:=tem1 sll count1;
                regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
                when "010"=>--SLT
                if(signed(srcc1)<signed(srcc2)) then
                regs(to_integer(unsigned(rd)))<=(others=>'1');
                else
                regs(to_integer(unsigned(rd)))<=(others=>'0');
                end if;
                when "011"=>--SLTU
                if(srcc1<srcc2) then
                regs(to_integer(unsigned(rd)))<=(others=>'1');
                else
                regs(to_integer(unsigned(rd)))<=(others=>'0');
                end if;
                when "100"=>--XOR
                regs(to_integer(unsigned(rd)))<=(srcc1 xor srcc2);
                when "101"=>
                if(imm(11 downto 5)="0000000") then--SRL
                tem2:=tem1 srl count1;
                regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
			    else--SRA
			    tem2:=tem1 sra count1;
                regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
			    end if;
			    when "110"=>--OR
			    regs(to_integer(unsigned(rd)))<=(srcc1 or srcc2);
			    when "111"=>--AND
                regs(to_integer(unsigned(rd)))<=(srcc1 and srcc2);
                end case;
                elsif(jal='1') then--JAL
			    imm2:=resize(signed(imm1), imm2'length);
			    tem3:=std_logic_vector(imm2*2)(7 downto 0);
			    jum<=tem3;
			    regs(to_integer(unsigned(rd)))<="000000000000000000000000"&tem3;
			    elsif(jalr='1') then--JALR
			    imm2:=resize(signed(imm), imm2'length);
			    tem3:=std_logic_vector(signed(imm2)+signed(srcc1))(7 downto 0);
			    jum<=tem3;
			    regs(to_integer(unsigned(rd)))<="000000000000000000000000"&tem3;
			    elsif(be='1') then
			    case funct3 is
			    when "000"=>--BEQ
			    if(srcc1=srcc2) then
			    imm2:=resize(signed(imm), imm2'length);
			    jum<=std_logic_vector(imm2*2)(7 downto 0);
			    jud<='1';
			    else
			    jud<='0';
			    end if;
			    when "001"=>--BNE
			    if(srcc1/=srcc2) then
			    imm2:=resize(signed(imm), imm2'length);
			    jum<=std_logic_vector(imm2*2)(7 downto 0);
			    jud<='1';
			    else
			    jud<='0';
			    end if;
			    when "100"=>--BLT
			    if(signed(srcc1)<signed(srcc2)) then
			    imm2:=resize(signed(imm), imm2'length);
			    jum<=std_logic_vector(imm2*2)(7 downto 0);
			    jud<='1';
			    else
			    jud<='0';
			    end if;
			    when "101"=>--BGE
			    if(signed(srcc1)>signed(srcc2)) then
			    imm2:=resize(signed(imm), imm2'length);
			    jum<=std_logic_vector(imm2*2)(7 downto 0);
			    jud<='1';
			    else
			    jud<='0';
			    end if;
			    when "110"=>--BLTU
			    if(srcc1<srcc2) then
			    imm2:=resize(signed(imm), imm2'length);
			    jum<=std_logic_vector(imm2*2)(7 downto 0);
			    jud<='1';
			    else
			    jud<='0';
			    end if;
			    when "111"=>--BGEU
			    if(srcc1>srcc2) then
			    imm2:=resize(signed(imm), imm2'length);
			    jum<=std_logic_vector(imm2*2)(7 downto 0);
			    jud<='1';
			    else
			    jud<='0';
			    end if;
			    when others=>
			    end case;
			    end if;
			end if;
		end process;
end behav;

--s    <= to_integer(unsigned(shamt));
--signal s :integer range 0 to 31;
--signal temp: bit_vector(31 downto 0);
--temp <= to_bitvector(src1);
 --when "001"=>--slli 
        --temp1<=temp sll s;
        --regs(to_integer(unsigned(rd)))<=to_stdlogicvector(temp1);
        --when "101"=>
        --if(ir(31 downto 25)="0000000") then--srli 
        --temp1<=temp srl s;
        --regs(to_integer(unsigned(rd)))<=to_stdlogicvector(temp1); 
        --else--srai
        --temp1<=temp sra s;
        --regs(to_integer(unsigned(rd)))<=to_stdlogicvector(temp1);
        --end if;

