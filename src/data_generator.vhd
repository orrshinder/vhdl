

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_generator is
  generic (
    G_RESET_ACTIVE_VALUE : std_logic := '0';
    C_PIXELS_PER_LINE  : natural := 800;
	C_LINES_PER_FRAME  : natural := 525;
    g_VIDEO_WIDTH : integer := 8;     --?
	DATA_VALUE : integer := 16;      --?
	ADDRES_VALUE : integer := 18;     --?
    g_ACTIVE_COLS : integer := 640;
	bar_size : integer := 80;      --?
	pic_start_h: integer := 260;      --?
	pic_end_h: integer := 379;     --?
	pic_start_v: integer := 150;     --?
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
end entity data_generator;
architecture rtl of data_generator is
	function bit_adder(x:std_logic_vector(time_per_pixel-1 downto 0)) return std_logic_vector is
		variable y:std_logic_vector(g_VIDEO_WIDTH-1 downto 0):="00000000";
		begin
		if x="00" then
			y:="00000000";
		elsif x="01" then
			y:="00111111";
		elsif x="10" then
			y:="01111111";
		elsif x="11" then
			y:="11111111";
		end if;
		return y;
	end function bit_adder;
	signal red:std_logic_vector(g_VIDEO_WIDTH-1 downto 0):="00000000";
	signal green:std_logic_vector(g_VIDEO_WIDTH-1 downto 0):="00000000";
	signal blue:std_logic_vector(g_VIDEO_WIDTH-1 downto 0):="00000000";
	signal adrres_pointer:integer range 0 to (PICTURE_size*PICTURE_AMAOUNT):=0;
	signal min_adrres_pointer:integer range 0 to (PICTURE_size*PICTURE_AMAOUNT):=0;
	signal max_adrres_pointer:integer range 0 to (PICTURE_size*PICTURE_AMAOUNT):=0;
	signal flag:std_logic:='0';
	signal red_pixel:std_logic_vector(time_per_pixel-1 downto 0):="00";
	signal green_pixel:std_logic_vector(time_per_pixel-1 downto 0):="00";
	signal blue_pixel:std_logic_vector(time_per_pixel-1 downto 0):="00";
	signal picture_display:integer range 0 to (PICTURE_AMAOUNT):=0;
	signal temp:integer range 0 to (PICTURE_size*PICTURE_AMAOUNT):=0;
	signal data_cerator:std_logic:='0';
  
begin


  
  -- Register syncs to align with output data.
    process (clk,rst) is
    begin
	if(rst=G_RESET_ACTIVE_VALUE) then
		picture_display<=0;	
		flag<='0';
		adrres_pointer<=0;
		data_cerator<='0';
	elsif rising_edge(clk) then
		if IMAGE_ENA='1' then
			if ANIMATION_DIR='1' then
				if NEXT_IMAGE='1' and picture_display<(PICTURE_AMAOUNT-1) then
					picture_display<=picture_display+1;
					min_adrres_pointer<=(PICTURE_size*(picture_display));
					max_adrres_pointer<=((picture_display+1)*(PICTURE_size));
					adrres_pointer<=(PICTURE_size*(picture_display+1));
				elsif NEXT_IMAGE='0' and picture_display<(PICTURE_AMAOUNT-1) then
					min_adrres_pointer<=(PICTURE_size*(picture_display));
					max_adrres_pointer<=((picture_display+1)*(PICTURE_size));
				else
					picture_display<=0;
					min_adrres_pointer<=(0);
					max_adrres_pointer<=((PICTURE_size));
					adrres_pointer<=(0);
				end if;
				if ((H_CNT<bar_size and V_CNT< g_ACTIVE_ROWS) or (((bar_size*8)-1)<=H_CNT and H_CNT<(bar_size*8))) and V_CNT< g_ACTIVE_ROWS then
					red<="11111111";
					green<="00000000";
					blue<="00000000";
					data_cerator<='1';
				elsif (bar_size*1)<=H_CNT and H_CNT<(bar_size*2) and V_CNT< g_ACTIVE_ROWS then
					red<="00000000";
					green<="11111111";
					blue<="00000000";
					data_cerator<='1';
				elsif (bar_size*2)<=H_CNT and H_CNT<(bar_size*3)and V_CNT< g_ACTIVE_ROWS then
					red<="00000000";
					green<="00000000";
					blue<="00000000";
					data_cerator<='1';
				elsif (bar_size*3)<=H_CNT and H_CNT<(bar_size*4) and V_CNT< g_ACTIVE_ROWS then
					if (pic_start_h<=H_CNT and H_CNT<(bar_size*4)) and pic_start_v<V_CNT and V_CNT<=pic_end_v then	
						if min_adrres_pointer<=adrres_pointer and adrres_pointer<=max_adrres_pointer-1 then
							if flag='0' then
								red<=bit_adder(SRAM_D(time_per_pixel-1 downto 0));
								green<=bit_adder(SRAM_D((2*time_per_pixel-1) downto time_per_pixel));
								blue<=bit_adder(SRAM_D((3*time_per_pixel-1) downto (2*time_per_pixel)));
								flag<='1';
							elsif flag='1' then
								red<=bit_adder(SRAM_D((5*time_per_pixel-1) downto (4*time_per_pixel)));
								green<=bit_adder(SRAM_D((6*time_per_pixel-1) downto (5*time_per_pixel)));
								blue<=bit_adder(SRAM_D((7*time_per_pixel-1) downto (6*time_per_pixel)));
								adrres_pointer<=adrres_pointer+1;
								flag<='0';
								if adrres_pointer>=(max_adrres_pointer-1) then
									adrres_pointer<=min_adrres_pointer;
								end if;
							end if;
						else
							adrres_pointer<=min_adrres_pointer;
						end if;
	
					else
						red<="11111111";
						green<="11111111";
						blue<="00000000";
					end if;
					data_cerator<='1';
				elsif (bar_size*4)<=H_CNT and H_CNT<(bar_size*5) and V_CNT< g_ACTIVE_ROWS then
					if (bar_size*4<=H_CNT and H_CNT<(pic_end_h)) and pic_start_v<V_CNT and V_CNT<=(pic_end_v) then
						if min_adrres_pointer<=adrres_pointer and adrres_pointer<=max_adrres_pointer-1 then
							if flag='0' then
								red<=bit_adder(SRAM_D(time_per_pixel-1 downto 0));
								green<=bit_adder(SRAM_D((2*time_per_pixel-1) downto time_per_pixel));
								blue<=bit_adder(SRAM_D((3*time_per_pixel-1) downto (2*time_per_pixel)));
								flag<='1';
							elsif flag='1' then
								red<=bit_adder(SRAM_D((5*time_per_pixel-1) downto (4*time_per_pixel)));
								green<=bit_adder(SRAM_D((6*time_per_pixel-1) downto (5*time_per_pixel)));
								blue<=bit_adder(SRAM_D((7*time_per_pixel-1) downto (6*time_per_pixel)));
								adrres_pointer<=adrres_pointer+1;
								flag<='0';
								if adrres_pointer>=(max_adrres_pointer-1) then
									adrres_pointer<=min_adrres_pointer;
								end if;
							end if;
						else
							adrres_pointer<=min_adrres_pointer;
						end if;
					else
						red<="00000000";
						green<="00000000";
						blue<="11111111";
					end if;
					data_cerator<='1';
				elsif (bar_size*5)<=H_CNT and H_CNT<(bar_size*6) and V_CNT< g_ACTIVE_ROWS then
					red<="11111111";
					green<="00000000";
					blue<="11111111";
					data_cerator<='1';
				elsif (bar_size*6)<=H_CNT and H_CNT<(bar_size*7) and V_CNT< g_ACTIVE_ROWS then
					red<="00000000";
					green<="11111111";
					blue<="11111111";
					data_cerator<='1';
				elsif (bar_size*7)<=H_CNT and H_CNT<((bar_size*8)-1)and V_CNT< g_ACTIVE_ROWS then 
					red<="11111111";
					green<="11111111";
					blue<="11111111";
					data_cerator<='1';
				else
					flag<='0';
					data_cerator<='0';
				end if;	
		
			else
				if NEXT_IMAGE='1' and picture_display>0 then
					picture_display<=picture_display-1;
					min_adrres_pointer<=((picture_display-1)*(PICTURE_size));
					max_adrres_pointer<=((picture_display)*(PICTURE_size));
					adrres_pointer<=(PICTURE_size*(picture_display-2));
				elsif NEXT_IMAGE='0' and picture_display>0 then
					min_adrres_pointer<=((picture_display-1)*(PICTURE_size));
					max_adrres_pointer<=((picture_display)*(PICTURE_size));
				else
					picture_display<=(PICTURE_AMAOUNT-1);
					min_adrres_pointer<=((PICTURE_AMAOUNT-2)*(PICTURE_size));
					max_adrres_pointer<=((PICTURE_AMAOUNT-1)*(PICTURE_size));
					adrres_pointer<=((PICTURE_AMAOUNT-2)*(PICTURE_size));
				end if;
				if ((H_CNT<bar_size and V_CNT< g_ACTIVE_ROWS) or (((bar_size*8)-1)<=H_CNT and H_CNT<(bar_size*8))) and V_CNT< g_ACTIVE_ROWS then
					red<="11111111";
					green<="00000000";
					blue<="00000000";
					data_cerator<='1';
				elsif (bar_size*1)<=H_CNT and H_CNT<(bar_size*2) and V_CNT< g_ACTIVE_ROWS then
					red<="00000000";
					green<="11111111";
					blue<="00000000";
					data_cerator<='1';
				elsif (bar_size*2)<=H_CNT and H_CNT<(bar_size*3)and V_CNT< g_ACTIVE_ROWS then
					red<="00000000";
					green<="00000000";
					blue<="00000000";
					data_cerator<='1';
				elsif (bar_size*3)<=H_CNT and H_CNT<(bar_size*4) and V_CNT< g_ACTIVE_ROWS then
					if (pic_start_h<=H_CNT and H_CNT<(bar_size*4)) and pic_start_v<V_CNT and V_CNT<=pic_end_v then	
						if min_adrres_pointer<=adrres_pointer and adrres_pointer<=max_adrres_pointer-1 then
							if flag='0' then
								red<=bit_adder(SRAM_D(time_per_pixel-1 downto 0));
								green<=bit_adder(SRAM_D((2*time_per_pixel-1) downto time_per_pixel));
								blue<=bit_adder(SRAM_D((3*time_per_pixel-1) downto (2*time_per_pixel)));
								flag<='1';
							elsif flag='1' then
								red<=bit_adder(SRAM_D((5*time_per_pixel-1) downto (4*time_per_pixel)));
								green<=bit_adder(SRAM_D((6*time_per_pixel-1) downto (5*time_per_pixel)));
								blue<=bit_adder(SRAM_D((7*time_per_pixel-1) downto (6*time_per_pixel)));
								adrres_pointer<=adrres_pointer+1;
								flag<='0';
								if adrres_pointer>=(max_adrres_pointer-1) then
									adrres_pointer<=min_adrres_pointer;
								end if;
							end if;
						else
							adrres_pointer<=min_adrres_pointer;
						end if;
	
					else
						red<="11111111";
						green<="11111111";
						blue<="00000000";
					end if;
					data_cerator<='1';
				elsif (bar_size*4)<=H_CNT and H_CNT<(bar_size*5) and V_CNT< g_ACTIVE_ROWS then
					if (bar_size*4<=H_CNT and H_CNT<(pic_end_h)) and pic_start_v<V_CNT and V_CNT<=(pic_end_v) then
						if min_adrres_pointer<=adrres_pointer and adrres_pointer<=max_adrres_pointer-1 then
							if flag='0' then
								red<=bit_adder(SRAM_D(time_per_pixel-1 downto 0));
								green<=bit_adder(SRAM_D((2*time_per_pixel-1) downto time_per_pixel));
								blue<=bit_adder(SRAM_D((3*time_per_pixel-1) downto (2*time_per_pixel)));
								flag<='1';
							elsif flag='1' then
								red<=bit_adder(SRAM_D((5*time_per_pixel-1) downto (4*time_per_pixel)));
								green<=bit_adder(SRAM_D((6*time_per_pixel-1) downto (5*time_per_pixel)));
								blue<=bit_adder(SRAM_D((7*time_per_pixel-1) downto (6*time_per_pixel)));
								adrres_pointer<=adrres_pointer+1;
								flag<='0';
								if adrres_pointer>=(max_adrres_pointer-1) then
									adrres_pointer<=min_adrres_pointer;
								end if;
							end if;
						else
							adrres_pointer<=min_adrres_pointer;
						end if;
					else
						red<="00000000";
						green<="00000000";
						blue<="11111111";
					end if;
					data_cerator<='1';
				elsif (bar_size*5)<=H_CNT and H_CNT<(bar_size*6) and V_CNT< g_ACTIVE_ROWS then
					red<="11111111";
					green<="00000000";
					blue<="11111111";
					data_cerator<='1';
				elsif (bar_size*6)<=H_CNT and H_CNT<(bar_size*7) and V_CNT< g_ACTIVE_ROWS then
					red<="00000000";
					green<="11111111";
					blue<="11111111";
					data_cerator<='1';
				elsif (bar_size*7)<=H_CNT and H_CNT<((bar_size*8)-1)and V_CNT< g_ACTIVE_ROWS then 
					red<="11111111";
					green<="11111111";
					blue<="11111111";
					data_cerator<='1';
				else
					flag<='0';
					data_cerator<='0';
				end if;
		
		
			end if;
		
		else
			if ((H_CNT<bar_size and V_CNT< g_ACTIVE_ROWS) or (((bar_size*8)-1)<=H_CNT and H_CNT<(bar_size*8))) and V_CNT< g_ACTIVE_ROWS  then
				red<="11111111";
				green<="00000000";
				blue<="00000000";
				data_cerator<='1';
			elsif (bar_size*1)<=H_CNT and H_CNT<(bar_size*2) and V_CNT< g_ACTIVE_ROWS then
				red<="00000000";
				green<="11111111";
				blue<="00000000";
				data_cerator<='1';
			elsif (bar_size*2)<=H_CNT and H_CNT<(bar_size*3) and V_CNT< g_ACTIVE_ROWS then
				red<="00000000";
				green<="00000000";
				blue<="00000000";
				data_cerator<='1';
			elsif (bar_size*3)<=H_CNT and H_CNT<(bar_size*4)and V_CNT< g_ACTIVE_ROWS then
				red<="11111111";
				green<="11111111";
				blue<="00000000";
				data_cerator<='1';
			elsif (bar_size*4)<=H_CNT and H_CNT<(bar_size*5)and V_CNT< g_ACTIVE_ROWS then
				red<="00000000";
				green<="00000000";
				blue<="11111111";
				data_cerator<='1';
			elsif (bar_size*5)<=H_CNT and H_CNT<(bar_size*6)and V_CNT< g_ACTIVE_ROWS then
				red<="11111111";
				green<="00000000";
				blue<="11111111";
				data_cerator<='1';
			elsif (bar_size*6)<=H_CNT and H_CNT<(bar_size*7) and V_CNT< g_ACTIVE_ROWS then
				red<="00000000";
				green<="11111111";
				blue<="11111111";
				data_cerator<='1';
			elsif (bar_size*7)<=H_CNT and H_CNT<((bar_size*8)-1)and V_CNT< g_ACTIVE_ROWS then
				red<="11111111";
				green<="11111111";
				blue<="11111111";
				data_cerator<='1';
			else
				data_cerator<='0';
			end if;
			
			
		
		end if;
	
	
	end if;

end process;

  R_DATA <=red;
    G_DATA <=green;
    B_DATA <=blue;
	SRAM_A<=std_logic_vector(to_unsigned(adrres_pointer,ADDRES_VALUE));
	DATA_ENA<=data_cerator;
  
end architecture RTL;
