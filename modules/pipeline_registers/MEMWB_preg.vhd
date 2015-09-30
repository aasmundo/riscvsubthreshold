library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;


entity MEMWB_preg is
	port(
	clk   : in std_logic;
	flush : in std_logic;
	
	mem_read_data_in : in std_logic_vector(31 downto 0);
	mem_read_data_out : out std_logic_vector(31 downto 0);
	rs2_data_in : in std_logic_vector(31 downto 0);
	rs2_data_out : out std_logic_vector(31 downto 0);
	
	wb_src_in : in std_logic;
	wb_src_out : out std_logic;
	wb_we_in : in std_logic;
	wb_we_out : out std_logic;
	rd_in : in std_logic_vector(4 downto 0);
	rd_out : out std_logic_vector(4 downto 0)
	
	
	);
end MEMWB_preg;	

architecture behave of MEMWB_preg is

begin
	
seq : process(clk, flush)
begin
	if(clk = '1' and clk'event) then
		if(flush = '1') then
			wb_we_out <= '0';
		else
			wb_we_out <= wb_we_in;
		end if;
		mem_read_data_out <= mem_read_data_in;
		wb_src_out <= wb_src_in;
		rd_out <= rd_in;
		rs2_data_out <= rs2_data_in;
	end if;
end process;
	
end behave;