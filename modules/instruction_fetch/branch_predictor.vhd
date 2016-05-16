library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

entity branch_predictor is 
generic (prediction_window : integer);
port(
	clk : in std_logic;
	nreset : in std_logic;
	PC_incr_IF : in std_logic_vector(prediction_window - 1  downto 0);
	PC_incr_MEM : in std_logic_vector(prediction_window - 1  downto 0);
	prediction : out std_logic;
	branch_MEM : in std_logic;
	is_branch_MEM : in std_logic
	);
end branch_predictor;

architecture behave of branch_predictor is
type prediction_table_t is array(0 to (2**prediction_window) - 1) of std_logic_vector(1 downto 0);
signal prediction_table : prediction_table_t;

function saturation (branch : std_logic; sat_cnt : std_logic_vector)
                 return std_logic_vector is
begin
	if(branch = '0' and sat_cnt /= "00") then
		return std_logic_vector(unsigned(sat_cnt) - 1);
	elsif(branch = '1' and sat_cnt /= "11") then
		return std_logic_vector(unsigned(sat_cnt) + 1);
	end if;
	return sat_cnt;
end saturation;

signal n_sat_cnt : std_logic_vector(1 downto 0);



begin

n_sat_cnt <= saturation(branch_MEM, prediction_table(to_integer(unsigned(PC_incr_MEM))));

combi : process(PC_incr_IF, prediction_table) 

begin
	prediction <= prediction_table(to_integer(unsigned(PC_incr_IF)))(1);
end process;


seq : process(clk)
begin
	if(clk'event and clk = '1') then
		if(nreset = '0') then 
			prediction_table <= (others => "01");
		elsif(is_branch_MEM = '1') then 
			prediction_table(to_integer(unsigned(PC_incr_MEM))) <= n_sat_cnt;
		end if;
	end if;
	
end process;
	
end behave;
