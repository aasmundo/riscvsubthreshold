library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;

entity hazard_detector is
	port(
	ex_rd     : in  std_logic_vector(4 downto 0);
	rs1       : in  std_logic_vector(4 downto 0);
	rs2       : in  std_logic_vector(4 downto 0);
	ex_wb_src : in  std_logic_vector(1 downto 0);
	is_imm    : in  std_logic;
	stall     : out std_logic
	
	);
end hazard_detector;

architecture behave of hazard_detector is
signal hazard_vector : std_logic_vector(1 downto 0);
signal rs1_eq_rd, rs2_eq_rd	: std_logic;
begin


	process(ex_wb_src, rs1, rs2, ex_rd, is_imm, rs1_eq_rd, rs2_eq_rd) 
	begin
		if(rs1 = ex_rd) then rs1_eq_rd <= '1';
		else                 rs1_eq_rd <= '0';
		end if;
		
		if(rs2 = ex_rd) then rs2_eq_rd <= '1';
		else				 rs2_eq_rd <= '0';
		end if;
		
		stall <= (rs1_eq_rd and ex_wb_src(0)) or (rs2_eq_rd and ex_wb_src(0) and (not is_imm));
	end process;
	
	
end behave;