library ieee;
use ieee.std_logic_1164.all;
use work.spi_param.all;

entity fsm_uart is
	port(
		clk		: in	std_logic;
		reset	 	: in	std_logic;
		start		: in	std_logic;
		
		
		s1_readyfordata 		: in	std_logic; --flag
		s1_dataavailable		: in	std_logic; --flag
	
		s1_read_n				: out	std_logic; --control
		s1_write_n				: out	std_logic; --control
		s1_begintransfer 		: out std_logic; --control
		
		data_in					: in	tipoADX;
		writedata_out			: out std_logic_vector(15 downto 0);
		readdata					: out std_logic_vector(15 downto 0)	
	);

end entity;

architecture rtl of fsm_uart is
	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3, s4);
	-- Register to hold the current state
	signal	state		:	state_type;
	signal	setup		:	std_logic;
	signal	cnt, adx, subadx		:	integer;
	
	constant	Setup_step	:	natural	:=	No_ADX*6;
	constant saltos		:	natural	:=	16;

begin
	--LOGICA DE TRANSICIONES
	process (clk, reset)
	begin
		if reset = '0' then
			state <= s0;
			cnt	<=	0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=>
					if start = '1' then
						state <= s1;
					else
						state <= s0;
					end if;
				when s1=>
					if s1_readyfordata = '1' then
						state <= s2;
					else
						state <= s1;
					end if;
				when s2=>
					if s1_readyfordata = '0' then
						state <= s3;
					else
						state <= s2;
					end if;
				when s3=>
					if s1_readyfordata = '1' then
						state <= s4;
					else
						state <= s3;
					end if;	
				when s4=>
					if	cnt < Setup_step	then
						cnt	<=	cnt + 1;
						state <= s1; --Enviar otro dato
					else
						state <= s0; --Fin de envio
						cnt	<=	0;
					end if;
					
				when others	=>	null;
			end case;
		end if;
	end process;

	--LOGICA DE SALIDAS
	--impulso de inicio
	--cuando los datos estén listos para enviarsen o recibirsen, se reporta mediante flags
	--por ahora, solo se desean enviar datos de la FPGA al pc, por lo que solo es importante activar el envio de datos y observar el flag s1_dataavailable
	--como son 6 bytes por acelerometro, se deben enviar 6*No_ADX veces y el valor de cnt permite seleccionar el dato a enviar.
	--cuando cnt = 6*No_ADX veces debe detener el envío de datos y esperar a ser estimulado de nuevo para volver a enviar datos.
	
	process (state)
	begin
		case state is
			when s0 =>
				s1_begintransfer	<=	'0';
				s1_write_n			<=	'1';	--activo bajo
				s1_read_n			<=	'1';	--activo bajo
			when s1 =>
				s1_begintransfer	<=	'0';
				s1_write_n			<=	'1';	
				s1_read_n			<=	'1';	
			when s2 =>
				s1_begintransfer	<=	'1';
				s1_write_n			<=	'0';	--enviar datos
				s1_read_n			<=	'0';	
			when s3 =>
				s1_begintransfer	<=	'1';
				s1_write_n			<=	'0';	
				s1_read_n			<=	'0';	
			when s4 =>
				s1_begintransfer	<=	'0';
				s1_write_n			<=	'1';	
				s1_read_n			<=	'1';
		end case;
	end process;
	
	adx <= cnt/6;
	subadx <= cnt - adx*6;
	writedata_out <= "00000000" & data_in(adx)(subadx*8 + 7 downto subadx*8);
	
end rtl;
