library ieee;
use ieee.std_logic_1164.all;

entity stabilizer is
 generic (
    G_RESET_ACTIVE_VALUE : std_logic := '0'
	);
	port(
		D_in  : in std_logic;
		RST   : in std_logic;
		CLK   : in std_logic;
		Q_out : out std_logic
		);
end entity;


architecture behave of stabilizer is
signal QinDout : std_logic := '0';  -- acts like port/wire
begin
process(RST,CLK)
	begin
		if RST = G_RESET_ACTIVE_VALUE then 
			Q_out <= '0';
			QinDout <= '0';
		else
			if rising_edge(CLK) then
				QinDout <= D_in;
				Q_out <= QinDout;
			end if;
		end if;
	end process; -- only at the end of the process the signals and hardware ports change
		 

end architecture;
		