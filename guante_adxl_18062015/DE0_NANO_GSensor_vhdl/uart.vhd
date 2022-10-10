library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity UART is
	Port (	clock_50: in std_logic;
				SW: in std_logic_vector(7 downto 0);
				key: in std_logic_vector(3 downto 0);
				ledr: out std_logic_vector(7 downto 0);
				ledg: out std_logic_vector (7 downto 0);
				uart_TXD : out std_logic;
				uart_RXD :in std_logic;
				uart_RXD_busy	: out std_logic;
				uart_TXD_busy	: out std_logic
	);
end uart;
	
architecture main	of uart is

	signal tx_data: std_logic_vector(7 downto 0);
	signal tx_start: std_logic:= '0';
	signal tx_busy: std_logic;
	signal rx_data: std_logic_vector(7 downto 0);
	signal rx_busy: std_logic;
	signal led: std_logic_vector(7 downto 0);
		
	component tx
		port(	clk : in std_logic;
				start:in std_logic;
				busy: out std_logic;
				data: in std_logic_vector(7 downto 0);
				tx_line: out std_logic;
				led	: out std_logic_vector(7 downto 0)
		);
	end component tx;
	
	component rx
		port(	clk : in std_logic;
				Rx_line: in std_logic;
				data: out std_logic_vector(7 downto 0);
				busy: out std_logic	
		);
	end component rx;	
	
	
	begin
		
		C1: tx port map(clock_50,tx_start,tx_busy,tx_data,uart_TXD,led);
		C2: rx port map(clock_50,uart_RXD,rx_data,rx_busy);
		
		uart_RXD_busy	<=	rx_busy;
		uart_TXD_busy	<=	tx_busy;
		
		
		process (rx_busy)
			variable conversion : integer range 0 to 1:= 0;
			variable count: integer range 0 to 2:= 0;
			variable data: std_logic_vector (7 downto 0);
			variable valor: integer range 0 to 512:=0;
			begin
				if(rx_busy'event and rx_busy='0') then
					--ledr(7 downto 0) <= rx_data;   ----- pinta led dato recibido
					
					if(rx_data = "01101111" AND conversion = 0) then
						conversion := 1;
						count := 0;
						valor := 0;
					elsif(rx_data = "01011010" and count = 3) then
						conversion := 0;
						count := 0;
						--ledr(7 downto 0) <= std_logic_vector(to_unsigned(valor,8)) ;
					elsif(rx_data /= "01011010" and count = 3) then
						valor:= 0;															
						conversion := 0;
						count := 0;
					end if;
					
					ledr(7 downto 0) <= rx_data ;

	
					if(conversion = 1 and rx_data /= "01101111") then	
						case(rx_data) is
							when  "00110000" => data := "00000000";
							when  "00110001" => data := "00000001";
							when  "00110010" => data := "00000010";
							when  "00110011" => data := "00000011";
							when  "00110100" => data := "00000100";
							when  "00110101" => data := "00000101";
							when  "00110110" => data := "00000110";
							when  "00110111" => data := "00110111";
							when  "00111000" => data := "00001000";
							when  "00111001" => data := "00001001";
							when others =>	null;
						end case;
						
						if(count = 1) then
							valor := to_integer(unsigned(data))*10 + valor;
						elsif(count = 2) then
							valor := to_integer(unsigned(data))+ valor;
						END IF;
							count := count + 1;
					End if;				
										
				end if;	
					
		end process;
		
		process(clock_50)
			begin
				if(clock_50'event and clock_50='1') then
					if(key(0)='1' and tx_busy='0' ) then --editado key para manejar señal interna
						tx_data<=sw(7 downto 0);
						tx_start<='1';
						--ledg <= tx_data;  -- visualizar en leds los datos que se envian
					else
						tx_start<='0';				
					end if;			
				end if;
		end process;
		ledg <= led;
		
end main;