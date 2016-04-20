library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

library work;
use work.constants.all;


entity soc_top is
	port(
	clk       : in std_logic;
	nreset    : in std_logic;
	--testbench
	pass      : out std_logic;
	fail      : out std_logic;
	--spi--
	sclk      : out std_logic;
	miso      : in  std_logic;
	mosi      : out std_logic;
	cs1       : out std_logic;
	cs2       : out std_logic;
	cs3       : out std_logic;
	cs4       : out std_logic
	);
end entity;




architecture behave of soc_top is 
--test interface
signal pass_i, pass_i_reg : std_logic;
signal fail_i, fail_i_reg : std_logic;

--SPI and startup
signal spi_settings     :  std_logic;
signal spi_data_in      :  std_logic_vector(31 downto 0);
signal spi_data_out     :  std_logic_vector(31 downto 0);
	
signal spi_busy         :  std_logic;
signal spi_finished     :  std_logic;
signal spi_clear        :  std_logic;
signal spi_start        :  std_logic;

signal startup_data_mem : std_logic_vector(31 downto 0);	
signal startup_address  : std_logic_vector(DATA_MEM_WIDTH - 3 downto 0);
signal startup_we		: std_logic;
signal startup_done		: std_logic;

signal d_clk            : std_logic; 
signal clk_reset, 
reset_last   : std_logic;
signal sync_reset : std_logic;
--memory
signal instr_we         : std_logic;
signal instr_data_w		: std_logic_vector(31 downto 0);
signal instr_data_r		: std_logic_vector(31 downto 0);
signal instr_addr		: std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
signal instr_re         : std_logic;

signal data_we          : std_logic; 
signal data_mem_we      : std_logic;
signal data_data_w		: std_logic_vector(31 downto 0);
signal data_data_r		: std_logic_vector(31 downto 0);
signal data_addr        : std_logic_vector(SPI_AND_DATA_MEM_WIDTH - 1 downto 0);
signal data_be          : std_logic_vector(1 downto 0);
signal data_re          : std_logic; 

signal data_mem_data_r  : std_logic_vector(31 downto 0); 
signal data_mem_re      : std_logic;
signal data_busy        : std_logic;


signal startup_instr_addr : std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
signal startup_data_addr  : std_logic_vector(SPI_AND_DATA_MEM_WIDTH - 1 downto 0);
signal startup_instr_we   : std_logic;
signal startup_data_we    : std_logic;

signal startup_spi_data_in  : std_logic_vector(31 downto 0);
signal startup_spi_data_out : std_logic_vector(31 downto 0);
signal startup_spi_finished : std_logic;
signal startup_spi_start    : std_logic;
signal startup_spi_clear    : std_logic;
signal startup_spi_settings : std_logic;

signal cpu_instr_we         : std_logic;
signal cpu_instr_data_w		: std_logic_vector(31 downto 0);
signal cpu_instr_data_r		: std_logic_vector(31 downto 0);
signal cpu_instr_addr		: std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
signal cpu_instr_re         : std_logic;

signal cpu_data_we          : std_logic;
signal cpu_data_data_w		: std_logic_vector(31 downto 0);
signal cpu_data_addr        : std_logic_vector(SPI_AND_DATA_MEM_WIDTH - 1 downto 0);
signal cpu_data_be          : std_logic_vector(1 downto 0);
signal cpu_data_re          : std_logic;

signal cpu_spi_data_in  : std_logic_vector(31 downto 0);
signal cpu_spi_data_out : std_logic_vector(31 downto 0);
signal cpu_spi_finished : std_logic;
signal cpu_spi_start    : std_logic;
signal cpu_spi_clear    : std_logic;
signal cpu_spi_settings : std_logic;

signal data_to_spi : std_logic_vector(31 downto 0);

signal spi_out, spi_status, spi_out_regs : std_logic_vector(31 downto 0);


signal mem_or_spi, mem_or_spi_reg        : std_logic;

--CPU
signal cpu_sleep : std_logic;

begin
pass <= pass_i_reg;
fail <= fail_i_reg;
	
