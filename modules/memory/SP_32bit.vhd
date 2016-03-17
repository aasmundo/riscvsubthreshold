library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

entity SP_32bit is 
generic (address_width : integer);
port(
		clk      : in  std_logic;
		we		 : in  std_logic;
		address  : in  std_logic_vector(address_width -1 downto 0);
		data_in  : in  std_logic_vector(31 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end SP_32bit;

architecture behave of SP_32bit is
--type mem_t is array(0 to ((2**address_width) - 1)) of std_logic_vector(7 downto 0);
--signal mem : mem_t;
begin

--combi : process(address, mem)
--begin
--	data_out <= mem(to_integer(unsigned(address) + 3)) & 
--	mem(to_integer(unsigned(address) + 2)) &
--	mem(to_integer(unsigned(address) + 1)) &
--	mem(to_integer(unsigned(address)));
--end process;

--seq : process(clk, we, data_in, address)
--begin
--	if(clk = '1' and clk'event) then
--		if(we = '1') then
--			mem(to_integer(unsigned(address))) <= data_in(7 downto 0);
--			mem(to_integer(unsigned(address) + 1)) <= data_in(15 downto 8);
--			mem(to_integer(unsigned(address) + 2)) <= data_in(23 downto 16);
--			mem(to_integer(unsigned(address) + 3)) <= data_in(31 downto 24);
--		end if;
--	end if;
--end process;

end behave;
