library ieee;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity video_generator is 
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
	G_BUTTON_NORMAL_STATE: std_logic :='1';
    g_ACTIVE_ROWS : integer := 480
    );
	port(

		SW_INC	: in  std_logic:='1';
		SW_DEC	: in  std_logic:='1';
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
end entity;

architecture struct of video_generator is 
component clock_generator
	port(
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic;        -- outclk0.clk
		locked   : out std_logic         --  locked.export
		);
end component;

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

component timing_generator
    generic (
        G_RESET_ACTIVE_VALUE : std_logic := '0';
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
component stabilizer
 generic (
    G_RESET_ACTIVE_VALUE : std_logic := '0'
	);
	port(
		D_in  : in std_logic;
		RST   : in std_logic;
		CLK   : in std_logic;
		Q_out : out std_logic
		);
end component;
component data_generator
  generic (
    G_RESET_ACTIVE_VALUE : std_logic := '0';
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
    g_ACTIVE_ROWS : integer := 480
    );
  port (
    Clk     : in std_logic;
	RST 			: in  std_logic;
    H_CNT       : in integer range 0 to (C_PIXELS_PER_LINE-1);
    V_CNT       : in integer range 0 to (C_LINES_PER_FRAME-1);
	IMAGE_ENA     : in std_logic;
	NEXT_IMAGE     : in std_logic;
	ANIMATION_DIR    : in std_logic;
	SRAM_D         : in std_logic_vector(DATA_VALUE-1 downto 0);
    --
	DATA_ENA     : out std_logic;
	SRAM_A : out std_logic_vector(ADDRES_VALUE-1 downto 0);
    R_DATA : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    G_DATA : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    B_DATA : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0)
    );
end component;


signal hdmi_rst          : std_logic:='0';
signal clk_hdmi_sig          : std_logic:='0';
signal inc_speed_sig  : std_logic:='0';
signal dec_speed_sig  : std_logic:='0';
signal push_inc_speed_sig  : std_logic:='0';
signal push_dec_speed_sig  : std_logic:='0';
signal hsync_sig : std_logic:='0';
signal vsync_sig : std_logic:='0';
signal data_ena_sig : std_logic:='0';
signal next_img_sig : std_logic:='0';
signal H_CNT_sig   : integer range 0 to (C_PIXELS_PER_LINE-1);
signal V_CNT_sig   : integer range 0 to (C_LINES_PER_FRAME-1);
signal red:std_logic_vector(g_VIDEO_WIDTH-1 downto 0):="00000000";
signal green:std_logic_vector(g_VIDEO_WIDTH-1 downto 0):="00000000";
signal blue:std_logic_vector(g_VIDEO_WIDTH-1 downto 0):="00000000";
signal HDMI_TX_SIG:std_logic_vector(23 downto 0);
signal not_rst_sig: std_logic:='0';
signal SW_IMAGE_ENA_sig: std_logic:='0';
signal SW_ANIMATION_DIR_sig: std_logic:='0';
begin

U1: clock_generator
	PORT MAP(
			refclk  => Clk,
			RST   => 	not_rst_sig,
			outclk_0   =>clk_hdmi_sig,
			locked => hdmi_rst  
			);


U2:push_button_if--increasing speed
	generic map(		
		Time_press=> Time_press,
		long_press =>long_press,
		G_RESET_ACTIVE_VALUE=>G_RESET_ACTIVE_VALUE,
		G_BUTTON_NORMAL_STATE=>G_BUTTON_NORMAL_STATE
)
PORT MAP(
			CLK  => clk_hdmi_sig,
			RST   => hdmi_rst ,
			SW_IN   => inc_speed_sig,
			PRESS_OUT => push_inc_speed_sig
			);

U3: push_button_if----decreasing speed
	generic map(		
		Time_press=> Time_press,
		long_press =>long_press,
		G_RESET_ACTIVE_VALUE=>G_RESET_ACTIVE_VALUE,
		G_BUTTON_NORMAL_STATE=>G_BUTTON_NORMAL_STATE
)
	PORT MAP(
			CLK  => clk_hdmi_sig,
			RST   => hdmi_rst ,
			SW_IN   => dec_speed_sig,
			PRESS_OUT => push_dec_speed_sig
			);

U4: timing_generator
	generic map(		
	    G_RESET_ACTIVE_VALUE => G_RESET_ACTIVE_VALUE,
        C_PIXELS_PER_LINE  =>C_PIXELS_PER_LINE,
		C_LINES_PER_FRAME  =>C_LINES_PER_FRAME,
		MAX_RATE=>MAX_RATE,
		MIN_RATE=>MIN_RATE,
		DEF_rate=>DEF_rate
)
	PORT MAP(
        CLK  =>clk_hdmi_sig,
		RST   => hdmi_rst ,
		INC_SPEED=>push_inc_speed_sig, 
		DEC_SPEED=> push_dec_speed_sig,
        hsync=> hsync_sig,
		vsync=> vsync_sig,
        next_image=>next_img_sig,
        H_CNT=>H_CNT_sig,
        V_CNT=>V_CNT_sig
		);
	
U5: data_generator
	generic map(		
	G_RESET_ACTIVE_VALUE=>G_RESET_ACTIVE_VALUE, 
    C_PIXELS_PER_LINE =>C_PIXELS_PER_LINE,
	C_LINES_PER_FRAME=>C_LINES_PER_FRAME, 
    g_VIDEO_WIDTH=>g_VIDEO_WIDTH, 
	DATA_VALUE=>DATA_VALUE, 
	ADDRES_VALUE=>ADDRES_VALUE, 
    g_ACTIVE_COLS=>g_ACTIVE_COLS, 
	bar_size=>bar_size, 
	pic_start_h=>pic_start_h,
	pic_end_h=>pic_end_h,
	pic_start_v=>pic_start_v,
	pic_end_v=>pic_end_v,
	MAX_ADDRES=>MAX_ADDRES,
	MIN_ADDRES=>MIN_ADDRES,
	time_per_pixel=>time_per_pixel,
	PICTURE_AMAOUNT=>PICTURE_AMAOUNT, 
	PICTURE_size=>PICTURE_size,
    g_ACTIVE_ROWS=>g_ACTIVE_ROWS 
)
	PORT MAP(
    CLK  => clk_hdmi_sig,
	RST   => hdmi_rst ,
    H_CNT  =>H_CNT_sig,
    V_CNT  =>V_CNT_sig,
	IMAGE_ENA    =>SW_IMAGE_ENA_sig,
	NEXT_IMAGE     =>next_img_sig,
	ANIMATION_DIR    =>SW_ANIMATION_DIR_sig,
	SRAM_D    =>SRAM_D,
	DATA_ENA  =>data_ena_sig,
	SRAM_A =>SRAM_A,
    R_DATA =>red,
    G_DATA =>green,
    B_DATA =>blue
    );
	U6: stabilizer
	generic map(
	G_RESET_ACTIVE_VALUE=>G_RESET_ACTIVE_VALUE)
	port map(
	D_in=>SW_INC,
		RST=>hdmi_rst,
		CLK=>clk_hdmi_sig,
		Q_out=>inc_speed_sig
	);
	U7: stabilizer
		generic map(
	G_RESET_ACTIVE_VALUE=>G_RESET_ACTIVE_VALUE)
	port map(
	D_in=>SW_IMAGE_ENA,
		RST=>hdmi_rst, 
		CLK=>clk_hdmi_sig,
		Q_out=>SW_IMAGE_ENA_sig
	);
	U8: stabilizer
		generic map(
	G_RESET_ACTIVE_VALUE=>G_RESET_ACTIVE_VALUE)
	port map(
	D_in=>SW_DEC,
		RST=>hdmi_rst, 
		CLK=>clk_hdmi_sig,
		Q_out=>dec_speed_sig
	);
	U9: stabilizer
		generic map(
	G_RESET_ACTIVE_VALUE=>G_RESET_ACTIVE_VALUE)
	port map(
	D_in=>SW_ANIMATION_DIR,
		RST=>hdmi_rst, 
		CLK=>clk_hdmi_sig,
		Q_out=>SW_ANIMATION_DIR_sig
	);

	
	process(clk_hdmi_sig)
	begin
		if rising_edge(clk_hdmi_sig) then
			HDMI_TX_SIG<=red & green & blue;
		end if;
	end process;
	not_rst_sig<=not RSTn;
		HDMI_TX<=HDMI_TX_SIG;
		SRAM_CEn<='0';
		SRAM_OEn<='0';
		SRAM_WEn<='1';
		SRAM_UBn<='0';
		SRAM_LBn <='0';
		HDMI_TX_HS<=hsync_sig;
		HDMI_TX_VS <=vsync_sig;
		HDMI_TX_CLK<=clk_hdmi_sig;
		HDMI_TX_DE<=data_ena_sig;
end architecture;