library IEEE;
use ieee.std_logic_1164.all;
use work.spi_param.all;


entity spi_reg_ffd is
	port
	(
		-- Input ports
		IRSTN				: in  std_logic;
		CLK				: in  std_logic;
		start				: in  std_logic;
		input				: in tipoADX;
		
	-- Output ports
		output			: out tipoADX
	);
end spi_reg_ffd;

architecture rtl of spi_reg_ffd is
begin
	process(CLK)
	begin
		if (rising_edge(CLK)) then
			if (start = '1') then
				for i in 0 to No_ADX-1 loop
					output(i) <= input(i);
				end loop;
			end if;
		end if;
	end process;
end rtl;