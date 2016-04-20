library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity bp_pg_wrapper is
	generic (prediction_window : integer;
prediction_history : integer);
port(
	pwr_en : in std_logic;
	clk : in std_logic;
	nreset : in std_logic;
	PC_incr_IF : in std_logic_vector(prediction_window - 1  downto 0);
	PC_incr_MEM : in std_logic_vector(prediction_window - 1  downto 0);
	prediction : out std_logic;
	branch_MEM : in std_logic;
	is_branch_MEM : in std_logic
	);
end entity;	


architecture behave of bp_pg_wrapper is
signal prediction_unsafe : std_logic;
begin

prediction <= pwr_en and prediction_unsafe; --assume not taken when pwr disabled	
	
branch_predictor : entity work.branch_predictor generic map(
	prediction_window => prediction_window)
	port map(
	clk => clk,
	nreset => nreset,
	PC_incr_IF => PC_incr_IF,
	PC_incr_MEM => PC_incr_MEM,
	prediction => prediction_unsafe,
	branch_MEM => branch_MEM,
	is_branch_MEM => is_branch_MEM
	);

	
	
end behave;

