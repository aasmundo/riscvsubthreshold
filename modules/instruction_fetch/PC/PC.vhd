-------------------------------------------------------------------------------
--
-- Title       : PC
-- Design      : commando8
-- Author      : Oma
-- Company     : Vandelay industries
--
-------------------------------------------------------------------------------
--
-- File        : PC.vhd
-- Generated   : Tue Oct 21 18:02:48 2014
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.20
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {PC} architecture {behave}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library work;
use work.constants.all;

entity PC is
	port(clk, we, nreset, pwr_en 	: in std_logic;
	PC_out 				: out std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_next             : out std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_in				: in std_logic_vector(PC_WIDTH - 1 downto 0)	
	);
end PC;

--}} End of automatically maintained section

architecture behave of PC is 
signal PC : std_logic_vector(PC_WIDTH - 1 downto 0);
signal PC_in_with_nreset	: std_logic_vector(PC_WIDTH - 1 downto 0);
signal we_with_nreset       : std_logic;
begin

	
PC_regs : entity work.PC_reg port map(
	clk => clk,
	we => we,
	pwr_en => pwr_en,
	PC_in => PC_in_with_nreset,
	PC_out => PC
	);
PC_out <= PC;	

PC_in_with_nreset <= PC_in when nreset = '1' else std_logic_vector(to_unsigned(512,PC_WIDTH));
we_with_nreset <= we when nreset = '1' else '1';
combi : process(PC_in, PC, we)
begin
	case(we) is
		when '1' =>
			PC_next <= PC_in;
		when '0' =>
			PC_next <= PC;
		when others =>
			null;
	end case;

end process;

--assert (PC(1) /= '0' or PC(0) /= '0') report "PC not aligned" severity failure;
--assert (PC < x"800") report "PC more than 0x800" severity failure;

end behave;
