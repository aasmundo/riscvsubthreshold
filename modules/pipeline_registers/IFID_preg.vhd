library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity IFID_preg is
	port(
	clk : in std_logic;
	flush : in std_logic;
	
	instruction_i : in std_logic_vector(31 downto 0);
	branch_target_in : in std_logic_vector(PC_WIDTH - 1 downto 0);
	branch_target_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
	
	instruction_o : out std_logic_vector(31 downto 0);
	
	current_PC_in : in std_logic_vector(PC_WIDTH - 1 downto 0);
	current_PC_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_incr_in :  in std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_incr_out :  out std_logic_vector(PC_WIDTH - 1 downto 0)
	);
end IFID_preg;

architecture behave of IFID_preg is
begin
	
seq : process(clk, flush, instruction_i)
begin
	if(clk'event and clk = '1') then
		if(flush = '1') then
			 instruction_o <= x"00000000";
		else
			 instruction_o <= instruction_i;
		end if;
		branch_target_out <= branch_target_in;
		current_PC_out    <= current_PC_in;
		PC_incr_out <= PC_incr_in;
	end if;
end process;

end behave;
	