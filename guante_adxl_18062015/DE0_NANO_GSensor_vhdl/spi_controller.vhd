library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_misc.all;
use work.spi_param.all;

entity spi_controller is
	port
	(
		-- Input ports
		R_nW				: in  std_logic;
		MB					: in  std_logic;
		iAddress			: in  std_logic_vector(5 downto 0);
		iData				: in  std_logic_vector(7 downto 0);
		ISPI_CLK			: in  std_logic;
		ISPI_CLK_OUT	: in  std_logic;
		
		iSPI_GO			: in  std_logic;
		IRSTN				: in  std_logic;
		
		-- Inout ports
		SPI_SDIO			: inout std_logic_vector(No_ADX-1 downto 0);
		
		-- Output ports
		spiControl		: out	std_logic;
		
		oSPI_END			: out std_logic;
		oSPI_CSN			: out std_logic;
		oS2P_DATA		: out tipoADX;
		oSPI_CLK			: out std_logic
	);
end spi_controller;


architecture rtl of spi_controller is
	signal	read_mode, write_address	:	std_logic;
	signal	iP2S_DATA		:	std_logic_vector(15 downto 0);
	signal	spi_count		:	unsigned(3 downto 0);
	signal	spi_count_en	:	std_logic;
	signal 	vSPI_END			:	std_logic;
	signal	vS2P_DATA		:	tipoADX;
	
	signal	sSPI_END, sSPI_CSN, sSPI_CLK		:	std_logic_vector(No_ADX-1 downto 0);
	signal	auxSPI_END, auxSPI_CSN, auxSPI_CLK	:	std_logic_vector(No_ADX-1 downto 0);
	signal	sS2P_DATA		:	tipoADXnew;
	
	signal	sfifoDATA_L		:	tipoADX;
	
	
	Component spi_controller_v is
		port(
			iRSTN				:	in std_logic;
			iSPI_CLK			:	in std_logic;
			iSPI_CLK_OUT	:	in std_logic;
			iP2S_DATA		:	in std_logic_vector(SI_DataL downto 0);
			iSPI_GO			:	in std_logic;
			oSPI_END			:	out std_logic;
			oS2P_DATA		:	out std_logic_vector(7 downto 0);--(SO_DataL downto 0);
			SPI_SDIO			:	inout std_logic;
			oSPI_CSN			:	out std_logic;							
			oSPI_CLK			:	out std_logic
		);
	end component;
	
	component FIFO is
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
	end component;
	
begin

	--Multiples interfaces SPI
	SPI_interfaz:
	for i in 0 to No_ADX-1 generate
		SPI_module	:	spi_controller_v
			port map(
				iRSTN				=>	IRSTN,
				iSPI_CLK			=>	ISPI_CLK,
				iSPI_CLK_OUT	=>	ISPI_CLK_OUT,
				iP2S_DATA		=>	R_nW & MB & iAddress & iData,
				iSPI_GO			=>	iSPI_GO,
				oSPI_END			=>	sSPI_END(i),
				oS2P_DATA		=> sS2P_DATA(i),
				SPI_SDIO			=>	SPI_SDIO(i),
				oSPI_CSN			=>	sSPI_CSN(i),
				oSPI_CLK			=>	sSPI_CLK(i)
			);
	end generate;
	
	--sincronizar modulos
--	auxSPI_CSN(0) <= sSPI_CSN(0);
--	flags:
--	for i in 1 to No_ADX-1 generate
--		auxSPI_CSN(i) <= auxSPI_CSN(i-1) AND sSPI_CSN(i);
--	end generate;
--	oSPI_CSN	<=	auxSPI_CSN(No_ADX-1);
	oSPI_CLK	<=	sSPI_CLK(0);
	oSPI_CSN	<=	sSPI_CSN(0);
	oSPI_END	<=	sSPI_END(0);
	
	--Registros FIFO
	FIFOs:
	for i in 0 to No_ADX-1 generate
		FIFO_module	:	FIFO
			port map(
				-- Input ports
				clk		=>	ISPI_CLK,
				reset		=>	IRSTN,
				enable	=>	sSPI_END(0),--sSPI_END(0),--not(iSPI_GO),
				X			=>	sS2P_DATA(i),
				-- Output ports
				Z			=>	sfifoDATA_L(i)
			);
	end generate;
	
	--Salida de datos (No escalable)
	Salidas:
	for i in 0 to No_ADX-1 generate
		oS2P_DATA(i)	<=	sfifoDATA_L(i);
	end generate;
	
	
end rtl;
