library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

entity branch_predictor_pg is 
generic (prediction_window : integer);
port(
	clk : in std_logic;
	pwr_en : in std_logic;
	nreset : in std_logic;
	PC_incr_IF : in std_logic_vector(prediction_window - 1  downto 0);
	PC_incr_MEM : in std_logic_vector(prediction_window - 1  downto 0);
	prediction : out std_logic;
	branch_MEM : in std_logic;
	is_branch_MEM : in std_logic
	);
end branch_predictor_pg;

architecture behave of branch_predictor_pg is

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


signal write_data, write_data_with_reset   : std_logic_vector(1 downto 0);
signal write_enable, write_enable_with_reset : std_logic_vector((2**prediction_window) - 1 downto 0);

signal data : std_logic_vector(((2**prediction_window) * 2) - 1 downto 0);

signal old_sat_cnt : std_logic_vector(1 downto 0);
begin

write_enable_with_reset <= write_enable when nreset = '1' else (others => '1');
write_data_with_reset <= write_data when nreset = '1' else "01";	
	
branch_predictor_regs : entity work.branch_predictor_reg_wrap generic map(
	prediction_window => prediction_window)
port map(
	clk => clk,
	pwr_en => pwr_en,
	data => data,
	write_data => write_data_with_reset,
	write_enable => write_enable_with_reset
	);

old_sat_cnt <= data((2* to_integer(unsigned(PC_incr_MEM))) + 1 downto (2* to_integer(unsigned(PC_incr_MEM))));

write_data <= saturation(branch_MEM, old_sat_cnt);

combi : process(PC_incr_IF, data, is_branch_MEM, PC_incr_MEM) 

begin
	prediction <= data((2* to_integer(unsigned(PC_incr_IF))) + 1); 
	for i in 0 to (2**prediction_window) - 1 loop
		if( i = to_integer(unsigned(PC_incr_MEM))) then
			write_enable(i) <= is_branch_MEM;
		else
			write_enable(i) <= '0';
		end if;
	end loop;
end process;

	
end behave;
