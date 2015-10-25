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
	port(clk, we, nreset 	: in std_logic;
	PC_out 				: out std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_in				: in std_logic_vector(PC_WIDTH - 1 downto 0)	
	);
end PC;

--}} End of automatically maintained section

architecture behave of PC is 
signal PC : std_logic_vector(PC_WIDTH - 1 downto 0);
begin

PC_out <= PC;
	
seq : process(clk, we, nreset)
begin
	if(clk'event and clk = '1') then
		if(nreset = '0') then
			PC <= std_logic_vector(to_unsigned(512,PC_WIDTH));
		elsif(we = '1') then
			PC <= PC_in;
		end if;
	end if;
end process;

end behave;
