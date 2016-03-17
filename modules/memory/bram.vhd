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
--type ram_t is array(0 to (2**address_width) - 1) of std_logic_vector(7 downto 0);
--signal ram : ram_t := (others => (others => 'U'));
begin
	
--seq : process(clk)
--begin
--	if(clk'event and clk = '1') then
--		if(we = '1') then
--			assert (write_data(7 downto 0) /= "UUUUUUUU") report "unknown write data bram" severity failure;
--			case (byte_enable) is
--				when "00" =>
--					ram(to_integer(unsigned(address)))     <= write_data(7 downto 0);
--				when "01" => 
--					ram(to_integer(unsigned(address)))     <= write_data(7 downto 0);
--					ram(to_integer(unsigned(address) + 1)) <= write_data(15 downto 8);
--					assert (write_data(15 downto 7) /= "UUUUUUUU") report "unknown write data bram" severity failure;
--				when others =>
--					ram(to_integer(unsigned(address)))     <= write_data(7 downto 0);
--					ram(to_integer(unsigned(address) + 1)) <= write_data(15 downto 8);
--					ram(to_integer(unsigned(address) + 2)) <= write_data(23 downto 16);
--					ram(to_integer(unsigned(address) + 3)) <= write_data(31 downto 24);
--					assert (write_data(15 downto 7) /= "UUUUUUUU") report "unknown write data bram" severity failure;
--					assert (write_data(31 downto 15) /= "UUUUUUUU") report "unknown write data bram" severity failure;
--			end case;
--		end if;
--		
--		case (byte_enable) is
--			when "00" =>
--				read_data(7 downto 0)   <= ram(to_integer(unsigned(address)));
--				read_data(31 downto 8)  <= x"000000";
---			when "01" =>  
--				read_data(7 downto 0)   <= ram(to_integer(unsigned(address)));
--				read_data(15 downto 8)  <= ram(to_integer(unsigned(address) + 1));
--				read_data(31 downto 16) <= x"0000";
--			when others =>
--				read_data <= 
--					 ram(to_integer(unsigned(address) + 3)) &
--					 ram(to_integer(unsigned(address) + 2)) &
--					 ram(to_integer(unsigned(address) + 1)) &
--					 ram(to_integer(unsigned(address)));
--		end case;
--	end if;
--end process;
end behave;
