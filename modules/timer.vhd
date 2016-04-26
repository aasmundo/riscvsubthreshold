library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use ieee.numeric_std.all;
library work;
use work.constants.all;


entity timer is
	port(
		clk : in std_logic;
		timer : out std_logic_vector(63 downto 0);
		nreset : in std_logic
	);
end timer;

architecture behave of timer is
signal timer_unsigned : unsigned(63 downto 0);
begin

timer <= std_logic_vector(timer_unsigned);

seq : process(clk)
begin
	if(clk'event and clk = '1') then
		if(nreset = '0') then
			timer_unsigned <= (others => '0');
		else
			timer_unsigned <= timer_unsigned + 1;
		end if;
	end if;
end process;
end behave;