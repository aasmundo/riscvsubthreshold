library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;


entity instr_mem_sram_model is
generic (address_width : integer);
port(
	Address               : in std_logic_vector(address_width - 1 downto 0);	  
	clk                   : in std_logic;
	read_data             : out std_logic_vector(31 downto 0);
	write_data_input      : in std_logic_vector(31 downto 0);
	write_en              : in std_logic;
	reset_pulse_generator : in std_logic;
	idle                  : out std_logic;
	
	write_all_en          : in std_logic;
	write_all_data        : in std_logic_vector(((2**address_width) * 8 ) - 1 downto 0)
);
end instr_mem_sram_model;


architecture behave of instr_mem_sram_model is
signal state, state_n : integer range 0 to 31;
type mem_t is array(0 to ((2**address_width) - 1)) of std_logic_vector(7 downto 0);
signal mem : mem_t;

signal output_reg, input_reg : std_logic_vector(31 downto 0);
signal idle_i, output_reg_we, mem_we, input_reg_we : std_logic;

signal data_out_n : std_logic_vector(31 downto 0);
signal address_input_reg, address_input_reg_n : std_logic_vector(address_width - 1 downto 0);


begin

 
	
combi : process(state, write_en, address_input_reg, Address)

begin
	address_input_reg_n <= address_input_reg;
	state_n <= state + 1;
	output_reg_we <= '0';
	mem_we <= '0';
	input_reg_we <= '0';
	idle_i <= '0';
	case(state) is
		when 0 =>
			idle_i <= '1';
			address_input_reg_n <= Address;
			if(write_en = '1') then
				state_n <= 16;
				input_reg_we <= '1';
			else
				state_n <= 1;
			end if;
		when 1|2|3|4|5|6|7|8|9|10|11|12|13 =>
			null;
		when 14 =>	
			output_reg_we <= '1';
		when 15 =>
			idle_i <= '1';
			state_n <= 0;
		when 16|17|18|19|20|21|22|23|24|25|26|27|28|29 =>
			null;
		when 30 =>
			mem_we <= '1';
			idle_i <= '1';
			state_n <= 0;
		when others =>
			null;
		end case;	
end process;
	


combi2 : process(address, mem)
begin
	data_out_n <= mem(to_integer(unsigned(address) + 3)) & 
	mem(to_integer(unsigned(address) + 2)) &
	mem(to_integer(unsigned(address) + 1)) &
	mem(to_integer(unsigned(address)));
end process;

seq : process(clk)
begin
	if(clk = '1' and clk'event) then
		if(reset_pulse_generator = '0') then
			state <= 0;
		elsif(write_all_en = '1') then
			for i in 1 to (2**address_width) loop
				mem(i-1) <= write_all_data((i * 8) - 1 downto ((i-1) * 8));	
			end loop;	
		else
			if(mem_we = '1') then
				mem(to_integer(unsigned(address)))     <= input_reg(7 downto 0);
				mem(to_integer(unsigned(address) + 1)) <= input_reg(15 downto 8);
				mem(to_integer(unsigned(address) + 2)) <= input_reg(23 downto 16);
				mem(to_integer(unsigned(address) + 3)) <= input_reg(31 downto 24);
			end if;
			if(output_reg_we = '1') then
				read_data <= data_out_n;
			end if;
			if(input_reg_we = '1') then
				input_reg <= write_data_input;
			end if; 
			address_input_reg <= address_input_reg_n;
			state <= state_n;
			idle <= idle_i;
		end if;
	end if;
end process;
end behave;
