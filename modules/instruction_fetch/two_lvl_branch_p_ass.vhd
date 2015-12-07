library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity two_level_bp is 
generic (prediction_window : integer;
prediction_history : integer);
port(
	clk : in std_logic;
	nreset : in std_logic;
	PC_incr_IF : in std_logic_vector(prediction_window - 1  downto 0);
	PC_incr_MEM : in std_logic_vector(prediction_window - 1  downto 0);
	prediction : out std_logic;
	branch_MEM : in std_logic;
	is_branch_MEM : in std_logic
	);
end two_level_bp;

architecture behave of two_level_bp is
type tag_table_t : is array(0 to (2**prediction_window) - 1) of std_logic_vector(PC_WIDTH - 1 downto prediction_window);
signal tag_table_one, tag_table_two : tag_table_t;
signal lru : std_logic_vector(prediction_window - 1 downto 0);
signal prediction_one, prediction_two : std_logic;

signal one_match, two_match : std_logic;

begin


predictor_one : entity work.two_level_bp generic map(
	prediction_window => prediction_window,
	prediction_history => prediction_history)
	port map(
	clk => clk,
	nreset => nreset,
	PC_incr_IF => PC_incr_IF,
	PC_incr_MEM => PC_incr_MEM,
	prediction => prediction_one,
	branch_MEM => branch_MEM,
	is_branch_MEM => is_branch_MEM
	);
	
predictor_two : entity work.two_level_bp generic map(
	prediction_window => prediction_window,
	prediction_history => prediction_history)
	port map(
	clk => clk,
	nreset => nreset,
	PC_incr_IF => PC_incr_IF,
	PC_incr_MEM => PC_incr_MEM,
	prediction => prediction_two,
	branch_MEM => branch_MEM,
	is_branch_MEM => is_branch_MEM
	);
	
process(clk, nreset)

begin
	if(clk'event and clk = '1') then
		if(nreset = '0') then
			lru <= (others <= '0');
			tag_table_one => (others <= '0');
			tag_table_two => (others <= '0');
		else
			
		end if;
	end if;
	
	
end process;
	
end behave;