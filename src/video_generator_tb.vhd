library ieee;
use ieee.std_logic_1164.all;


entity video_generator_tb is
end entity;


architecture sim of video_generator_tb is

constant clock_period	: time := 40 ns;
constant white_value	: std_logic_vector := "111111111111111111111111";
    component video_generator
generic(G_RESET_ACTIVE_VALUE : std_logic := '0';
    C_PIXELS_PER_LINE  : natural := 800;
	C_LINES_PER_FRAME  : natural := 525;
    g_VIDEO_WIDTH : integer := 8;
	DATA_VALUE : integer := 16;
	ADDRES_VALUE : integer := 18;
    g_ACTIVE_COLS : integer := 640;
	bar_size : integer := 80;
	pic_start_h: integer := 261;
	pic_end_h: integer := 379;
	pic_start_v: integer := 150;
	pic_end_v: integer := 330;
	MAX_ADDRES: std_logic_vector := "111111111111111111";
	MIN_ADDRES: std_logic_vector := "000000000000000000";
	time_per_pixel : integer := 2;
	PICTURE_AMAOUNT : integer := 24;
	PICTURE_size : integer := 10620;
	Time_press : integer := 50000000;
	MAX_RATE:integer :=1;
	MIN_RATE:integer :=200;
	DEF_rate:integer:=20;
	long_press : integer := 6250000;
	G_BUTTON_NORMAL_STATE: std_logic :='0';
    g_ACTIVE_ROWS : integer := 480
    );
	port(

		SW_INC	: in  std_logic;
		SW_DEC	: in  std_logic;
		SW_ANIMATION_DIR	: in  std_logic;
		SW_IMAGE_ENA	: in  std_logic;
		CLK		    : in  std_logic;
		RSTn		: in  std_logic;
		SRAM_D	: in std_logic_vector(DATA_VALUE-1 downto 0);
		
		SRAM_A	: out std_logic_vector(ADDRES_VALUE-1 downto 0);
		HDMI_TX 	: out std_logic_vector(23 downto 0);
		SRAM_CEn		: out  std_logic;
		SRAM_OEn 		: out  std_logic;
		SRAM_WEn		: out  std_logic;
		SRAM_UBn		: out  std_logic;
		SRAM_LBn 		: out  std_logic;
		HDMI_TX_DE		: out  std_logic;
		HDMI_TX_HS 		: out  std_logic;
		HDMI_TX_VS 		: out  std_logic;
		HDMI_TX_CLK 		: out  std_logic
		);
end component;
signal sram_a :std_logic_vector(17 downto 0):="000000000000000000";
signal video_tb :std_logic_vector(23 downto 0);
signal sram_d :std_logic_vector(15 downto 0):="0000000000000000";
signal sram_wen :std_logic:='1'; 
signal sram_oen :std_logic:='0'; 
signal sram_ubn :std_logic:='0'; 
signal sram_cen :std_logic:='0';  
signal sram_lbn :std_logic:='0'; 
signal test_sig :std_logic:='0';
signal HDMI_TX_DE_1 :std_logic; 
signal HDMI_TX_HS_1 :std_logic; 
signal HDMI_TX_VS_1 :std_logic; 
signal HDMI_TX_CLK_1 :std_logic:='0'; 
 signal CLK_SIG  : std_logic := '0'; 
 signal adrres_pointer_1: integer range 0 to (24*10620):=0;

begin
process
begin
	CLK_SIG <= '1';
	wait for clock_period/2 ;
	CLK_SIG <= '0';
	wait for clock_period/2 ;
end process;


    
    sram_inst: entity work.sim_sram
    generic map ( 
        ini_file_name       => "test.bin"
    )
    port map (
        SRAM_ADDR           => sram_a,
        SRAM_DQ             => sram_d,
        SRAM_WE_N           => sram_wen,
        SRAM_OE_N           => sram_oen,
        SRAM_UB_N           => sram_ubn, 
        SRAM_LB_N           => sram_lbn,
        SRAM_CE_N           => sram_cen
    );
  uut: video_generator
	port map(
		SW_INC=>'1',
		SW_DEC=>'0',
		SW_ANIMATION_DIR=>'0',
		SW_IMAGE_ENA=>'1',
		CLK	=>CLK_SIG,
		RSTn=>'1',
		SRAM_D=>sram_d,
		
		SRAM_A	=>sram_a,
		HDMI_TX =>video_tb,
		SRAM_CEn=>sram_cen,
		SRAM_OEn =>sram_oen,
		SRAM_WEn=>sram_wen,
		SRAM_UBn=>sram_ubn,
		SRAM_LBn =>sram_lbn,
		HDMI_TX_DE	=>HDMI_TX_DE_1,
		HDMI_TX_HS 	=>HDMI_TX_HS_1,
		HDMI_TX_VS =>HDMI_TX_VS_1,
		HDMI_TX_CLK =>HDMI_TX_CLK_1
			);
    



end sim;

    
    