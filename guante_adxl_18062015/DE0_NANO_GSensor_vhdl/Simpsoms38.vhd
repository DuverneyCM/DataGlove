--IP para doble integracion mediante el metodo de simpsons 3/8
--El metodo no divide en 8 o por 64 ya que solo representan desplazamientos
--Tambien porque se desea trabajar solo con numeros enteros
--Y las divisiones representan tan solo un escalar en el resultado final.

--Simpsoms 3/8
-- (3/8)*T*[ f(k) + 3*f(k+1) + 3*f(k+2) + f(k+3) ]
-- N = cantidad de muestras - 1
-- T = 1/N

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Simpsoms38 is
	generic
	(
		NoBits	:	natural  :=	16	-- 2 Bytes que genera el ADX, a medida que se integre, con el metodo usado, puede aumentar el numero de bits
	);

	port
	(
		-- Input ports
		clk	: in	std_logic;	
		reset	: in	std_logic;
		X		: in  std_logic_vector(NoBits - 1 downto 0);
		-- Output ports
		Y		: out std_logic_vector(NoBits + 1 downto 0)
	);
end Simpsoms38;


architecture rtl of Simpsoms38 is
	Signal X0	:	std_logic_vector(NoBits + 1 downto 0);
	Signal X1	:	std_logic_vector(NoBits + 1 downto 0);
	Signal X2	:	std_logic_vector(NoBits + 1 downto 0);
	Signal X3	:	std_logic_vector(NoBits + 1 downto 0);
	
	Signal Xa	:	std_logic_vector(NoBits + 1 downto 0);
	Signal Xb	:	std_logic_vector(NoBits + 1 downto 0);
	Signal Xb1	:	std_logic_vector(NoBits + 1 downto 0);
	
begin
	X0	<=	("00" & X)  + X3;
	Xa	<=	X0 + X3;
	Xb	<=	X1 + X2;
	Xb1	<=	Xb + (Xb(NoBits+1 downto 1) & '0');
	Y <=	Xa + Xb1;
	
	reg_desplazamiento:
	process(reset, clk) is 
	begin 
		if(reset = '1') then
			X1	<=	(X1'range => '0');
			X2	<= (X2'range => '0');
			X3	<= (X3'range => '0');
		elsif(rising_edge(clk)) then
			X1	<=	X0;
			X2	<= X1;
			X3	<= X2;
		end if;
	end process; 

end rtl;
