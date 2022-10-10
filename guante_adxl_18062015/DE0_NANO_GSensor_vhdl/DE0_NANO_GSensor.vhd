library IEEE;
use ieee.std_logic_1164.all;
use work.spi_param.all;

entity DE0_NANO_GSensor is
	port
	(
		-- Input ports
		CLOCK_50			: in  std_logic;
		KEY				: in  std_logic_vector(1 downto 0);
		G_SENSOR_INT	: in  std_logic;
		--G_SENSOR_INT	: in  std_logic_vector(No_ADX-1 downto 0);
		
		-- Inout ports
		I2C_SDAT			: inout std_logic_vector(No_ADX-1 downto 0);
		
		-- Output ports
		tierras			:	out	std_logic_vector(7 downto 0);
--		spiControlExt	: out std_logic_vector(No_ADX-1 downto 0);
--		Ax					: out	std_logic_vector(15 downto 0);
--		Ay					: out	std_logic_vector(15 downto 0);
--		Az					: out	std_logic_vector(15 downto 0);
		
		--I2C_SCLK			: out std_logic;
		I2C_SCLK			: out std_logic_vector(No_ADX-1 downto 0);
		--G_SENSOR_CS_N	: out std_logic;
		G_SENSOR_CS_N	: out std_logic_vector(No_ADX-1 downto 0);
		--UART
		ext_uart_tx		:	out	std_logic;
		ext_uart_rx		:	in		std_logic;
		
		LED				:	out	std_logic_vector(7 downto 0)
		
		
	);
end DE0_NANO_GSensor;


architecture rtl of DE0_NANO_GSensor is
-- DECLARATIONS
	signal	sI2C_SCLK		:	std_logic;
	signal	sG_SENSOR_CS_N	:	std_logic;

-- Components
component reset_delay is
	port
	(
		-- Input ports
		ICLK		: in  std_logic;
		IRSTN		: in  std_logic;
		
		-- Output ports
		oRST		: out std_logic
	);
end component;

component spipll is
	port
	(
		-- Input ports
		areset	: in  std_logic;
		Inclk0	: in  std_logic;
		
		-- Output ports
		c0	: out std_logic;
		c1	: out std_logic
	);
end component;

component spi_ee_config is
	port
	(
		-- Input ports
		start				: in	std_logic;
		IG_INT2			: in  std_logic;
		IRSTN				: in  std_logic;
		ISPI_CLK			: in  std_logic;
		ISPI_CLK_OUT	: in  std_logic;
		
		-- Inout ports
		SPI_SDIO			: inout std_logic_vector(No_ADX-1 downto 0);
		
		-- Output ports
		spiControl		: out	std_logic;
		
		oSPI_CLK			: out std_logic;
		oSPI_CSN			: out std_logic;
		oDATA_L			: out tipoADX;
		oDATA_H			: out std_logic_vector(7 downto 0)
	);
end component;

component muestreo is
	port
	(
		-- Input ports
		reset	: in  std_logic;
		clk	: in  std_logic;

		-- Output ports
		start_spi	: out std_logic;
		start_uart	: out std_logic
	);
end component;

component UART is
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
end component;

component fsm_uart is
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
		writedata_out			: out std_logic_vector(15 downto 0)
	);
end component;

component FIFO is
	port
	(
		-- Input ports
		clk	: in	std_logic;	
		reset	: in	std_logic;
		X		: in  std_logic_vector(SO_DataL downto 0);
		-- Output ports
		Z		: out tipoDatosM
	);
end component;

component OFFSET is
	port
	(
		-- Input ports
		clk				: in	std_logic;
		reset				: in	std_logic;
		set				: in	std_logic;
		instruccion		: in	std_logic_vector(7 downto 0);
		iDATA_L			: in	tipoADX;
		-- Output ports
		oDATA_L			: out	tipoADX
	);
end component;

component get_angulos is
	port(
		-- Input ports
		CLOCK_50			:	in	std_logic;
		reset				:	in	std_logic;
		iDATA_L			:	in	tipoADX;
		start				:	in std_logic;
		
		-- Output ports
		angulos			:	out	tipoAngulos;
		signos			:	out	std_logic_vector(15 downto 0)
	);
end component;

component fsm_uart_angle is
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
end component;


signal	start,
			dly_rst,
			muestreo_spi,
			muestreo_uart,
			spy_clk,
			spy_clk_out	:	std_logic;
signal	data_x	:	std_logic_vector(15 downto 0);
signal	soDATA_L, soDATA_Loffset	:	tipoADX;
signal	sofDATA_L	:	tipoDatosM;

--UART
signal	uart_datos_enviar, uart_datos_recibir	:	std_logic_vector(7 downto 0);
signal	uart_start, uart_rx, uart_tx	:	std_logic;
signal	scan	:	std_logic_vector(7 downto 0);
signal	clk_aux	:	std_logic;
------
		signal	uart_tx_busy_n			:	std_logic;
		signal	uart_rx_busy_n			:	std_logic;
		signal	uart_read_n				:	std_logic;
		signal	uart_write_n			:	std_logic;
		signal	uart_writedata_out	:	std_logic_vector(15 downto 0);
		
--calcular angulos
signal	sAngulos		:	tipoAngulos;
signal	sSignos		:	std_logic_vector(15 downto 0);

--senal de prueba
signal	spiControl	:	std_logic;
signal	habilitador	:	std_logic_vector(No_ADX-1 downto 0)	:=	"00000000000"&"111111";

