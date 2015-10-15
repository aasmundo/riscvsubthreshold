library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;

entity bram is
	generic(address_width : integer := 7);
	port(
	    clk : in std_logic;
		byte_enable : in std_logic_vector(1 downto 0);
		address : in std_logic_vector(address_width - 1 downto 0); 
		we : in std_logic;
		write_data : in std_logic_vector(31 downto 0);
		read_data : out std_logic_vector(31 downto 0)
	);
end bram;

architecture behave of bram is
type ram_t is array(0 to (2**address_width) - 1) of std_logic_vector(7 downto 0);
signal ram : ram_t;
begin
	
seq : process(clk, we, address, byte_enable)
begin
	if(clk'event and clk = '1') then
		if(we = '1') then
			ram(to_integer(unsigned(address))) <= write_data(7 downto 0);
			if(byte_enable(1) = '1' or byte_enable(0) = '1') then
				ram(to_integer(unsigned(address) + 1)) <= write_data(15 downto 8);
			end if;
			if(byte_enable(1) = '1') then
				ram(to_integer(unsigned(address) + 2)) <= write_data(23 downto 16);
				ram(to_integer(unsigned(address) + 3)) <= write_data(31 downto 24);
			end if;
		end if;
		read_data <= ram(to_integer(unsigned(address) + 3)) &
					 ram(to_integer(unsigned(address) + 2)) &
					 ram(to_integer(unsigned(address) + 1)) &
					 ram(to_integer(unsigned(address))); 
	end if;
end process;
end behave;