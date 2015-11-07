library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity IFID_preg is
	port(
	clk : in std_logic;
	flush : in std_logic;
	stall : in std_logic;
	
	instruction_i : in std_logic_vector(31 downto 0);
	branch_target_in : in std_logic_vector(PC_WIDTH - 1 downto 0);
	branch_target_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
	
	instruction_o : out std_logic_vector(31 downto 0);
	
	current_PC_in : in std_logic_vector(PC_WIDTH - 1 downto 0);
	current_PC_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_incr_in :  in std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_incr_out :  out std_logic_vector(PC_WIDTH - 1 downto 0);
	branched_in : in std_logic;
	branched_out : out std_logic
	);
end IFID_preg;

architecture behave of IFID_preg is
signal instruction : std_logic_vector(31 downto 0);
signal branch_target :std_logic_vector(PC_WIDTH - 1 downto 0);
	
signal current_PC : std_logic_vector(PC_WIDTH - 1 downto 0);
signal PC_incr : std_logic_vector(PC_WIDTH - 1 downto 0);
signal branched : std_logic;
begin

branch_target_out <= branch_target;
current_PC_out    <= current_PC;
PC_incr_out <= PC_incr;
instruction_o <= instruction;
branched_out <= branched;	
seq : process(clk, flush, instruction_i, stall)
begin
	if(clk'event and clk = '1') then
		if(stall = '0')	then
			branch_target <= branch_target_in;
			current_PC    <= current_PC_in;
			PC_incr <= PC_incr_in;
			if(flush = '1') then
			 	instruction <= x"00000000";
				 branched <= '0';
			else
				branched <= branched_in;
			 	instruction <= instruction_i;
			end if;
		else
			branch_target <= branch_target;
			current_PC    <= current_PC;
			PC_incr <= PC_incr;
			if(flush = '1') then
			 	instruction <= x"00000000";
				 branched <= '0';
			else
				branched <= branched;
			 	instruction <= instruction;
			end if;
		end if;
		
	end if;
end process;

end behave;
	