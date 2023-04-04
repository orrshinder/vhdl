library ieee;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

 
entity push_button_if_tb is
end push_button_if_tb;

architecture behavior of push_button_if_tb is
constant clock_period	: time := 40 ns;
constant G_BUTTON_NORMAL_STATE: std_logic :='0';
component push_button_if
generic(Time_press : integer := 50000000;
		long_press : integer := 6250000;
		G_RESET_ACTIVE_VALUE: std_logic :='0';
		G_BUTTON_NORMAL_STATE: std_logic :='0'
		);
	port(
		 CLK   : in std_logic;
		 RST   : in std_logic;
		 SW_IN   : in std_logic;
		 PRESS_OUT  : out std_logic
		);
end component;

--signal sclk : std_logic;
signal SRST     : std_logic;
signal SSW_IN      : std_logic;
signal SPRESS_OUT    : std_logic := '0';
signal CLK_SIG  : std_logic := '0';
signal ST       : std_logic:='0'; 
signal scounter:integer  range 0 to 50000000;
signal state_sit1: std_logic_vector (1 downto 0);
begin
process
begin
	CLK_SIG <= '1';
	wait for clock_period / 2;
	CLK_SIG <= '0';
	wait for clock_period / 2;
end process;

uut: push_button_if
	port map(
			CLK => CLK_SIG,
			RST => SRST,
			SW_IN  => SSW_IN,
			PRESS_OUT => SPRESS_OUT
			);
			
ST <= SSW_IN and not(G_BUTTON_NORMAL_STATE);
--st<= "11" after 0 ns , "10" after 100 ns , "00" after 200 ns , "11" after 300 ns;
SRST <= '1' after 0 sec, '0' after 50 ms;
SSW_IN <= '1' after  500 ms, '0' after 800 ms, '1' after 1 sec, '0' after 1100 ms,'1' after 2 sec,'0' after 6 sec ;

end;
