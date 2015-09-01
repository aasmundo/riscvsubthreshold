library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity JAL_detector is
port(
	instr : in std_logic_vector(6 downto 0);
	is_jal : out std_logic
);
end JAL_detector;


architecture behave of JAL_detector is
begin
process(instr)
begin
	is_jal <= instr(6) and instr(5) and (not instr(4)) and instr(3) and instr(2) and instr(1) and instr(0);
end process;

end behave;