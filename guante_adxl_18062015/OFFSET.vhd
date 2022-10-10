library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.spi_param.all;


entity OFFSET is
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
end OFFSET;

architecture rtl of OFFSET is
	Signal	reg_offset		:	tipoADX;
	signal	orden				:	std_logic_vector(5 downto 0);
	signal	flag, flag2		:	std_logic;
	signal	soDATA_L, soDATA_Laux			:	tipoADX;
	
begin
	--identificar instruccion
	orden <= 	"111111" when instruccion = "0011"&"0000" else
					"000001" when instruccion = "0011"&"0001" else
					"000010" when instruccion = "0011"&"0010" else
					"000100" when instruccion = "0011"&"0011" else
					"001000" when instruccion = "0011"&"0100" else
					"010000" when instruccion = "0011"&"0101" else
					"100000" when instruccion = "0011"&"0110" else
					"000000";
	
	--aplicar instruccion
	set_offset:
	process(reset, clk) is 
	begin 
		if(reset = '0') then
		--offset por defecto (x,y,z)
			reg_offset(1)	<=	"1111111101100010"&"0000000000001000"&"0000010010001111";
			reg_offset(2)	<=	"0000000000010110"&"0000000000100000"&"0000010010100000";
			reg_offset(3)	<=	"0000000000100000"&"0000000000010010"&"0000000011010100";
			reg_offset(4)	<=	"0000000000000000"&"0000000000000000"&"0000000000000000";
			
			reg_offset(5)	<=	"1111111101000110"&"1111111101101110"&"0000100000111011";
			reg_offset(6)	<=	"1111111100011000"&"1111111110010100"&"0000010011001110";
			reg_offset(7)	<=	"0000000000010000"&"1111111111000001"&"0000010010100100";
			reg_offset(8)	<=	"1111111111010010"&"1111111011011110"&"0000010011011000";
			reg_offset(9)	<=	"0000000000000000"&"0000000000000000"&"0000000000000000";
			
			reg_offset(10)	<=	"1111111100011010"&"1111111101001010"&"0000010010101110";
			reg_offset(11)	<=	"1111111110111011"&"1111111111000101"&"0000010000011101";
			reg_offset(12)	<=	"1111111101111011"&"1111111011111110"&"0000010000101100";
			reg_offset(13)	<=	"1111111100011000"&"1111111111010110"&"0000010011011110";
			reg_offset(14)	<=	"1111111101110100"&"1111111110001010"&"0000001110110101";
			
			reg_offset(15)	<=	"0000000001011110"&"0000000001001000"&"0000001111111000";--listo x
			reg_offset(16)	<=	"0000000000000010"&"1111111111111010"&"0000010000100110";--listo y
			reg_offset(0)	<=	"0000000000001110"&"0000000000000010"&"0000000100001010";--listo z
			
--			for i in 0 to No_ADX-1 loop
--				reg_offset(i)	<=	(reg_offset(i)'range => '0');
--			end loop;
		elsif(rising_edge(clk)) then
			if orden(0) = '1' then
				reg_offset(0) <=	iDATA_L(0);
				reg_offset(16) <=	iDATA_L(16);
			end if;
			if orden(1) = '1' then
				reg_offset(1) <=	iDATA_L(1);
				reg_offset(6) <=	iDATA_L(6);
				reg_offset(11) <=	iDATA_L(11);
			end if;
			if orden(2) = '1' then
				reg_offset(2) <=	iDATA_L(2);
				reg_offset(7) <=	iDATA_L(7);
				reg_offset(12) <=	iDATA_L(12);
			end if;
			if orden(3) = '1' then
				reg_offset(3) <=	iDATA_L(3);
				reg_offset(8) <=	iDATA_L(8);
				reg_offset(13) <=	iDATA_L(13);
			end if;
			if orden(4) = '1' then
				reg_offset(4) <=	iDATA_L(4);
				reg_offset(9) <=	iDATA_L(9);
				reg_offset(14) <=	iDATA_L(14);
			end if;
			if orden(5) = '1' then
				reg_offset(5) <=	iDATA_L(5);
				reg_offset(10) <=	iDATA_L(10);
				reg_offset(15) <=	iDATA_L(15);
			end if;
		end if;
	end process;
	
	--Aplicar offSET
	
		SPI_interfaz:
	for i in 0 to No_ADX-1 generate
		soDATA_Laux(i)(47 downto 32)	<=	iDATA_L(i)(47 downto 32) - reg_offset(i)(47 downto 32);
		soDATA_Laux(i)(31 downto 16)	<=	iDATA_L(i)(31 downto 16) - reg_offset(i)(31 downto 16);
		soDATA_Laux(i)(15 downto 0)	<=	iDATA_L(i)(15 downto 0) - reg_offset(i)(15 downto 0) + 255;
	end generate;

	reg_desplazamiento:
	process(reset, clk) is 
	begin 
		if(reset = '0') then
			for i in 0 to No_ADX-1 loop
				soDATA_L(i)	<=	(soDATA_L(i)'range => '0');
			end loop;
		elsif(rising_edge(clk)) then
			if (set = '1') then
				soDATA_L	<=	soDATA_Laux;
			else
				soDATA_L	<=	soDATA_L;
			end if;
		end if;
	end process;
	oDATA_L	<=	soDATA_L;
	

end rtl;