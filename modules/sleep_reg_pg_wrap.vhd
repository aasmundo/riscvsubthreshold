library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

entity sleep_reg_pg_wrap is 
port(
	clk : in std_logic;
	pwr_en : in std_logic;
	d : in std_logic;
	q : out std_logic
	);
end sleep_reg_pg_wrap; 

architecture behave of sleep_reg_pg_wrap is
signal d_iso : std_logic;
signal q_i   : std_logic;
begin
q <= q_i;
d_iso <= d when pwr_en = '1' else q_i;
process(clk)
begin
	if(clk'event and clk = '1') then
		q_i <= d_iso;
	end if;
end process;
	
end behave;