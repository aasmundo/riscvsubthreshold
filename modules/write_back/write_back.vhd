library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;

entity write_back is
	port(
	wb_src : in std_logic_vector(1 downto 0);
	mem_data : in std_logic_vector(31 downto 0);
	ALU_data : in std_logic_vector(31 downto 0);
	wb_data : out std_logic_vector(31 downto 0);
	mem_load_width : in std_logic_vector(1 downto 0);
	mem_load_unsigned : in std_logic;
	PC_incr : in std_logic_vector(PC_WIDTH -1 downto 0);
	clock_count : in std_logic_vector(63 downto 0)
	);
end write_back;	  

architecture behave of write_back is
signal mem_data_ext : std_logic_vector(31 downto 0);
signal sign_ext_helper : std_logic_vector(2 downto 0);
begin



	
combi : process(wb_src, mem_data, ALU_data, mem_data_ext, mem_load_unsigned, mem_load_width, sign_ext_helper, PC_incr) 
begin
	sign_ext_helper <= mem_load_unsigned & mem_load_width;
	case (sign_ext_helper) is
		when "000" => mem_data_ext <= std_logic_vector(resize(signed(mem_data(7 downto 0)), mem_data'length));
		when "001" => mem_data_ext <= std_logic_vector(resize(signed(mem_data(15 downto 0)), mem_data'length));
		when "100" => mem_data_ext <= std_logic_vector(resize(unsigned(mem_data(7 downto 0)), mem_data'length));
		when "101" => mem_data_ext <= std_logic_vector(resize(unsigned(mem_data(15 downto 0)), mem_data'length));
		when "010" => mem_data_ext <= mem_data;
		when others => mem_data_ext <= mem_data;
	end case;
	
	case (wb_src) is
		when "00" => wb_data <= ALU_data;
		when "01" => wb_data <= mem_data_ext;
		when "10" => wb_data <= std_logic_vector(resize(unsigned(PC_incr), wb_data'length));
		when "11" => wb_data <= clock_count(31 downto 0);
		when others => wb_data <= ALU_data;
	end case;
	
end process;
	
end behave;