library IEEE;
use ieee.std_logic_1164.all;

entity led_driver is
	port
	(
		-- Input ports
		ICLK		: in  std_logic;
		IG_INT2	: in	std_logic;
		IRSTN		: in	std_logic;
		IDIG		: in  std_logic_vector(9 downto 0);
		
		-- Output ports
		oLED	: out std_logic_vector(7 downto 0)
	);
end led_driver;


architecture rtl of led_driver is
	signal select_data		:	std_logic_vector(4 downto 0);
	signal signed_bit			:	std_logic;
	signal abs_select_high	:	std_logic_vector(3 downto 0);
	signal int2_d				:	std_logic_vector(1 downto 0);
	signal int2_count			:	std_logic_vector(4 downto 0);
	signal int2_count_en		:	std_logic;
begin
	select_data	<=	IDIG(9 downto 5)	when IG_INT2 = '1' else	--	resolucion +-2g, 10bits
						--	resolucion +-g, 9bits
						IDIG(8 downto 4)	when (IDIG(9) AND IDIG(8)) = '1'			else
						"10000"				when (IDIG(9) AND NOT(IDIG(8))) = '1'	else
						"01111"				when (NOT(IDIG(9)) AND IDIG(8)) = '1'	else
						--IDIG(8 downto 4)	when (NOT(IDIG(9)) AND (NOT(IDIG(8))))	else
						IDIG(8 downto 4)	when (IDIG(9) NOR IDIG(8)) = '1'			else
						null;

	signed_bit	<=	select_data(4);
	
	abs_select_high	<=	NOT(select_data(3 downto 0))	when signed_bit = '1' else
								select_data(3 downto 0);
								
	
--	oLED	<=		when	(abs_select_high(3 downto 1) = "000")	AND	int2_count(23)	else
--					when	(abs_select_high[3:1] == 3'h0)	AND	int2_count(23)	else
--	
--	oLED	<=	(with abs_select_high(3 downto 1) select	<target> <= <value> when <choices>
--				<value> when <choices>
--				<value> when <choices>
--	 		    ...
--				<value> when others;)
--	
--	
--	
	oLED	<=	IDIG(7 downto 0);
end rtl;