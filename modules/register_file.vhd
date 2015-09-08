library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all; 

entity registers is	
	port(
	clk, 
	reg_write 						: in std_logic; 
	read_register_1,
	read_register_2, 
	write_register 					: in std_logic_vector(4 downto 0);	
	write_data 						: in std_logic_vector(31 downto 0);
	
	read_data_1, 
	read_data_2 					: out std_logic_vector(31 downto 0)
	);											   
end registers;

architecture behave of registers is
type register_array is array(1 to 31) of std_logic_vector(31 downto 0);
signal register_a : register_array;
signal read_data_1_signal, read_data_2_signal : std_logic_vector(31 downto 0);
signal is_zero_1, is_zero_2 : std_logic; 
begin	
	
combi : process(read_register_1, read_register_2,register_a)
	begin
		case to_integer(unsigned(read_register_1)) is
			when 0 =>
				read_data_1 <= x"00000000";
			when others =>
				read_data_1 <= register_a(to_integer(unsigned(read_register_1)));
			end case;
			
		case to_integer(unsigned(read_register_2)) is
			when 0 =>
				read_data_2 <= x"00000000";
			when others =>
				read_data_2 <= register_a(to_integer(unsigned(read_register_2)));
			end case;	
	end process;
	
seq : process(clk)
	begin
		if(clk'event and clk = '0') then
			if(reg_write = '0' nor to_integer(unsigned(write_register)) = 0) then
				register_a(to_integer(unsigned(write_register))) <= write_data;
			end if;
		end if;
	end process;
	
end behave;
	