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
	
	mem_read_out : out std_logic_vector(31 downto 0)

	);
end memory;
	
architecture behave of memory is
signal rs2_data : std_logic_vector(31 downto 0);
begin
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
byte_enable => mem_write_width,
address => ALU_result(DATA_MEM_WIDTH - 1 downto 0),
we => mem_we,
write_data => rs2_data,
read_data => mem_read_out
);



end behave;