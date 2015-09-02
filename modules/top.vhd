library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity top is
	port(
	clk    : in std_logic;
	nreset : in std_logic
	);
end top;


architecture behave of top is

--Instruction fetch
signal branch_or_jump : std_logic;
signal boj_target : std_logic_vector(31 downto 0);
signal stall_IF : std_logic;
signal instruction_IF : std_logic_vector(31 downto 0);

--IFID pipline register
signal instruction_IFID : std_logic_vector(31 downto 0);
signal flush_IFID : std_logic;
begin
	
instruction_fetch : entity work.instruction_fetch port map(
	clk => clk,
	nreset => nreset,
	branch_or_jump => branch_or_jump,
	boj_target => boj_target,
	stall => stall_IF,
	instruction_o => instruction_IF
	);
	
IFID_pipline_register : entity work.IFID_preg port map(
	clk => clk,
	flush => flush_IFID,
	instruction_i => instruction_IF,
	instruction_o => instruction_IFID	
	);
	
end behave;