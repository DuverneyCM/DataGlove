library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.spi_param.all;

entity FILTROmm is
	port
	(
		-- Input ports
		clk	: in	std_logic;	
		reset	: in	std_logic;
		X		: in  tipoDatosM;
		-- Output ports
		Y		: out std_logic_vector(SO_DataL downto 0)
	);
end FILTROmm;


architecture rtl of FILTROmm is
	type 		tipoFiltro is array(No_ADX-1 downto 0) of std_logic_vector(SI_DataL + expNoStage downto 0);
	
	Signal	auxX,auxY,auxZ	:	tipoFiltro;
	Signal	sumaX, sumaY, sumaZ	:	std_logic_vector(SI_DataL + expNoStage downto 0);
	Signal M	:	tipoDatosM;
	
begin
	EntradaAmpliadaP5:
	for i in 0 to NoStage-1 generate
		auxX(i)	<=	"00000" & X(i)(15 downto 0); -- hacer el numero de ceros ajustable al expNoStage
		auxY(i)	<=	"00000" & X(i)(31 downto 16); -- hacer el numero de ceros ajustable al expNoStage
		auxZ(i)	<=	"00000" & X(i)(47 downto 32); -- hacer el numero de ceros ajustable al expNoStage
	end generate;
	
	
	
	sumador:
	process(reset, clk) is 
	begin 
		--sumaX	<=	sumaX'range => '0');
		
		for i in 0 to NoStage-1 loop
			sumaX	<=	sumaX + auxX(i);
			sumaY	<=	sumaY + auxY(i);
			sumaZ	<=	sumaZ + auxZ(i);
		end loop;
	end process;
	
	Y	<= sumaX(SI_DataL + expNoStage downto expNoStage) + sumaY(SI_DataL + expNoStage downto expNoStage) + sumaZ(SI_DataL + expNoStage downto expNoStage);
	

end rtl;