library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.spi_param.all;


entity get_angulos is
	port
	(
		-- Input ports
		CLOCK_50			:	in	std_logic;
		reset				:	in	std_logic;
		iDATA_L			:	in	tipoADX;
		start				:	in std_logic;
		
		-- Output ports
		angulos			:	out	tipoAngulos;
		signos			:	out	std_logic_vector(16 downto 1)
	);
end get_angulos;

ARCHITECTURE rtl of get_angulos is
	--x = AyBy + AzBz
	--y = AzBy - AyBz
	
	component arctan_dudu is
		port(
			-- Input ports
			CLOCK_50			: in	std_logic;
			reset				: in	std_logic;
			
			X					: in	std_logic_vector(17 downto 0);
			Y					: in	std_logic_vector(17 downto 0);
			-- Output ports
			angulo			: out	std_logic_vector(7 downto 0); --7
			-- flag				: out	std_logic;
			signo				: out	std_logic
		);
	end component;
	
	type adxArray is array(21 downto 1) of std_logic_vector(SO_DataL downto 0);
	type xyArray is array(16 downto 1) of std_logic_vector(31 downto 0);
	
	signal	adxl	:	adxArray;
	signal	x, y	:	xyArray;
	
	signal	sangulos, sangulos_aux	:	tipoAngulos;
	signal	ssignos, ssignos_aux		:	std_logic_vector(16 downto 1);
begin
	--organizar señales estrategicamente
	orden:
	for i in 1 to 16 generate
		adxl(i)	<=	iDATA_L(i);
	end generate;
	adxl(17)	<=	iDATA_L(16);
	adxl(18)	<=	iDATA_L(16);
	adxl(19)	<=	iDATA_L(16);
	adxl(20)	<=	iDATA_L(16);
	adxl(21)	<=	iDATA_L(0);
	
	--calcular X y Y
	xyTag:
	for i in 1 to 15 generate
		x(i)	<=	std_logic_vector( signed(adxl(i)(31 downto 16))*signed(adxl(i+5)(31 downto 16)) + signed(adxl(i)(15 downto 0))*signed(adxl(i+5)(15 downto 0)) );
		y(i)	<=	std_logic_vector( signed(adxl(i)(15 downto 0))*signed(adxl(i+5)(31 downto 16)) - signed(adxl(i)(31 downto 16))*signed(adxl(i+5)(15 downto 0)) );	
	end generate;
	x(16)	<=	std_logic_vector( signed(adxl(16)(31 downto 16))*signed(adxl(21)(47 downto 32)) + signed(adxl(16)(15 downto 0))*signed(adxl(21)(15 downto 0)) );
	y(16)	<=	std_logic_vector( signed(adxl(16)(15 downto 0))*signed(adxl(21)(47 downto 32)) - signed(adxl(16)(31 downto 16))*signed(adxl(21)(15 downto 0)) );	

	
	--calcula angulos
	angulosTag:
	for i in 1 to 16 generate
		arctanTag:arctan_dudu
		port map(
			-- Input ports
			CLOCK_50				=>	CLOCK_50,
			reset					=>	reset,
			X						=> x(i)(17 downto 0),
			Y						=>	y(i)(17 downto 0),
			-- Output ports
			angulo				=>	sangulos_aux(i),
			signo					=> ssignos_aux(i)
		);
	end generate;
	
	reg_desplazamiento:
	process(reset, CLOCK_50) is 
	begin 
		if(reset = '0') then
			for i in 1 to NoAngulos loop
				sangulos(i)	<=	(sangulos(i)'range => '0');
				ssignos	<=	(ssignos'range => '0');
			end loop;
		elsif(rising_edge(CLOCK_50)) then
			if (start = '1') then
				sangulos	<=	sangulos_aux;
				ssignos	<=	ssignos_aux;
			else
				sangulos	<=	sangulos;
				ssignos	<=	ssignos;
			end if;
		end if;
	end process;
	angulos	<=	sangulos;
	signos	<=	ssignos;
	
	
	
end rtl;