cpu_sleep <= (not startup_done) or (pass_i_reg or fail_i_reg);
	
	
clk_reset <= not (reset_last and not nreset);

	
clk_reset_process : process(clk)
begin	
	if(clk'event and clk = '1') then
		reset_last <= nreset;	
	end if;
end process;


sync_reset_process : process(d_clk)
begin
	if(d_clk'event and d_clk = '1') then
		sync_reset <= nreset;	
	end if;
end process; 

test_process : process(d_clk)
begin
	if(d_clk'event and d_clk = '1') then
		if(nreset = '0') then
			pass_i_reg <= '0';
			fail_i_reg <= '0';
		else
			pass_i_reg <= pass_i;
			fail_i_reg <= fail_i;
		end if;
	end if;	
end process;

startup_instr_addr <= startup_address(DATA_MEM_WIDTH - 3 downto 0) & "00";
startup_data_addr  <= '0' & startup_address(DATA_MEM_WIDTH - 3 downto 0) & "00";

cpu_spi_data_in <= cpu_data_data_w;
startup_spi_finished <= spi_finished;
startup_spi_data_out <= spi_data_out;
cpu_spi_data_out <= spi_data_out;

memory_control_selector : process(startup_done, startup_instr_addr, 
startup_data_addr, startup_instr_we, startup_data_we, startup_data_mem, 
startup_data_mem, cpu_instr_addr, cpu_data_addr, cpu_instr_we,
cpu_data_we, cpu_data_be, cpu_instr_data_w, cpu_data_re, cpu_instr_re, 
cpu_data_data_w, startup_spi_data_in, startup_spi_start, startup_spi_clear, 
startup_spi_settings, cpu_spi_data_in , cpu_spi_start, cpu_spi_clear, cpu_spi_settings)
begin
	case (startup_done) is
		when '0' =>
			instr_addr    <= startup_instr_addr;
			data_addr     <= startup_data_addr;
			instr_we      <= startup_instr_we;
			data_we       <= startup_data_we;
			data_be       <= "10";
			instr_data_w  <= startup_data_mem;
			data_data_w   <= startup_data_mem;
			data_re       <= '0';
			instr_re      <= '0';
			data_to_spi   <= startup_spi_data_in;
			spi_start     <= startup_spi_start;
			spi_clear     <= startup_spi_clear;
			spi_settings  <= startup_spi_settings;
		when '1' =>
			instr_addr    <= cpu_instr_addr;
			data_addr     <= cpu_data_addr;
			instr_we      <= cpu_instr_we;
			data_we       <= cpu_data_we;
			data_be       <= cpu_data_be;
			instr_data_w  <= cpu_instr_data_w;
			data_data_w   <= cpu_data_data_w;
			data_re       <= cpu_data_re;
			instr_re      <= cpu_instr_re;
			data_to_spi   <= cpu_spi_data_in;
			spi_start     <= cpu_spi_start;
			spi_clear     <= cpu_spi_clear;
			spi_settings  <= cpu_spi_settings;
		when others =>
			NULL;
	end case;
end process;

memory_map : process(data_addr)
begin
	if(data_addr(SPI_AND_DATA_MEM_WIDTH - 1 downto 2) = SPI_MEMORY_MAP) then
		mem_or_spi <= SPI_MAP;	
	else
		mem_or_spi <= MEM_MAP;
	end if;
end process;

spi_status_regs : process(d_clk)
begin
	if(d_clk'event and d_clk = '1') then
		spi_out_regs <= spi_out;
		mem_or_spi_reg <= mem_or_spi;
	end if;
end process;


spi_mem_map_decode : process(mem_or_spi, data_addr, data_re, data_we, spi_data_out, data_mem_data_r, spi_busy, spi_out, mem_or_spi_reg)

begin
	case (mem_or_spi) is
		when SPI_MAP =>
			data_mem_we     <= '0';
			data_mem_re     <= '0';	
			
			data_busy       <= spi_busy;
		when MEM_MAP =>
			data_mem_we     <= data_we;
			data_mem_re     <= data_re;
				 
			data_busy       <= '0';
		when others =>
			null;
	end case;
	
	case (mem_or_spi_reg) is
		when SPI_MAP =>
			data_data_r     <= spi_out_regs;
		when MEM_MAP =>
			data_data_r     <= data_mem_data_r;
		when others =>
			null;
	end case;
	
	cpu_spi_settings <= '0';
	cpu_spi_start    <= '0';
	cpu_spi_clear    <= '0';
	spi_out <= spi_data_out;
	
	case (data_addr(1 downto 0)) is
		when "00" =>
		  spi_out <= x"0000000" & "00" &  spi_finished & spi_busy; 	--address: FFC
		when SPI_settings_OP =>
		  cpu_spi_settings  <= mem_or_spi and data_we;              --address: FFD
		when SPI_START_OP    =>
		  cpu_spi_start     <= mem_or_spi and data_we;              --address: FFE
		when SPI_clear_OP    =>
		  cpu_spi_clear     <= mem_or_spi and data_we;              --address: FFF
		when others => NULL;
	end case;	
end process;   


--spi_control_selector : process(startup_done)
--begin
--	case (startup_done) is
--		when '0' =>
--		
--		when '1' =>
--		
--		when others =>
--			NULL;
--	end case;
--		
--end process;

	
spi_controller : entity work.SPI_controller port map(
	clk        => d_clk,
	nreset     => sync_reset,
	request    => spi_settings,
	data_in    => data_to_spi,
	data_out   => spi_data_out,
	
	busy       => spi_busy,
	finished   => spi_finished,
	clear      => spi_clear,
	start      => spi_start,

	--SPI interface
	miso       => miso,
	mosi       => mosi,
	sclk       => sclk,
	cs1        => cs1,
	cs2        => cs2,
	cs3        => cs3,
	cs4        => cs4
);

startup_controller : entity work.spi_startup port map(
	clk        => d_clk,
	nreset     => sync_reset,
	
	--SPI controller interface--
	data_to_spi => startup_spi_data_in,
	data_from_spi => startup_spi_data_out,
	spi_finished => startup_spi_finished,
	spi_start => startup_spi_start,
	spi_clear => startup_spi_clear,
	spi_settings => startup_spi_settings,
	
	
	--Memory interface--
	data_mem => startup_data_mem,
	address  => startup_address,
	instr_we => startup_instr_we,	
	data_we  => startup_data_we,
	
	done     => startup_done
	
);


clock_divider : entity work.clock_divider_cnt generic map(
	division => 4
	)	
	port map(
	clk => clk,
	nreset => clk_reset,
	d_clk => d_clk	
	);

instruction_memory : entity work.SP_32bit generic map(
	address_width => INSTRUCTION_MEM_WIDTH)
port map(
	clk => d_clk,
	we	=> instr_we,
	address  =>  instr_addr,
	data_in  => instr_data_w,
	data_out => instr_data_r
);

data_memory : entity work.bram generic map(
	address_width => DATA_MEM_WIDTH)
port map(
	clk => d_clk,
	byte_enable => data_be,
	address => data_addr(DATA_MEM_WIDTH - 1 downto 0),
	we => data_mem_we,
	write_data => data_data_w,
	read_data => data_mem_data_r
);	


AAsmund_RISC : entity work.top	port map
	(
	clk => d_clk,
	nreset => sync_reset,
	
	sleep => cpu_sleep,
	
	--test interface
	pass  => pass_i,
	fail  => fail_i,

	--data memory interface
	data_memory_address      => cpu_data_addr,
	data_memory_read_data    =>	data_data_r, 
	data_memory_be           =>	cpu_data_be,
	data_memory_write_data   => cpu_data_data_w,
	data_memory_write_enable => cpu_data_we,
	data_memory_read_enable => cpu_data_re,
	
	--instruction memory interface
	inst_memory_address => cpu_instr_addr,
	inst_memory_read_data => instr_data_r,
	inst_memory_write_enable => cpu_instr_we
	);

cpu_instr_data_w <= x"00000000";

cpu_instr_re <= '1'; --TODO: Implement read enable signal
end behave;