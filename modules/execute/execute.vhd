library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;

entity execute is
	port(
	--from instruction decode
		
		ALU_operation : in std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0);
		reg1 : in std_logic_vector(31 downto 0);
		reg2 : in std_logic_vector(31 downto 0);
		imm : in std_logic_vector(31 downto 0);
		is_imm : in std_logic;
		rs1 : in std_logic_vector(4 downto 0);
		rs2 : in std_logic_vector(4 downto 0);
		rs2_out : out std_logic_vector(31 downto 0);
		rd : in std_logic_vector(4 downto 0);
		current_PC : in std_logic_vector(PC_WIDTH - 1 downto 0);
		reg_or_PC : in std_logic;
		
	--from memory
		rd_dest_mem : in std_logic_vector(4 downto 0);
		rs2_adr_mem : in std_logic_vector(4 downto 0);
		rd_data_mem : in std_logic_vector(31 downto 0);
		rd_we_mem   : in std_logic;
		
	--from write back
		rd_dest_wb : in std_logic_vector(4 downto 0);
		rd_data_wb : in std_logic_vector(31 downto 0);
		rd_we_wb : in std_logic;
		
		
	--//\\--
		ALU_result : out std_logic_vector(31 downto 0);
		mem_rs2_src : out std_logic
		
	);
end execute;

architecture behave of execute is
signal ALU_a_in, ALU_b_in, b_reg, a_reg, PC_ext : std_logic_vector(31 downto 0);

signal reg_a_src , reg_b_src : std_logic_vector(1 downto 0);
begin

PC_ext <= std_logic_vector(resize(unsigned(current_PC), PC_ext'length));
rs2_out <= b_reg;	
alu_input_selection : process(reg1, reg2, imm, is_imm, rd_data_mem, rd_data_wb, b_reg, reg_a_src, reg_b_src, PC_ext, reg_or_PC, a_reg)
begin
	reg_a_input_src_mux : case(reg_or_PC) is 
		when '0'     => ALU_a_in <= a_reg;
		when '1'     => ALU_a_in <= PC_ext;
		when others => ALU_a_in <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	end case;
	
	a_reg_src_mux : case(reg_a_src) is 
		when ID     => a_reg <= reg1;
		when MEM_1 | MEM_2 => a_reg <= rd_data_mem;
		when WB     => a_reg <= rd_data_wb;
		when others => a_reg <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	end case;
	
	reg_b_input_src_mux : case(reg_b_src) is
		when ID     => b_reg <= reg2;
		when MEM_1 | MEM_2 => b_reg <= rd_data_mem;
		when WB     => b_reg <= rd_data_wb;
		when others => b_reg <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	end case;
	
	if(is_imm = '1') then
		ALU_b_in <= imm;
	else
		ALU_b_in <= b_reg;
	end if;

end process;

Arithmetic_logic_unit : entity work.ALU port map(
	A => ALU_a_in,
	B => ALU_b_in,
	operation => ALU_operation,
	result => ALU_result
	);
	
data_forwarder : entity work.forwarder port map(
	rs1_ex => rs1,
	rs2_ex => rs2,
	rs2_mem => rs2_adr_mem,
	rd_mem => rd_dest_mem,
	rd_wb  => rd_dest_wb,
	rd_mem_we => rd_we_mem,
	rd_wb_we => rd_we_wb,
	rs1_src => reg_a_src,
	rs2_src => reg_b_src,
	mem_rs2_src => mem_rs2_src
	);
end behave;