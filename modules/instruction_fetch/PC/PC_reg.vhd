library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library work;
use work.constants.all;

entity PC_reg is
	port(clk, we, pwr_en 	: in std_logic;
	PC_in : in std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_out : out std_logic_vector(PC_WIDTH - 1 downto 0)
	);
end PC_reg;		   


architecture behave of PC_reg is

signal PC_in_iso : std_logic_vector(PC_WIDTH - 1 downto 0);
signal we_iso    : std_logic;
begin

PC_in_iso <= PC_in when pwr_en = '1' else (others => '0');
we_iso <= we when pwr_en = '1' else '0';  
	
process(clk)
begin
	if(clk'event and clk = '1') then
		if(we_iso = '1') then
			PC_out <= PC_in;
		end if;
	end if;
end process;
	
end behave;