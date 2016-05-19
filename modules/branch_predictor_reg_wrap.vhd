library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

entity branch_predictor_reg_wrap is 
generic (prediction_window : integer);
port(
	clk : in std_logic;
	pwr_en : in std_logic;
	data : out std_logic_vector(((2**prediction_window) * 2) - 1 downto 0);
	write_data : in std_logic_vector(1 downto 0);
	write_enable : in std_logic_vector((2**prediction_window) - 1 downto 0)
	);
end branch_predictor_reg_wrap;


architecture behave of branch_predictor_reg_wrap is
type prediction_table_t is array(0 to (2**prediction_window) - 1) of std_logic_vector(1 downto 0);
signal prediction_table : prediction_table_t;

--isolated signals--
signal write_data_iso   : std_logic_vector(1 downto 0);
signal write_enable_iso : std_logic_vector((2**prediction_window) - 1 downto 0);
begin

write_data_iso <= write_data   when pwr_en = '1' else (others => '0');
write_enable_iso   <= write_enable when pwr_en = '1' else (others => '0');

combi : process(prediction_table)
begin
	for i in 0 to (2**prediction_window) - 1 loop
		data((2*(i+1)) - 1 downto 2*i) <= prediction_table(i);
	end loop;
end process;
	
seq : process(clk)
begin
	if(clk'event and clk = '1') then
		for i in 0 to (2**prediction_window) - 1 loop
			if(write_enable_iso(i) = '1') then
				prediction_table(i) <= write_data_iso;	
			end if;
		end loop;
	end if;
end process;

	
	
end behave;