-------------------------------------------------------------------------------
--
-- Title       : MUX
-- Design      : multi cycle design
-- Author      : Ole Brumm
-- Company     : Hundremeterskogen Dataservice
--
-------------------------------------------------------------------------------
--
-- File        : MUX.vhd
-- Generated   : Mon Sep 29 16:15:38 2014
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
--{entity {MUX} architecture {MUX}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUX2_32_bit is
	 port(
		 a, b : in STD_LOGIC_VECTOR (31 downto 0) ;
		 sel : in STD_LOGIC;
		 output : out STD_LOGIC_VECTOR (31 downto 0)
	     );
end MUX2_32_bit;

--}} End of automatically maintained section

architecture MUX2_32_bit of MUX2_32_bit is
begin

process(a, b, sel)
begin
	if sel = '0' then
		output <= a;
	else
		output <= b;		 
	end if;
end process;
	

end MUX2_32_bit;
