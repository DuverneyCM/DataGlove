library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reset_delay is
	port
	(
		-- Input ports
		ICLK		: in  std_logic;
		IRSTN		: in  std_logic;
		
		-- Output ports
		oRST		: out std_logic
	);
end reset_delay;


architecture rtl of reset_delay is
signal	cont	:	std_logic_vector(20 downto 0);
begin
	process_reset_delay:
	process(IRSTN, ICLK) is 
		-- Declaration(s) 
	begin 
		if(IRSTN = '0') then
			oRST	<=	'1';
			cont <= (others => '0');
		elsif(rising_edge(ICLK)) then
			if(cont(20) = '0') then
				oRST	<=	'1';
				cont <= cont + 1;
			else
				oRST	<=	'0';
			end if;
		end if;
	end process; 
end rtl;
