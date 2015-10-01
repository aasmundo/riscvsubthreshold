library IEEE;
use IEEE.STD_LOGIC_1164.all;
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
		rd : in std_logic_vector(4 downto 0);
		
	--from memory
		rd_dest_mem : in std_logic_vector(4 downto 0);
		rd_data_mem : in std_logic_vector(31 downto 0);
		rd_we_mem   : in std_logic;
		
	--from write back
		rd_dest_wb : in std_logic_vector(4 downto 0);
		rd_data_wb : in std_logic_vector(31 downto 0);
		rd_we_wb : in std_logic;
		
		
	--//\\--
		ALU_result : out std_logic_vector(31 downto 0)
		
	);
end execute;

architecture behave of execute is
signal ALU_a_in, ALU_b_in, b_reg : std_logic_vector(31 downto 0);

signal reg_a_src , reg_b_src : std_logic_vector(1 downto 0);
begin

alu_input_selection : process(reg1, reg2, imm, is_imm, rd_data_mem, rd_data_wb, b_reg)
begin
	reg_a_input_src_mux : case(reg_a_src) is 
		when ID     => ALU_a_in <= reg1;
		when MEM    => ALU_a_in <= rd_data_mem;
		when WB     => ALU_a_in <= rd_data_wb;
		when others => ALU_a_in <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	end case;
	
	reg_b_input_src_mux : case(reg_b_src) is
		when ID     => b_reg <= reg2;
		when MEM    => b_reg <= rd_data_mem;
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
	rd_mem => rd_dest_mem,
	rd_wb  => rd_dest_wb,
	rd_mem_we => rd_we_mem,
	rd_wb_we => rd_we_wb,
	rs1_src => reg_a_src,
	rs2_src => reg_b_src
	);
end behave;