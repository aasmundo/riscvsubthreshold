library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity write_back is
	port(
	wb_src : in std_logic;
	mem_data : in std_logic_vector(31 downto 0);
	rs2_data : in std_logic_vector(31 downto 0);
	wb_data : out std_logic_vector(31 downto 0)
	);
end write_back;	  

architecture behave of write_back is

begin

combi : process(wb_src, mem_data, rs2_data) 
begin
	if(wb_src = '0') then wb_data <= mem_data;
	else 				  wb_data <= rs2_data;
	end if;
end process;
	
end behave;