library ieee;
use ieee.std_logic_1164.all;

entity control is
	port(
	
	instruction : in std_logic_vector(31 downto 0);
	--control signals:
	wb_src : out std_logic_vector(1 downto 0);
	wb_we : out std_logic;
	mem_we : out std_logic;
	mem_write_width : out std_logic_vector(1 downto 0);
	mem_load_unsigned : out std_logic;
	is_branch : out std_logic;	  
	reg_or_PC : out std_logic;
	is_jump : out std_logic
	);
end control;


architecture behave of control is
signal opcode : std_logic_vector(6 downto 0);
signal funct3 : std_logic_vector(2 downto 0);
begin

opcode <= instruction(6 downto 0);	
funct3 <= instruction(14 downto 12);

control_process: process(opcode, funct3, instruction)

begin
	wb_src <= "00";
	wb_we <= '0';
	mem_we <= '0';
	mem_write_width <= funct3(1 downto 0);
	mem_load_unsigned <= funct3(2);
	is_branch <= '0';
	reg_or_PC <= '0';
	is_jump <= '0';
	
	case opcode is
		when "0100011" => 			  mem_we    <= '1';
		when "0000011" => 
						  			  wb_src    <= "01";
						  			  wb_we     <= '1';
		when "0110011" | "0010011" => wb_we     <= '1'; 
		when "0110111" => 			  wb_we     <= '1'; --LUI
		when "1100011" =>			  is_branch <= '1';
		when "0010111" =>			  				    --
									  wb_we     <= '1';
									  reg_or_PC <= '1';
		when "1101111" =>							    --JAL
									  wb_we     <= '1';
									  wb_src    <= "10";
		when "1100111" =>             					--JALR
						              wb_we     <= '1';
		                              wb_src    <= "10";
									  is_jump   <= '1';
		when "1110011" =>			  
								    if(instruction(31 downto 12) = "11000000000000000010") then
									  wb_we     <= '1';
									end if;
									  wb_src    <= "11";
		when others    => NULL;
	end case;
	
	
end process;
end behave;
	