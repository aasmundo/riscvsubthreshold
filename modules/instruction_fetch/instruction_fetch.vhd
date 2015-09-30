library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity instruction_fetch is
	port(
	clk : in std_logic;	
	nreset : in std_logic;
	
	--from other stages
	branch_or_jump : in std_logic;
	boj_target : in std_logic_vector(31 downto 0);
	stall : in std_logic;
	
	--to IFID preg
	instruction_o : out std_logic_vector(31 downto 0)
	);
end instruction_fetch;

architecture behave of instruction_fetch is
signal PC_we : std_logic;
signal PC_in, PC_out : std_logic_vector(31 downto 0);
signal PC_incr : std_logic_vector(31 downto 0);
signal instruction : std_logic_vector(31 downto 0);
begin

	
combi : process(PC_incr, boj_target, branch_or_jump, PC_in)

begin
	case(branch_or_jump) is
		when '0'    => PC_in <= PC_incr;
		when '1'    => PC_in <= boj_target;
		when others => PC_in <= UNKNOWN_32BIT;
	end case;
end process;
	
	
PC_we <= not stall;
instruction_o <= instruction;

PC : entity work.PC port map(
	clk => clk,
	we => PC_we,
	nreset => nreset,
	PC_in => PC_in,
	PC_out => PC_out
	);

PC_incrementer : entity work.PC_increment port map(
	input => PC_out,
	output => PC_incr
	);
	
instruction_memory : entity work.SP_32bit generic map(
address_width => INSTRUCTION_MEM_WIDTH) 
port map (
clk => clk,
address => PC_out(INSTRUCTION_MEM_WIDTH - 1 downto 0),
data_in => x"00000000",
data_out => instruction,
we => '0'
);

	
	
end behave;