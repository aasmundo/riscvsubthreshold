library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;


entity instr_mem_wrap is 
	generic (address_width : integer);
	port(
	clk                      : in std_logic;
	d_clk                    : in std_logic;		
	Address                  : in std_logic_vector(address_width - 1 downto 0);
	read_data                : out std_logic_vector(31 downto 0);
	write_data_input         : in std_logic_vector(31 downto 0);
	write_en                 : in std_logic;
	reset_pulse_generator    : in std_logic;
	idle                     : out std_logic;
	
	--memory reroute for no startup--
	reroute_write_en : out std_logic;
	reroute_Address  : out std_logic_vector(address_width - 1 downto 0);
	reroute_write_data_input  : out std_logic_vector(31 downto 0);
	reroute_read_data : in std_logic_vector(31 downto 0);
	reroute_reset_pulse_generator : out std_logic;
	reroute_idle : in std_logic	
	);
end instr_mem_wrap;

architecture behave of instr_mem_wrap is

function reverse_vector (a: in std_logic_vector)
return std_logic_vector is
  variable result: std_logic_vector(a'RANGE);
  alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
begin
  for i in aa'RANGE loop
    result(i) := aa(i);
  end loop;
  return result;
end function; -- function reverse_vector

signal Address_reg          : std_logic_vector(address_width - 1 downto 0);
signal write_data_input_reg : std_logic_vector(31 downto 0);
signal output   : std_logic_vector(31 downto 0);
begin

	
	

	

seq : process(d_clk)

begin
	if(d_clk'event and d_clk = '1') then
		Address_reg <= Address;
		write_data_input_reg <= write_data_input;
		read_data <= output;
	end if;
end process;


		
	reroute_write_en <= write_en;
	reroute_Address  <=  Address;
	reroute_write_data_input  <= write_data_input;
	output <= reroute_read_data;
	reroute_reset_pulse_generator <= reset_pulse_generator;
	idle <= reroute_idle;

end behave;