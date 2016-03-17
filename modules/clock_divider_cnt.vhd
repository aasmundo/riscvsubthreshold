library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity clock_divider_cnt is	
	generic(
		division : integer := 3
	);
	port(
		clk    : in  std_logic;
		nreset : in  std_logic;
		d_clk  : out std_logic
	);
end clock_divider_cnt;



architecture behave of clock_divider_cnt is
signal clk_lvls, n_clk_lvls : std_logic_vector(division - 1 downto 0);
begin

d_clk <= clk_lvls(division - 1);	
	
combi : process(clk_lvls)
begin
	n_clk_lvls <= std_logic_vector(unsigned(clk_lvls) + 1);
end process;
	
	
	
seq : process(clk) 
begin
if(clk'event and clk = '1') then
	if(nreset = '0') then
		clk_lvls <= (others => '0');
	else
		clk_lvls <= n_clk_lvls;
	end if;
end if;
	
end process;
	
end behave;

