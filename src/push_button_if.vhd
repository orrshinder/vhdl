library ieee;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity push_button_if is 
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
end entity;

architecture behave of push_button_if is
type mstate is (idle, st1, st2);
signal state : mstate;
signal counter : integer  range 0 to Time_press:= 0;
signal st : std_logic:=G_BUTTON_NORMAL_STATE; 
signal out_sig : std_logic:='0'; 


begin
st <= sw_in ;

control_process: process(CLK,RST)
begin
	if RST = G_RESET_ACTIVE_VALUE then
		state <= idle;
		out_sig<='0';
		counter<=0;
	elsif rising_edge(CLK) then
		case state is 
			when idle => 	
				if (st=not(G_BUTTON_NORMAL_STATE)) then
					
					out_sig<='0';
					counter<=0;
					state <= st1;
				else 
					counter<=0;
					out_sig<='0';
					state <= idle;
				end if;
			when st1 =>
				if (st=not(G_BUTTON_NORMAL_STATE) and counter<Time_press) then	
					counter<=counter+1;
					out_sig<='0';
					state <= st1;
				elsif (st=G_BUTTON_NORMAL_STATE and counter<Time_press and counter>0) then 
					out_sig<='1';
					counter<=0;
					state <= idle;
	
				elsif (st=not(G_BUTTON_NORMAL_STATE) and counter=Time_press) then 
					out_sig<='1';
					counter<=0;
					state <= st2;
				end if;
			when st2 =>
				if (st=not(G_BUTTON_NORMAL_STATE)) then 
					counter<=counter+1;
					out_sig<='0';
					if(counter = (long_press)) then
						out_sig<='1';
						counter<=0;
					end if;
					state <= st2;
				elsif (st=G_BUTTON_NORMAL_STATE) then
					state <= idle ;
				end if;
			
			when others=>
				null;
		end case;
	end if;
end process control_process;
	
--outputs
PRESS_OUT <= out_sig;

end architecture behave;