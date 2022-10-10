library IEEE;
use ieee.std_logic_1164.all;
use work.spi_param.all;


entity spi_ee_config is
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
		oDATA_L			: out	tipoADX;
		oDATA_H			: out std_logic_vector(7 downto 0)
	);
end spi_ee_config;


architecture rtl of spi_ee_config is
	--spi_controller
	signal	sR_nW, sMB, sISPI_CLK, sISPI_CLK_OUT, siSPI_GO, sIRSTN, soSPI_END, soSPI_CSN, soSPI_CLK		:	std_logic;
	signal	sSPI_SDIO	:	std_logic_vector(No_ADX-1 downto 0);
	signal	siData		:	std_logic_vector(7 downto 0);
	signal	soS2P_DATA, soS2P_DATA_reg		:	tipoADX;
	signal	siAddress				:	std_logic_vector(5 downto 0);
	
component spi_controller is
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
end component;

component spi_fsm_controller is
	port(
		clk		: in	std_logic;
		reset	 	: in	std_logic;
		start	 	: in	std_logic;
		iSPI_END	: in	std_logic;
		
		R_nW		: out	std_logic;
		MB			: out	std_logic;
		Address	: out	std_logic_vector(5 downto 0);
		Data		: out	std_logic_vector(7 downto 0);
		oSPI_go	: out std_logic
	);
end component;

component spi_reg_ffd is
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
end component;

begin
--Componente controlador spi
--in
sISPI_CLK	<=	ISPI_CLK;
sISPI_CLK_OUT	<=	ISPI_CLK_OUT;
sIRSTN		<=	IRSTN;
--out
oSPI_CLK	<=	soSPI_CLK;


--	process(start)
--	begin
--		if (rising_edge(start)) then
--			for i in 0 to No_ADX-1 loop
--				soS2P_DATA_reg(i) <= soS2P_DATA(i);
--			end loop;
--		end if;
--	end process;
--	
--	ADX2:
--	for i in 0 to No_ADX-1 generate
--		oDATA_L(i)	<=	soS2P_DATA_reg(i);
--	end generate;

oSPI_CSN	<=	soSPI_CSN;

uspi_reg_ffd	:	spi_reg_ffd
	port map(
		IRSTN				=>	sIRSTN,
		CLK				=>	sISPI_CLK,
		start				=>	start,
		--start				=>	siSPI_GO,
		input				=>	soS2P_DATA,
		output			=>	oDATA_L
	);

uspi_controller	:	spi_controller
	port map(
		-- Input ports
		R_nW				=>	sR_nW,
		MB					=>	sMB,
		iAddress			=>	siAddress,
		iData				=>	siData,
		
		ISPI_CLK			=>	sISPI_CLK,
		ISPI_CLK_OUT	=>	sISPI_CLK_OUT,
		iSPI_GO			=>	siSPI_GO,
		IRSTN				=>	sIRSTN,
		
		-- Inout ports
		SPI_SDIO			=> SPI_SDIO,
		
		-- Output ports
		spiControl		=>	spiControl,
		
		oSPI_END			=> soSPI_END,
		oSPI_CSN			=> soSPI_CSN,
		oS2P_DATA		=> soS2P_DATA,
		oSPI_CLK			=> soSPI_CLK
	);
	
uspi_fsm_controller	:	spi_fsm_controller
	port map(
		clk				=>	sISPI_CLK,
		reset	 			=>	sIRSTN,
		start	 			=>	start,
		iSPI_END			=>	soSPI_END,
		
		R_nW				=>	sR_nW,
		MB					=>	sMB,
		Address			=>	siAddress,
		Data				=>	siData,
		oSPI_go			=>	siSPI_GO
	);
--	datapath:
--	process(IRSTN, ISPI_CLK) is 
--		-- Declaration(s) 
--	begin 
--		if(IRSTN = '1') then
--			-- Asynchronous Sequential Statement(s) 
--			spi_count_en 	<= '0';
--			spi_count 		<= "1111";
--		elsif(rising_edge(ISPI_CLK)) then
--		-- Synchronous Sequential Statement(s)
--			
--			
--			
--
--			
--			
--		end if;
--	end process; 
--
--	
--	oSPI_CSN	<=	ISPI_CLK;


end rtl;





--			-- initial setting (write mode)
--			if (ini_index < INI_NUMBER) then
--				case spi_state is
--					when IDLE =>
--						p2s_data  <= WRITE_MODE & write_data;
--						spi_go		<= '1';
--						spi_state	<= TRANSFER;
--					when TRANSFER =>
--						if (spi_end) then
--							ini_index	<= ini_index + 1;
--							spi_go		<= '0';
--							spi_state	<= IDLE;	
--						end if;
--				end case;
--
--			end if;