library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all; 

entity clock_counter_pg_reg is
	port(
	clk    : in  std_logic;
	pwr_en : in  std_logic;
	cnt_in : in  std_logic_vector(63 downto 0);
	cnt    : out std_logic_vector(63 downto 0)
	);
end entity;

architecture behave of clock_counter_pg_reg is
signal cnt_in_iso, cnt_i : std_logic_vector(63 downto 0);
begin 
cnt <= cnt_i;
cnt_in_iso <= cnt_in when pwr_en = '1' else cnt_i;
process(clk)
begin
	if(clk'event and clk = '1') then
			cnt_i <= cnt_in;
	end if;
end process;

	
end behave;