library ieee;
use ieee.std_logic_1164.all;
use work.spi_param.all;

entity fsm_uart_angle is
	port(
		clk		: in	std_logic;
		reset	 	: in	std_logic;
		start		: in	std_logic;
		
		s1_readyfordata 		: in	std_logic; --flag
		s1_dataavailable		: in	std_logic; --flag
	
		s1_read_n				: out	std_logic; --control
		s1_write_n				: out	std_logic; --control
		s1_begintransfer 		: out std_logic; --control
		
		angulos					: in	tipoAngulos;
		signos					: in	std_logic_vector(15 downto 0);
		writedata_out			: out std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of fsm_uart_angle is
	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3, s4);
	-- Register to hold the current state
	signal	state		:	state_type;
	signal	setup		:	std_logic;
	signal	cnt, adx, subadx		:	integer range 0 to 255;
	
	constant	Setup_step	:	natural	:=	6+16+2 - 1;--preambulo + angulos + signos
	constant	saltos		:	natural	:=	16;

begin
	s1_read_n	<=	'0';
	s1_write_n	<=	'0';
	--LOGICA DE TRANSICIONES
	process (clk, reset)
	begin
		if reset = '1' then
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
					if s1_readyfordata = '1' then --no busy
						state <= s2;
					else
						state <= s1;
					end if;
				when s2=>
					if s1_readyfordata = '0' then --busy
						state <= s3;
					else
						state <= s2;
					end if;
				when s3=>
					if s1_readyfordata = '1' then --no busy, datos enviados
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
				s1_begintransfer	<=	'0';	--activo bajo
			when s1 =>
				s1_begintransfer	<=	'0';	
			when s2 =>
				s1_begintransfer	<=	'1';	
			when s3 =>
				s1_begintransfer	<=	'0';
			when s4 =>
				s1_begintransfer	<=	'0';
		end case;
	end process;
	
	process (cnt, angulos, signos)
	begin
		case cnt is
			--preambulo
			when 0 =>		writedata_out <= "00000000" & "10101010";
			when 1 =>		writedata_out <= "00000000" & "01010101";
			when 2 =>		writedata_out <= "00000000" & "01010101";
			when 3 =>		writedata_out <= "00000000" & "01010101";
			when 4 =>		writedata_out <= "00000000" & "01010101";
			when 5 =>		writedata_out <= "00000000" & "10101010";
			
			--datos
			--externos
			when 6 =>		writedata_out <= "00000000" & angulos(1);
			when 7 =>		writedata_out <= "00000000" & angulos(2);
			when 8 =>		writedata_out <= "00000000" & angulos(3);
			when 9 =>		writedata_out <= "00000000" & angulos(4);
			when 10 =>		writedata_out <= "00000000" & angulos(5);	
			--medios
			when 11 =>		writedata_out <= "00000000" & angulos(6);
			when 12 =>		writedata_out <= "00000000" & angulos(7);
			when 13 =>		writedata_out <= "00000000" & angulos(8);
			when 14 =>		writedata_out <= "00000000" & angulos(9);
			when 15 =>		writedata_out <= "00000000" & angulos(10);
			--proximos
			when 16 =>		writedata_out <= "00000000" & angulos(11);
			when 17 =>		writedata_out <= "00000000" & angulos(12);
			when 18 =>		writedata_out <= "00000000" & angulos(13);
			when 19 =>		writedata_out <= "00000000" & angulos(14);
			when 20 =>		writedata_out <= "00000000" & angulos(15);
			--munheca			
			when 21 =>		writedata_out <= "00000000" & angulos(16);
			--signos
			when 22 =>		writedata_out <= "00000000" & signos(15 downto 8);
			when 23 =>		writedata_out <= "00000000" & signos(7 downto 0);
			
			when others	=>	writedata_out <= "00000000" & "00000000";
		end case;
	end process;
	
	--adx <= cnt/6;
	--subadx <= cnt - adx*6;
--	writedata_out <= "00000000" & "10101010"; --data_in(adx)(subadx*8 + 7 downto subadx*8);
	
end rtl;