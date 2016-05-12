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
	ALU_data_in : in std_logic_vector(31 downto 0);
	ALU_data_out : out std_logic_vector(31 downto 0);
	
	wb_src_in : in std_logic_vector(1 downto 0);
	wb_src_out : out std_logic_vector(1 downto 0);
	wb_we_in : in std_logic;
	wb_we_out : out std_logic;
	rd_in : in std_logic_vector(4 downto 0);
	rd_out : out std_logic_vector(4 downto 0);
	mem_load_width_in : in std_logic_vector(1 downto 0);
	mem_load_width_out : out std_logic_vector(1 downto 0);
	mem_load_unsigned_in : in std_logic;  
	mem_load_unsigned_out : out std_logic;
	PC_incr_in :  in std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_incr_out :  out std_logic_vector(PC_WIDTH - 1 downto 0)
	
	);
end MEMWB_preg;	

architecture behave of MEMWB_preg is

begin

mem_read_data_out <= mem_read_data_in;	--mem data is already sequential
seq : process(clk, flush)
begin
	if(clk = '1' and clk'event) then
		if(flush = '1') then
			wb_we_out <= '0';
		else
			wb_we_out <= wb_we_in;
		end if;
		wb_src_out <= wb_src_in after 1 ns;
		rd_out <= rd_in after 1 ns;
		ALU_data_out <= ALU_data_in;
		mem_load_unsigned_out <= mem_load_unsigned_in;
		mem_load_width_out <= mem_load_width_in;
		PC_incr_out <= PC_incr_in;
	end if;
end process;
	
end behave;