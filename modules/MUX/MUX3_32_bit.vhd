library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUX3_32_bit is
	 port(
		 a, b, c : in STD_LOGIC_VECTOR (31 downto 0) ;
		 sel : in STD_LOGIC_VECTOR (1 downto 0);
		 output : out STD_LOGIC_VECTOR (31 downto 0)
	     );
end MUX3_32_bit;

--}} End of automatically maintained section

architecture MUX3_32_bit of MUX3_32_bit is
begin

process(a, b, c, sel)
begin
	case sel is
        when "00" =>
            output <= a;
        when "01" =>
            output <= b;
        when others =>
            output <= c;
        end case;
end process;
	

end MUX3_32_bit;
