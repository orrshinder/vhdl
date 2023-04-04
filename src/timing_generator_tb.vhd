library ieee;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

 
entity timing_generator_tb is
end timing_generator_tb;

architecture behavior of timing_generator_tb is

constant clock_period	: time := 40 ns;
constant C_PIXELS_PER_LINE  : natural := 800;
constant C_LINES_PER_FRAME  : natural := 525;
component timing_generator
generic(   G_RESET_ACTIVE_VALUE : std_logic := '0';
        C_PIXELS_PER_LINE  : natural := 800;
		C_LINES_PER_FRAME  : natural := 525;
		MAX_RATE:integer :=1;
		MIN_RATE:integer :=200;
		DEF_rate:integer:=20
		);
	port(
		clk           : in  std_logic;
		RST 			: in  std_logic;
		INC_SPEED		:in std_logic; 
		DEC_SPEED		:in std_logic;
        hsync, vsync  : out std_logic;
        next_image  : out std_logic;
        H_CNT       : out integer range 0 to (C_PIXELS_PER_LINE-1);
        V_CNT       : out integer range 0 to (C_LINES_PER_FRAME-1)
		);
end component;

--signal sclk : std_logic;
signal SRST     : std_logic:= '0';
signal SINC_SPEED      : std_logic:= '0';
signal SDEC_SPEED     : std_logic:= '0';
signal Shsync    : std_logic := '0';
signal Svsync    : std_logic := '0';
signal Snext_image    : std_logic := '0';
signal CLK_SIG  : std_logic := '0';
signal SH_CNT       :integer range 0 to (C_PIXELS_PER_LINE-1):=0;
signal SV_CNT      :integer range 0 to (C_PIXELS_PER_LINE-1):=0;

begin
process
begin
	CLK_SIG <= '1';
	wait for clock_period / 2;
	CLK_SIG <= '0';
	wait for clock_period / 2;
end process;

uut: timing_generator
	port map(
			CLK => CLK_SIG,
			RST => SRST,
			INC_SPEED  => SINC_SPEED,
			DEC_SPEED => SDEC_SPEED,
			next_image=>Snext_image,
			H_CNT=>SH_CNT,
			V_CNT=>SV_CNT,
			vsync=>Svsync,
			hsync=>Shsync
			);
			

--st<= "11" after 0 ns , "10" after 100 ns , "00" after 200 ns , "11" after 300 ns;
SRST <= '0' after 0 sec, '1' after 50 ms;
SINC_SPEED <= '1' after  500 ms, '0' after 501 ms, '1' after 1 sec, '0' after 1001 ms,'1' after 2 sec,'0' after 2001 ms ;

end;