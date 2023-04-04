library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timing_generator is
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
        hsync	: out std_logic;
		vsync  : out std_logic;
        next_image  : out std_logic;
        H_CNT       : out integer range 0 to (C_PIXELS_PER_LINE-1);
        V_CNT       : out integer range 0 to (C_LINES_PER_FRAME-1)
    );
end timing_generator;

architecture rtl of timing_generator is

    type video_timing_type is record
        H_VIDEO : integer;
        H_FP    : integer;
        H_SYNC  : integer;
        H_BP    : integer;
        H_TOTAL : integer;
        V_VIDEO : integer;
        V_FP    : integer;
        V_SYNC  : integer;
        V_BP    : integer;
        V_TOTAL : integer;
        H_POL   : std_logic;
        V_POL   : std_logic;
        ACTIVE  : std_logic;
    end record;



-- VGA timing
--      screen area 640x480 @60 Hz
--      horizontal : 640 visible + 16 front porch (fp) + 96 hsync + 48 back porch = 800 pixels
--      vertical   : 480 visible + 10 front porch (fp) +  2 vsync + 33 back porch = 525 pixels
--      Total area 800x525
--      clk input should be 25 MHz signal (800 * 525 * 60)
--      hsync and vsync are negative polarity

    constant VGA_TIMING : video_timing_type := (
        H_VIDEO =>  640,
        H_FP    =>   16,
        H_SYNC  =>   96,
        H_BP    =>   48,
        H_TOTAL =>  800,
        V_VIDEO =>  480,
        V_FP    =>   10,
        V_SYNC  =>    2,
        V_BP    =>   33,
        V_TOTAL =>  525,
        H_POL   =>  '0',
        V_POL   =>  '0',
        ACTIVE  =>  '1'
    );

    -- horizontal and vertical counters
    signal hcount : integer range  0 to (C_PIXELS_PER_LINE-1) := 0;
    signal vcount : integer range  0 to (C_LINES_PER_FRAME-1) := 0;
    signal timings : video_timing_type := VGA_TIMING;
	signal timer_imege: std_logic :='0';
	signal counter_rate:integer range 0 to MIN_RATE :=DEF_rate;
	signal counter_time:integer range 0 to MIN_RATE :=0;
begin

    timings <= VGA_TIMING;

    -- pixel counters
    process (clk,rst) is
    begin
	if RST = G_RESET_ACTIVE_VALUE then
		hcount<=0;
		vcount<=0;
		timer_imege<='0';
		counter_rate<=DEF_rate;
		counter_time<=0;
    elsif rising_edge(clk) then
		timer_imege<='0';
		if(INC_SPEED='1')then
			if(counter_rate>MAX_RATE)then
				counter_rate<=counter_rate-1;
			end if;
		end if;
		if(DEC_SPEED='1')then
			if(counter_rate<MIN_RATE)then
				counter_rate<=counter_rate+1;
			end if;
		end if;

        if (hcount = timings.H_TOTAL-1) then
            hcount <= 0;
            if (vcount = timings.V_TOTAL-1) then
				vcount <=  0;
				if(counter_time>=counter_rate)then
					timer_imege<='1';
					counter_time<=0;
				else
					timer_imege<='0';
					counter_time<=counter_time+1;
				end if;
            else
                vcount <= vcount + 1;
            end if;
        else
            hcount <= hcount + 1;
        end if;
    end if;
end process;

    -- generate video_active, hsync, and vsync signals based on the counters
    next_image <= timer_imege;
    hsync <= timings.H_POL when (hcount >= timings.H_VIDEO + timings.H_FP) and (hcount < timings.H_TOTAL - timings.H_BP) else not timings.H_POL;
    vsync <= timings.V_POL when (vcount >= timings.V_VIDEO + timings.V_FP) and (vcount < timings.V_TOTAL - timings.V_BP) else not timings.V_POL;
	H_CNT <= hcount;
	V_CNT <= vcount;

end rtl;










