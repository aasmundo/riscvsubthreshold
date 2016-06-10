library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;

entity top_pg_wrap is
	port(
	clk                : in  std_logic;
	nreset             : in  std_logic;
	
	sleep              : in  std_logic;
	
	--test interface
	pass        	   : out std_logic;
	fail               : out std_logic;

	--data memory interface
	data_memory_address : out std_logic_vector(SPI_AND_DATA_MEM_WIDTH - 1 downto 0);
	data_memory_read_data : in std_logic_vector(31 downto 0);
	data_memory_be        : out std_logic_vector(1 downto 0);
	data_memory_write_data : out std_logic_vector(31 downto 0);
	data_memory_write_enable : out std_logic;  
	data_memory_read_enable : out std_logic;
	
	--instruction memory interface
	inst_memory_address : out std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
	inst_memory_read_data : in std_logic_vector(31 downto 0);
	inst_memory_write_enable : out std_logic
	);
end top_pg_wrap;


architecture behave of top_pg_wrap is
signal pwr_en, n_pwr_en, cpu_sleep : std_logic;
type state_t is (ENABLE, ENABLE_TO_DISABLE, DISABLE, DISABLE_TO_ENABLE);
signal state, n_state : state_t;		  

--pragma synthesis_off
signal pwr_en_cnt : integer := 0;
signal pwr_en_not_cnt : integer := 0; 

signal save_state_1_cnt : integer := 0;
signal save_state_2_cnt : integer := 0;
signal first_sleep_clk_cnt : integer := 0;
signal second_sleep_clk_cnt : integer := 0;
signal deep_sleep_cnt : integer := 0;
signal wake_up_cnt : integer := 0;
signal first_after_wake_up_cnt : integer := 0; 
signal awake_cnt : integer := 0;   
signal monitor_state : integer := 0;
--pragma synthesis_on

--isolation cells
signal pass_iso        	              : std_logic;
signal fail_iso                       : std_logic;

signal data_memory_address_iso        : std_logic_vector(SPI_AND_DATA_MEM_WIDTH - 1 downto 0);
signal data_memory_be_iso             : std_logic_vector(1 downto 0);
signal data_memory_write_data_iso     : std_logic_vector(31 downto 0);
signal data_memory_write_enable_iso   : std_logic;  
signal data_memory_read_enable_iso    : std_logic;

signal inst_memory_address_iso        : std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
signal inst_memory_write_enable_iso   : std_logic;
begin

	AAsmund_RISC_inst : entity work.top	port map
		(
		clk => clk,
		nreset => nreset,
		pwr_en => pwr_en,
		
		sleep => cpu_sleep,
		
		--test interface
		pass  => pass_iso,
		fail  => fail_iso,
		
		--data memory interface
		data_memory_address      => data_memory_address_iso,
		data_memory_read_data    =>	data_memory_read_data, 
		data_memory_be           =>	data_memory_be_iso,
		data_memory_write_data   => data_memory_write_data_iso,
		data_memory_write_enable => data_memory_write_enable_iso,
		data_memory_read_enable  => data_memory_read_enable_iso,
		
		--instruction memory interface
		inst_memory_address      => inst_memory_address_iso,
		inst_memory_read_data    => inst_memory_read_data,
		inst_memory_write_enable => inst_memory_write_enable_iso
		);


pass                     <= pass_iso when pwr_en = '1' else '0';
fail                     <= fail_iso when pwr_en = '1' else '0';

data_memory_address  <=  data_memory_address_iso when pwr_en = '1' else (others => '0');  
data_memory_be        <=  data_memory_be_iso when pwr_en = '1' else (others => '0');   
data_memory_write_data <=  data_memory_write_data_iso when pwr_en = '1' else (others => '0'); 
data_memory_write_enable <=  data_memory_write_enable_iso when pwr_en = '1' else '0'; 
data_memory_read_enable <=  data_memory_read_enable_iso when pwr_en = '1' else '0';

--instruction memory interface
inst_memory_address  <=  inst_memory_address_iso when pwr_en = '1' else (others => '0');   
inst_memory_write_enable <=  inst_memory_write_enable_iso when pwr_en = '1' else '0';
process(state, sleep)
begin
	cpu_sleep <= '0';
	n_pwr_en <= '1';
	n_state <= state;
	case(state) is
		when ENABLE =>
			cpu_sleep <= sleep;
			if(sleep = '1') then
				n_state <= ENABLE_TO_DISABLE;
			end if;
		when ENABLE_TO_DISABLE =>
			cpu_sleep <= sleep;
			if(sleep = '1') then
				n_state <= DISABLE;
			else
				n_state <= ENABLE;
			end if;
		when DISABLE =>
			cpu_sleep <= '1';
			if(sleep = '0') then
				n_state <= DISABLE_TO_ENABLE;
			else
				n_pwr_en <= '0';
			end if;
		when DISABLE_TO_ENABLE =>
			n_state <= ENABLE;
			cpu_sleep <= '1';
		when others =>
			null;
	end case;
			
end process;

process(clk)
begin
	if(clk'event and clk = '1') then
		if(nreset = '0') then
			state <= ENABLE;
			pwr_en <= '1';
		else
			state <= n_state;
			pwr_en <= n_pwr_en;
		end if;		
	end if;
end process;

--pragma synthesis_off
process(clk)
begin
	if(clk'event and clk = '1') then
		if(nreset = '0') then
			pwr_en_not_cnt <= 0;
			pwr_en_cnt <= 0;
			save_state_1_cnt <= 0;
			save_state_2_cnt <= 0;
			first_sleep_clk_cnt<= 0;
			second_sleep_clk_cnt <= 0;
			deep_sleep_cnt <= 0;
			wake_up_cnt <= 0;
			first_after_wake_up_cnt <= 0;
			awake_cnt <= 0; 
			monitor_state <= 0;
		else
			if(pwr_en = '0') then
				pwr_en_not_cnt <= pwr_en_not_cnt + 1;
			else
				pwr_en_cnt     <= pwr_en_cnt + 1;
			end if;	 
			if(state = ENABLE and sleep = '0') then
				awake_cnt <= awake_cnt + 1;
				monitor_state <= 0;
			elsif(state = ENABLE and sleep = '1') then
				save_state_1_cnt <= save_state_1_cnt + 1;
			elsif(state = ENABLE_TO_DISABLE) then
				save_state_2_cnt <= save_state_2_cnt + 1;
			elsif(state = DISABLE) then
				if(sleep = '1') then
					if(monitor_state = 0) then
						first_sleep_clk_cnt <= first_sleep_clk_cnt + 1;
					elsif(monitor_state = 1) then
						second_sleep_clk_cnt <= second_sleep_clk_cnt + 1;
					else
						deep_sleep_cnt <= deep_sleep_cnt + 1;
					end if;
				else
					awake_cnt <= awake_cnt + 1;
				end if;
				monitor_state <= monitor_state + 1;
			elsif(state = DISABLE_TO_ENABLE) then
				if(monitor_state > 1) then
					wake_up_cnt <= wake_up_cnt + 1;
				else
					awake_cnt <= awake_cnt + 1;
				end if;
			end if;
		end if;		
	end if;
end process;

--pragma synthesis_on


end behave;
