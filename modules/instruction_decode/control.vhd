library ieee;
use ieee.std_logic_1164.all;

entity control is
	port(
	opcode : in std_logic_vector(6 downto 0);
	funct3 : in std_logic_vector(2 downto 0);
	
	--control signals:
	signal wb_src : out std_logic;
	signal wb_we : out std_logic;
	signal mem_we : out std_logic;
	signal mem_write_width : out std_logic_vector(1 downto 0);
	signal is_branch : out std_logic
	);
end control;


architecture behave of control is

begin
	
control_process: process(opcode, funct3)

begin
	wb_src <= '0';
	wb_we <= '0';
	mem_we <= '0';
	mem_write_width <= funct3(1 downto 0);
	is_branch <= '0';
	
	case opcode is
		when "0100011" => mem_we <= '1';
		when "0000011" => wb_src <= '1';	
		when "0-10011" => wb_we <= '1';
		when "1100011" => is_branch <= '1';
		when others    => NULL;
	end case;
	
	
end process;
end behave;
	