library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity activity_control is
	port(	
	clk                    : in  std_logic;
	pwr_en                 : in  std_logic;
	
	sleep,
	stall_ID,  
	nreset,
	control_transfer_MEM   : in  std_logic;
	
	init_sleep,
	counter_enable,		   
	stall_IF,
	stall,
	flush_IFID,
	flush_IDEX,
	flush_EXMEM,
	flush_MEMWB		   : out std_logic
	
	);
end activity_control;


architecture behave of activity_control is
signal stall_i : std_logic;
signal sleeping	: std_logic;
signal sleep_with_nreset : std_logic;
begin
	counter_enable <= not sleep;	
	stall_i <= (sleeping or stall_ID) and nreset;
	stall_IF <= stall_i and not control_transfer_MEM;
	flush_IFID <= control_transfer_MEM or sleep or not nreset;
	flush_IDEX <= control_transfer_MEM or sleep or stall_i or not nreset;
	flush_EXMEM <= control_transfer_MEM or sleep or not nreset;
	flush_MEMWB <= not nreset or (sleep and sleeping);
	init_sleep <= sleep and (not sleeping);
	stall <= stall_i;
	
	sleep_with_nreset <= sleep when nreset = '1' else '0';
	
	sleep_reg : entity work.sleep_reg_pg_wrap port map(
		clk => clk,
		pwr_en => pwr_en,
		d => sleep_with_nreset,
		q => sleeping
		);

end behave;