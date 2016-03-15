library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity SPI_controller is
port(
	clk        : in  std_logic;
	nreset     : in  std_logic;
	request    : in  std_logic;
	data_in    : in  std_logic_vector(31 downto 0);
	data_out   : out std_logic_vector(31 downto 0);
	
	busy       : out std_logic;
	finished   : out std_logic;
	clear      : in  std_logic;
	start      : in  std_logic;

	--SPI interface--
	miso       : in  std_logic;
	mosi       : out std_logic;
	sclk       : out std_logic;
	cs1        : out std_logic;    
	cs2		   : out std_logic;
	cs3		   : out std_logic;
	cs4		   : out std_logic

);
end SPI_controller;

architecture behave of SPI_controller is
type state_t is (IDLE_s, START_s, BUSY_s, FIN_s);
signal state, n_state : state_t;
signal start_byte, n_start_byte, byte_complete, write_byte, write_word, write_settings : std_logic; 
signal message : std_logic_vector(31 downto 0);
signal master_data, slave_data : std_logic_vector(7 downto 0);
signal msg_cnt, n_msg_cnt : unsigned(1 downto 0);
signal settings          : std_logic_vector(4 downto 0); 
-------------------------------------------------------
-- Settings register:
-- bit | function
-- 0,1 | message length  
--  2  | ignore response
-- 3,4 | chip select address  
--
-------------------------------------------------------
signal cs_addr   : std_logic_vector(1 downto 0);
signal cs_demux  : std_logic_vector(3 downto 0);
signal assert_cs : std_logic;

begin

master_data <= message(31 downto 24);
data_out <= message;
cs_addr <= settings(4 downto 3);
cs1 <= not (assert_cs and cs_demux(0));
cs2 <= not (assert_cs and cs_demux(1));
cs3 <= not (assert_cs and cs_demux(2));
cs4 <= not (assert_cs and cs_demux(3));


chip_select : process(cs_addr)
begin
	case(cs_addr) is
		when "00" => 
			cs_demux <= "0001";
		when "01" => 
			cs_demux <= "0010";
		when "10" => 
			cs_demux <= "0100";
		when "11" => 
			cs_demux <= "1000";
		when others =>
			NULL;
	end case;
		
end process;

combi : process(state, start, msg_cnt, byte_complete, settings, request, clear)

begin
	busy <= '0';
	start_byte <= '0';
	start_byte <= '0';
	n_msg_cnt <= msg_cnt;
	n_state <= state;
	finished <= '0';
	write_word <= '0';
	write_byte <= '0';
	write_settings <= '0';
	assert_cs <= '0';
	case (state) is
		when IDLE_s =>
			if(start = '1') then
				n_state <= START_s;
				write_word <= '1';
			else
				busy    <= '0';
				if(request = '1') then
					write_settings <= '1';
				end if;
			end if;
			n_msg_cnt <= "00";	
		when START_s =>
			assert_cs <= '1';
			start_byte <= '1';
			n_state <= BUSY_s;
			busy <= '1';
			n_msg_cnt <= msg_cnt + 1;
		when BUSY_s =>
			assert_cs <= '1';
			busy <= '1';
			if(byte_complete = '1') then
				if(msg_cnt = unsigned(settings(1 downto 0)) + 1) then
					n_state <= FIN_s;
				else 
					n_state <= START_s;
				end if;
				write_byte <= '1';
			end if;
		when FIN_s =>
			busy <= '1';
			finished <= '1';
			assert_cs <= '1';
			if(clear = '1' or settings(2) = '1') then
				n_state <= IDLE_s;
			elsif(start = '1') then
				n_state <= START_s;
			end if;
		when others =>
			NULL;
	end case;
		

end process;


seq : process(clk)
begin
	if(clk'event and clk = '1') then
		if(nreset = '0') then
			state   <= IDLE_s;
			settings <= "00000";
			msg_cnt <= "00";
		else
			msg_cnt <= n_msg_cnt;
			state <= n_state;
			if(write_byte = '1') then
				message <= message(23 downto 0) & slave_data;
			elsif(write_settings = '1') then 
				settings <= data_in(4 downto 0);
			elsif(write_word = '1') then 
				message <= data_in;
			end if;
		end if;
	end if;

end process;

SPI_top : entity work.SPI_top3 port map(
clk => clk,
data_in => master_data,
data_out => slave_data,
miso => miso,
mosi => mosi,
nreset => nreset,
start => start_byte,
sclk => sclk,
byte_complete => byte_complete
);


end behave;
