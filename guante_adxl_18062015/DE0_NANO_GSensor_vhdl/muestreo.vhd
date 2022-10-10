library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity muestreo is
	port
	(
		-- Input ports
		reset	: in  std_logic;
		clk	: in  std_logic;

		-- Output ports
		start_spi	: out std_logic;
		start_uart	: out std_logic
	);
end muestreo;

architecture rtl of muestreo is
--signal	cnt	:	std_logic_vector(10 downto 0); --2M -> 100 ~ 2000ciclos
signal	cnt				:	std_logic_vector(11 downto 0); --2M -> 100 ~ 2000ciclos
signal	cuenta_pulsos	:	std_logic_vector(6 downto 0); --cuenta hasta 128, pulsos a 25Hz
signal	start	:	std_logic;
signal	aux_spi, aux_uart, delay_spi, delay_uart	:	std_logic;
--signal	cnt	: integer range 0 to 800000;
begin
	process(reset, clk) is 
		
	begin 
		if(reset = '1') then
			cnt 				<= (others => '0');
			cuenta_pulsos	<= (others => '0');			
			--cnt <= 0;
		elsif(rising_edge(clk)) then
			--if(cnt = "11111010000") then --2000 -> 1000Hz
			--if(cnt = "1001-1100-0100-0000-0") then --80000 -> 25Hz
			--if(cnt = "10011100010000000") then --1250 -> 1600Hz
			--Reloj de frecuencia máxima
			if(cnt = "001001110001") then --625 -> 3200Hz
				cnt <= (others => '0');
				--cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
			--contador de pulsos
			if(start = '1') then
				cuenta_pulsos <= cuenta_pulsos + 1;
			else
				cuenta_pulsos <= cuenta_pulsos;
			end if;
			
			delay_spi	<=	aux_spi;
			delay_uart	<=	aux_uart;
			
		end if;
	end process; 
	
	start			<= '1' when (cnt = 0) else '0';
	--0=1600, 1=800, 2=400, 3=200, 4=100, 5=50, 6=25
	
	aux_spi	<=	cuenta_pulsos(4);--100Hz
	aux_uart	<=	cuenta_pulsos(6);--50Hz
	
	start_spi	<=	start;--aux_spi and not(delay_spi);--start;
	start_uart	<=	aux_uart and not(delay_uart);

end rtl;