begin
u_reset_delay : reset_delay 
	port map (
		--input
		ICLK => CLOCK_50,
		IRSTN	 => KEY(0),
		--output
		oRST => dly_rst
		--inout
		--<formal_inout> => <signal>
	);

u_spipll: spipll 
	port map (
		--input
		Inclk0 => CLOCK_50,
		areset	 => dly_rst,
		--output
		c0 => spy_clk,
		c1 => spy_clk_out
	);
	
u_muestreo:	muestreo
	port map(
		reset			=>	dly_rst,	
		clk			=>	spy_clk,
		start_spi	=>	muestreo_spi,
		start_uart	=>	muestreo_uart
	);

u_spi_ee_config: spi_ee_config 
	port map (
		--input
		start				=>	muestreo_spi,
		IG_INT2 			=> G_SENSOR_INT,
		IRSTN	 			=> NOT(dly_rst),
		ISPI_CLK 		=> spy_clk,
		ISPI_CLK_OUT	=> spy_clk_out,
		--output
		spiControl		=>	spiControl,
		
		oSPI_CLK	 => sI2C_SCLK,
		oSPI_CSN	 => sG_SENSOR_CS_N,
		oDATA_L	 => soDATA_L,
		oDATA_H	 => data_x(15 downto 8),
		--inout
		SPI_SDIO(16) => I2C_SDAT(16),
		SPI_SDIO(15) => I2C_SDAT(15),
		SPI_SDIO(14 downto 10) => I2C_SDAT(14 downto 10),
		SPI_SDIO(9) => I2C_SDAT(9),
		SPI_SDIO(8 downto 5) => I2C_SDAT(8 downto 5),
		SPI_SDIO(4) => I2C_SDAT(4),
		SPI_SDIO(3 downto 0) => I2C_SDAT(3 downto 0)
	);
	--I2C_SDAT(15)	<=	'0';
	--I2C_SDAT(9)	<=	'0';
	--I2C_SDAT(4)		<=	'0';

u_uart: UART 
	Port map(	clock_50		=>	CLOCK_50,
				SW					=>	uart_datos_enviar,
				key				=>	"000" & uart_start, --KEY(1), --uart_start,
				ledr				=>	uart_datos_recibir,
				--ledg				=>	LED,
				uart_TXD			=>	uart_tx,
				uart_RXD			=>	uart_rx,
				uart_RXD_busy	=>	uart_rx_busy_n,
				uart_TXD_busy	=>	uart_tx_busy_n
	);
	ext_uart_tx	<=	uart_tx;
	uart_rx <= ext_uart_rx;
	--uart_start <= muestreador;
	--uart_datos_enviar <= soDATA_L(0)(41 downto 34);
	uart_datos_enviar <= uart_writedata_out(7 downto 0);
	LED	<=	uart_datos_recibir;
	
--u_fsm_uart:	fsm_uart
--	port map(
--		clk						=>	CLOCK_50,--
--		reset	 					=>	dly_rst,--
--		start						=>	muestreo_uart,--
--		s1_readyfordata 		=>	not(uart_tx_busy_n),
--		s1_dataavailable		=>	uart_rx_busy_n,
--		s1_read_n				=>	uart_read_n,
--		s1_write_n				=>	uart_write_n,
--		s1_begintransfer 		=>	uart_start,
--		data_in					=>	soDATA_Loffset,--
--		writedata_out			=>	uart_writedata_out
--	);

u_fsm_uart_angle:fsm_uart_angle
	port map(
		clk						=>	CLOCK_50,--
		reset	 					=>	dly_rst,--
		start						=>	muestreo_uart,--
		s1_readyfordata 		=>	not(uart_tx_busy_n),
		s1_dataavailable		=>	uart_rx_busy_n,
		s1_read_n				=>	uart_read_n,
		s1_write_n				=>	uart_write_n,
		s1_begintransfer 		=>	uart_start,
		angulos					=>	sAngulos,
		signos					=>	sSignos,
		writedata_out			=>	uart_writedata_out
	);
	
	offset_adxl:OFFSET
	port map(
		-- Input ports
		clk				=>	CLOCK_50,
		reset				=>	not(dly_rst),
		set				=>	muestreo_uart,
		instruccion		=>	uart_datos_recibir,
		iDATA_L			=>	soDATA_L,
		-- Output ports
		oDATA_L			=> soDATA_Loffset
	);
	
	get_angulosTag:get_angulos
	port map(
		CLOCK_50			=>	CLOCK_50,
		reset				=>	not(dly_rst),
		iDATA_L			=>	soDATA_Loffset,
		start				=>	muestreo_uart,
		-- Output ports
		angulos			=>	sAngulos,
		signos			=>	sSignos
	);
	
	multiples_adx:
	for i in 0 to No_ADX-1 generate
		I2C_SCLK(i)			<=	sI2C_SCLK and habilitador(i);
		G_SENSOR_CS_N(i)	<=	sG_SENSOR_CS_N and habilitador(i);
		--spiControlExt(i)	<=	spiControl;
		
--		u_FIFO : FIFO 
--		port map (
--			clk	=>	CLOCK_50,
--			reset	=>	dly_rst,
--			X		=>	soDATA_L(i),
--			Z		=>	sofDATA_L --necesito una señal diferente para cada banco de memoria creado
--		);
	end generate;
	
--	Ax <= soDATA_L(0)(47 downto 32);
--	Ay <= soDATA_L(0)(31 downto 16);
--	Az <= soDATA_L(0)(15 downto 0);
	--pines no utilizados
	tierras	<=	(others => '0'); 
		
end rtl;
