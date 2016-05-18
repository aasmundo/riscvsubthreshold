library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all; 

entity register_file is	
	port(
	clk,
	nreset,
	pwr_en,
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
signal read_1, read_2 : std_logic_vector(31 downto 0);
signal write_enable : std_logic_vector(31 downto 1);
signal write_data_w_nreset : std_logic_vector(31 downto 0);
signal data : std_logic_vector(991 downto 0);
begin
	
register_regs : entity work.register_file_regs_wrap	port map(
	clk => clk,
	pwr_en => pwr_en,
	write_enable => write_enable,
	data => data,
	write_data => write_data_w_nreset
	);


write_data_w_nreset <= write_data when nreset = '1' else (others => '0');
	
combi : process(write_register, read_register_1, read_register_2, write_data, data, read_1, read_2, reg_write)

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
			read_1 <= data(((to_integer(unsigned(read_register_1))*32) - 1) downto ((to_integer(unsigned(read_register_1)-1) *32))); 
	end case;
		
	case (to_integer(unsigned(read_register_2))) is
		when 0 =>
			read_2 <= x"00000000";
		when others =>
			read_2 <= data(((to_integer(unsigned(read_register_2))*32) - 1) downto ((to_integer(unsigned(read_register_2)-1) *32)));
	end case;
	
	if(nreset = '0') then
		write_enable <= (others => '1');
	else	
		for i in 1 to 31 loop
			if(to_integer(unsigned(write_register)) = i) then
				write_enable(i) <= reg_write;
			else
				write_enable(i) <= '0';
			end if;
		end loop;
	end if;
		
end process;

	
end behave;
	