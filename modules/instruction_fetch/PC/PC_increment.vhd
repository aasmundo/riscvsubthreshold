library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.constants.all;

entity PC_increment is
	port(input : in	 std_logic_vector(PC_WIDTH - 1 downto 0);	 
		output : out std_logic_vector(PC_WIDTH - 1 downto 0)
	);
end entity;

architecture behave of PC_increment is

begin
process(input)
begin


output <= std_logic_vector(unsigned(input) + 1 );


end process;

end behave;