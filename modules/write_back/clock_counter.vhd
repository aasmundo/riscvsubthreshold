library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all; 


entity clock_counter is
	port(
	clk    : in  std_logic;
	cnt_en : in  std_logic;
	nreset : in  std_logic;
	cnt    : out std_logic_vector(63 downto 0)
	);
end entity;

architecture behave of clock_counter is
signal count : unsigned(63 downto 0);
begin

	cnt <= std_logic_vector(count);
	
	seq : process(clk) is
	begin
		if(clk'event and clk = '1') then
			if(nreset = '0') then
				count <= x"0000000000000000";
			else	
				if(cnt_en = '1') then
					count <= count + "1";
				else
					count <= count;
				end if;
			end if;
		end if;		
	end process;
	
end behave;