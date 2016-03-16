library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity clock_divider is	
	generic(
		division : integer := 3
	);
	port(
		clk    : in  std_logic;
		nreset : in  std_logic;
		d_clk  : out std_logic
	);
end clock_divider;



architecture behave of clock_divider is
signal clk_lvls : std_logic_vector(division downto 0);
begin
	
	clk_lvls(0) <= clk;
	
	clk_div_gen : for i in 1 to division generate
	begin
		process(clk_lvls(i), clk_lvls(i - 1), nreset) 
		begin
			if(nreset = '0') then
				clk_lvls(i) <= '1';	 --reset to 1 because limitation of library
			elsif(clk_lvls(i - 1)'event and clk_lvls(i - 1) = '1') then
				clk_lvls(i) <= not clk_lvls(i);	
			end if;
		end process;	
	end generate;

	d_clk <= clk_lvls(division);
	
end behave;

