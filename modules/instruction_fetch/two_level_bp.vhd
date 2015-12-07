library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

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
type history_t is array(0 to (2**prediction_window) - 1) of std_logic_vector(prediction_history - 1 downto 0);
type single_p_table_t is array(0 to (2**prediction_history) - 1) of std_logic_vector(1 downto 0);
type p_table_t is array(0 to (2**prediction_window) - 1) of single_p_table_t;
signal history : history_t;
signal p_table : p_table_t;
signal PC_incr_MEM_int : integer := 0;
signal PC_incr_IF_int : integer := 0;
signal history_MEM_int : integer := 0;
signal history_IF_int : integer := 0;
begin

PC_incr_MEM_int <= 	to_integer(unsigned(PC_incr_MEM));
PC_incr_IF_int <= to_integer(unsigned(PC_incr_IF));
history_IF_int <= to_integer(unsigned(history(PC_incr_IF_int)));
history_MEM_int	<= to_integer(unsigned(history(PC_incr_MEM_int)));
process(PC_incr_IF_int, history_IF_int, p_table)

begin
	prediction <= p_table(PC_incr_IF_int)(history_IF_int)(1);	
	--prediction <= '0';
end process;
	
	
process(clk, nreset)

begin
	if(clk'event and clk = '1') then
		if(nreset = '0') then
			history <= (others => (others => '0'));
			p_table <= (others => (others => "01"));
		else
			if(is_branch_MEM = '1') then 
				p_table(PC_incr_MEM_int)(history_MEM_int)(0) <=
				(branch_MEM and p_table(PC_incr_MEM_int)(history_MEM_int)(1)) or 
			(branch_MEM and not p_table(PC_incr_MEM_int)(history_MEM_int)(0)) or
			(p_table(PC_incr_MEM_int)(history_MEM_int)(1) and not p_table(PC_incr_MEM_int)(history_MEM_int)(0));
			
			
			p_table(PC_incr_MEM_int)(history_MEM_int)(1) <= 
			(branch_MEM and (p_table(PC_incr_MEM_int)(history_MEM_int)(1) or p_table(PC_incr_MEM_int)(history_MEM_int)(0))) or
			(p_table(PC_incr_MEM_int)(history_MEM_int)(1) and p_table(PC_incr_MEM_int)(history_MEM_int)(0));
			
			
			for i in 0 to prediction_history - 2 loop
				history(PC_incr_MEM_int)(i) <= history(PC_incr_MEM_int)(i + 1);
			end loop;	 
			history(PC_incr_MEM_int)(prediction_history - 1) <= branch_MEM; 
			end if;
		end if;
	end if;
	
	
end process;
	
end behave;