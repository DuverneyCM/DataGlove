library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

Package spi_param is

	-- Data MSB Bit
	constant	IDLE_MSB			:	natural	:=	14;
	constant	SI_DataL			:	natural	:=	15;
	constant	SO_DataL			:	natural	:=	8*6-1; --7;
	
	--Numero de acelerometros
	constant No_ADX			:	natural	:=	17;
	constant NoAngulos		:	natural	:=	16;
	
	--Numero de etapas del registro de desplazamiento
	constant	expNoStage		:	natural  :=	5;
	constant	NoStage		:	natural  	:=	6;--2**expNoStage;

	-- Write/Read Mode 
	constant	WRITE_MODE		:	std_logic_vector	:=	"00";
	constant	READ_MODE		:	std_logic_vector	:=	"10";

	-- Initial Reg Number 
	constant	INI_NUMBER		:	std_logic_vector	:=	"0011";

	-- SPI State 
	constant	IDLE		   	:	std_logic	:=	'0';
	constant	TRANSFER			:	std_logic	:=	'1';

	-- Write Reg Address 
	constant	BW_RATE			:	std_logic_vector(5 downto 0)	:=	"101100";
	constant	POWER_CONTROL	:	std_logic_vector(5 downto 0)	:=	"101101";
	constant	DATA_FORMAT		:	std_logic_vector(5 downto 0)	:=	"110001";
	constant	INT_ENABLE		:	std_logic_vector(5 downto 0)	:=	"101110";
	constant	INT_MAP			:	std_logic_vector(5 downto 0)	:=	"101111";
	constant	THRESH_ACT		:	std_logic_vector(5 downto 0)	:=	"100100";
	constant	THRESH_INACT	:	std_logic_vector(5 downto 0)	:=	"100101";
	constant	TIME_INACT		:	std_logic_vector(5 downto 0)	:=	"100110";
	constant	ACT_INACT_CTL	:	std_logic_vector(5 downto 0)	:=	"100111";
	constant	THRESH_FF		:	std_logic_vector(5 downto 0)	:=	"101000";
	constant	TIME_FF			:	std_logic_vector(5 downto 0)	:=	"101001";
	
	constant	OFSX				:	std_logic_vector(5 downto 0)	:=	"011110";
	constant	OFSY				:	std_logic_vector(5 downto 0)	:=	"011111";
	constant	OFSZ				:	std_logic_vector(5 downto 0)	:=	"100000";

	-- Read Reg Address
	constant	INT_SOURCE		:	std_logic_vector(5 downto 0)	:=	"110000"; -- INT Status
	constant	X_LB 			   :	std_logic_vector(5 downto 0)	:=	"110010"; -- Low Byte
	constant	X_HB			   :	std_logic_vector(5 downto 0)	:=	"110011"; -- High Byte
	constant	Y_LB			   :	std_logic_vector(5 downto 0)	:=	"110100"; -- Low Byte 
	constant	Y_HB			   :	std_logic_vector(5 downto 0)	:=	"110101"; -- High Byte
	constant	Z_LB			   :	std_logic_vector(5 downto 0)	:=	"110110"; -- Low Byte 
	constant	Z_HB			   :	std_logic_vector(5 downto 0)	:=	"110111"; -- High Byte
	
	--TIPOS
	type 		tipoADX is array(No_ADX-1 downto 0) of std_logic_vector(SO_DataL downto 0);
	type 		tipoAngulos is array(NoAngulos downto 1) of std_logic_vector(7 downto 0);
	type 		tipoADXnew is array(No_ADX-1 downto 0) of std_logic_vector(7 downto 0);
	type 		tipoDatosM is array(NoStage-1 downto 0) of std_logic_vector(7 downto 0);
	
end spi_param;