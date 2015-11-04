library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity memory is
	port(
	clk : in std_logic;
	
	ALU_result : in std_logic_vector(31 downto 0);
	rs2_data_ex : in std_logic_vector(31 downto 0);
	rs2_data_wb : in std_logic_vector(31 downto 0);
	rs2_src : in std_logic;
	mem_write_width : in std_logic_vector(1 downto 0);
	mem_we : in std_logic;
	
	is_branch : in std_logic;
	funct3 : in std_logic_vector(2 downto 0);
	is_jump : in std_logic;
	new_PC : out std_logic_vector(PC_WIDTH - 1 downto 0);
	branch_target : in std_logic_vector(PC_WIDTH - 1 downto 0);
	control_transfer : out std_logic;
	
	mem_read_out : out std_logic_vector(31 downto 0);
	
	
	--testbench input
	tb_mem_we : in std_logic;
	tb_mem_data : in std_logic_vector(31 downto 0);
	tb_mem_be : in std_logic_vector(1 downto 0);
	tb_mem_write_addr : in std_logic_vector(DATA_MEM_WIDTH - 1 downto 0)

	);
end memory;
	
architecture behave of memory is
signal rs2_data : std_logic_vector(31 downto 0);
signal branch : std_logic;

signal bram_we : std_logic;
signal bram_data_in : std_logic_vector(31 downto 0);
signal bram_addr : std_logic_vector(DATA_MEM_WIDTH - 1 downto 0);
signal bram_mem_be : std_logic_vector(1 downto 0);
begin 
data_mem_input : process(tb_mem_we, tb_mem_data, tb_mem_be, tb_mem_write_addr, mem_write_width, ALU_result, mem_we, rs2_data)
begin
	if(tb_mem_we = '0') then
		 bram_mem_be <= mem_write_width;
		 bram_addr <= ALU_result(DATA_MEM_WIDTH - 1 downto 0);
   	   	 bram_we <= mem_we;
		 bram_data_in <= rs2_data; 
	else
		 bram_mem_be <= tb_mem_be;
		 bram_addr <= tb_mem_write_addr;
   	   	 bram_we <= tb_mem_we;
		 bram_data_in <= tb_mem_data;
	end if;
end process;
	
	
	
rs2_src_process : process(rs2_src, rs2_data_ex, rs2_data_wb) 
begin
	if(rs2_src = '1') then rs2_data <= rs2_data_wb;
	else 				   rs2_data <= rs2_data_ex;
	end if;
end process;
data_memory : entity work.bram generic map(
address_width => DATA_MEM_WIDTH)
port map (
clk => clk,
byte_enable => bram_mem_be,
address => bram_addr,
we => bram_we,
write_data => bram_data_in,
read_data => mem_read_out
);

branch_control : entity branch_control port map(
	ALU_result => ALU_result,
	is_branch => is_branch,
	funct3 => funct3,
	branch => branch	
);

process(is_jump, ALU_result, branch_target, branch, is_jump)

begin
	case (is_jump) is
		when '1' => new_PC <= ALU_result(PC_WIDTH - 1 downto 0);
		when others => new_PC <= branch_target;
	end case;
	control_transfer <= branch or is_jump;
end process;



end behave;