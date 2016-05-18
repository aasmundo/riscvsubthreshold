library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;


entity register_file_regs_wrap is
	port(
	clk : in std_logic;
	pwr_en : in std_logic;
	write_enable : in std_logic_vector(31 downto 1);
	data : out std_logic_vector(991	downto 0);
	write_data : in std_logic_vector(31 downto 0)
	);
end entity;

architecture behave of register_file_regs_wrap is
type register_array_t is array(1 to 31) of std_logic_vector(31 downto 0);
signal register_array : register_array_t;
signal write_data_iso : std_logic_vector(31 downto 0);
signal write_enable_iso : std_logic_vector(31 downto 1);
begin

write_enable_iso <= write_enable when pwr_en = '1' else (others => '0');
write_data_iso <= write_data when pwr_en = '1' else (others => '0');

combi : process(register_array) 
begin
	for i in 1 to 31 loop
		data((i*32) - 1 downto ((i-1) * 32)) <= register_array(i);
	end loop;
end process;
	
seq : process(clk)
begin
	if(clk'event and clk = '1') then
		for i in 1 to 31 loop
			if(write_enable_iso(i) = '1') then
				register_array(i) <= write_data_iso;
			end if;
		end loop;
	end if;
end process;
	
end behave;