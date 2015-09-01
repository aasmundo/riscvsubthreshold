library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUX2_5_bit is
	 port(
		 sel : in STD_LOGIC;
		 a, b : in STD_LOGIC_VECTOR(4 downto 0);
		 output : out STD_LOGIC_VECTOR(4 downto 0)
	     );
end MUX2_5_bit;

--}} End of automatically maintained section

architecture MUX2_5_bit of MUX2_5_bit is
begin

process(a, b, sel)
begin
	if sel = '0' then
		output <= a;
	else
		output <= b;		 
	end if;
end process;


end MUX2_5_bit;
