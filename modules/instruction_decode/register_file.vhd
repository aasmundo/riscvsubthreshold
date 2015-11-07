library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all; 

entity register_file is	
	port(
	clk,
	nreset,
	reg_write 						: in std_logic; 
	read_register_1,
	read_register_2, 
	write_register 					: in std_logic_vector(4 downto 0);	
	write_data 						: in std_logic_vector(31 downto 0);
	
	read_data_1, 
	read_data_2 					: out std_logic_vector(31 downto 0)
	);											   
end register_file;

architecture behave of register_file is
type register_array is array(1 to 31) of std_logic_vector(31 downto 0);
signal register_a : register_array;
signal read_1, read_2 : std_logic_vector(31 downto 0);
begin	
combi : process(write_register, read_register_1, read_register_2, write_data, register_a, read_1, read_2, reg_write)

begin
	if(read_register_1 = write_register and read_register_1 /= "00000" and reg_write = '1') then read_data_1 <= write_data; 
	else                                      						   read_data_1 <= read_1;
	end if;
	if(read_register_2 = write_register and read_register_2 /= "00000" and reg_write = '1') then read_data_2 <= write_data;
	else                                      							read_data_2 <= read_2;
	end if;
	
	
	case (to_integer(unsigned(read_register_1))) is
		when 0 =>
			read_1 <= x"00000000";
		when others =>
			read_1 <= register_a(to_integer(unsigned(read_register_1))); 
	end case;
		
	case (to_integer(unsigned(read_register_2))) is
		when 0 =>
			read_2 <= x"00000000";
		when others =>
			read_2 <= register_a(to_integer(unsigned(read_register_2)));
	end case;
		
end process;
	
	
seq : process(clk)
	begin
		if(clk'event and clk = '1') then
			if(nreset = '0') then
				register_a <= (others => (others => '0'));
			elsif(reg_write = '0' nor to_integer(unsigned(write_register)) = 0) then
				register_a(to_integer(unsigned(write_register))) <= write_data;
			end if;
				
		end if;
	end process;
	
end behave;
	