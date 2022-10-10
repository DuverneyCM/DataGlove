library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.spi_param.all;

entity FIFO is
	port
	(
		-- Input ports
		clk		: in	std_logic;
		reset		: in	std_logic;
		enable	: in	std_logic;
		X			: in  std_logic_vector(7 downto 0);--(SO_DataL downto 0);
		-- Output ports
		Z			: out std_logic_vector(SO_DataL downto 0)
	);
end FIFO;


architecture rtl of FIFO is
	Signal M		:	tipoDatosM;
	signal flag, flag2	:	std_logic;
	
begin
		
	reg_desplazamiento:
	process(reset, clk) is 
	begin 
		if(reset = '0') then
			for i in 0 to NoStage-1 loop
				M(i)	<=	(M(i)'range => '0');
				flag	<=	'0';
			end loop;
		elsif(rising_edge(clk)) then
			if (flag = '1') then
				--if (flag = '0') then
					M(0)	<=	X;
					for i in 1 to NoStage-1 loop
						M(i)	<=	M(i-1);
					end loop;
				--else
				--	M <= M;
				--end if;
				
			else
				M <= M;
			end if;
			flag	<=	enable;
		end if;
	end process;
	
	Z	<= M(5)&M(4)&M(3)&M(2)&M(1)&M(0);
	

end rtl;
