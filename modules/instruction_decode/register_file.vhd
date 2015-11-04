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
signal read_pass_t_1, read_pass_t_2 : std_logic;
begin	
combi : process(write_register, read_register_1, read_register_2, read_pass_t_2, read_pass_t_1, write_data, register_a)

begin
	read_pass_t_1 <= '0';
	read_pass_t_2 <= '0';
	if(read_register_1 = write_register) then read_pass_t_1 <= '1'; 
	end if;
	if(read_register_2 = write_register) then read_pass_t_2 <= '1'; 
	end if;
	
	case (read_register_1) is
		when "00000" =>
			read_data_1 <= x"00000000";
		when others =>
			if(	read_pass_t_1 = '0') then
				read_data_1 <= register_a(to_integer(unsigned(read_register_1))); 
			else 
				read_data_1 <= write_data;
			end if;
	end case;
		
	case (read_register_2) is
		when "00000" =>
			read_data_2 <= x"00000000";
		when others =>
			if(	read_pass_t_2 = '0') then
				read_data_2 <= register_a(to_integer(unsigned(read_register_2)));
			else 
				read_data_2 <= write_data;
			end if;
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
	