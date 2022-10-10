library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.spi_param.all;


entity arctan_dudu is
	port
	(
		-- Input ports
		CLOCK_50			: in	std_logic;
		reset				: in	std_logic;
		
		X					: in	std_logic_vector(17 downto 0);
		Y					: in	std_logic_vector(17 downto 0);
		-- Output ports
		angulo			: out	std_logic_vector(7 downto 0); --7
		--flag				: out	std_logic;
		signo				: out	std_logic
	);
end arctan_dudu;


ARCHITECTURE rtl of arctan_dudu is
	signal	signoX, signoY		:	std_logic;
	signal	datoX, datoY		:	std_logic_vector(17 downto 0);
	signal	A, B					:	std_logic_vector(17 downto 0);
	signal	C						:	std_logic_vector(17 downto 0);
	signal	Aaux, Baux, Caux	:	std_logic_vector(25 downto 0);
	signal	MSBs					:	std_logic_vector(7 downto 0);
	signal	mayor					:	std_logic;
	signal	oh						:	std_logic_vector(180 downto 0);
	signal	distancia			:	std_logic_vector(179 downto 0);
	signal	nDistancia			:	std_logic_vector(7 downto 0);
	signal	op1,op2,op3,op4	:	std_logic_vector(7 downto 0);
	signal	selector				:	std_logic_vector(1 downto 0);
	
	signal 	Xaux					:	std_logic_vector(17 downto 0) := "000000"&"0001"&"0001"&"1000";
	signal 	Yaux					:	std_logic_vector(17 downto 0) := "000000"&"0000"&"0001"&"0000";

begin
	
	--convertir complemento a 2 a signo-magnitud
	signoX	<=	X(17); --Xaux(15);--
	datoX		<=	X when signoX = '0' else 0-X; --Xaux when signoX = '0' else 0-Xaux;--
	signoY	<=	Y(17); --Yaux(15);--
	datoY		<=	Y when signoY = '0' else 0-Y; --Yaux when signoX = '0' else 0-Yaux;--
	
	--identificar y ordenar por mayor magnitud
	A			<=	datoX;--	when datoX>datoY else datoY; -- A es el de mayor magnitud
	B			<=	datoY;--	when datoX>datoY else datoX; -- B es el de menor magnitud
	--mayor		<=	'0'	when datoX>datoY else '1';
	
	--calcular Y/X
	--MSBs	<=	(others => B(17));
	Baux	<=	B & "00000000";
	Aaux	<=	"00000000" & A;
	Caux	<=	std_logic_vector( unsigned(Baux)/unsigned(Aaux) );
	C		<=	Caux(17 downto 0);
	
	--comparar Y/X con tabla y encontrar angulo (distancia desde la diagonal)
	
	distancia(44)	<=	'1' when C > "0000000011111100" else '0' or signoX;	--252 -- 0
	distancia(43)	<=	'1' when C > "0000000011110011" else '0' or signoX;	--243 -- 1
	distancia(42)	<=	'1' when C > "0000000011101011" else '0' or signoX;	--235
	distancia(41)	<=	'1' when C > "0000000011100010" else '0' or signoX;	--226
	distancia(40)	<=	'1' when C > "0000000011011011" else '0' or signoX;	--219
	distancia(39)	<=	'1' when C > "0000000011010011" else '0' or signoX;	--211
	distancia(38)	<=	'1' when C > "0000000011001100" else '0' or signoX;	--204
	distancia(37)	<=	'1' when C > "0000000011000100" else '0' or signoX;	--196
	distancia(36)	<=	'1' when C > "0000000010111101" else '0' or signoX;	--189
	distancia(35)	<=	'1' when C > "0000000010110111" else '0' or signoX;	--183
	
	distancia(34)	<=	'1' when C > "0000000010110000" else '0' or signoX;	--176
	distancia(33)	<=	'1' when C > "0000000010101001" else '0' or signoX;	--169
	distancia(32)	<=	'1' when C > "0000000010100011" else '0' or signoX;	--163
	distancia(31)	<=	'1' when C > "0000000010011101" else '0' or signoX;	--157
	distancia(30)	<=	'1' when C > "0000000010010111" else '0' or signoX;	--151	
	distancia(29)	<=	'1' when C > "0000000010010001" else '0' or signoX;	--145
	distancia(28)	<=	'1' when C > "0000000010001011" else '0' or signoX;	--139
	distancia(27)	<=	'1' when C > "0000000010000101" else '0' or signoX;	--133
	distancia(26)	<=	'1' when C > "0000000010000000" else '0' or signoX;	--128
	distancia(25)	<=	'1' when C > "0000000001111010" else '0' or signoX;	--122

	distancia(24)	<=	'1' when C > "0000000001110101" else '0' or signoX;	--117
	distancia(23)	<=	'1' when C > "0000000001101111" else '0' or signoX;	--111
	distancia(22)	<=	'1' when C > "0000000001101010" else '0' or signoX;	--106
	distancia(21)	<=	'1' when C > "0000000001100101" else '0' or signoX;	--101
	distancia(20)	<=	'1' when C > "0000000001100000" else '0' or signoX;	--96
	distancia(19)	<=	'1' when C > "0000000001011011" else '0' or signoX;	--91
	distancia(18)	<=	'1' when C > "0000000001010110" else '0' or signoX;	--86
	distancia(17)	<=	'1' when C > "0000000001010001" else '0' or signoX;	--81
	distancia(16)	<=	'1' when C > "0000000001001100" else '0' or signoX;	--76
	distancia(15)	<=	'1' when C > "0000000001000111" else '0' or signoX;	--71
	
	distancia(14)	<=	'1' when C > "0000000001000010" else '0' or signoX;	--66
	distancia(13)	<=	'1' when C > "0000000000111101" else '0' or signoX;	--61
	distancia(12)	<=	'1' when C > "0000000000111001" else '0' or signoX;	--57
	distancia(11)	<=	'1' when C > "0000000000110100" else '0' or signoX;	--52
	distancia(10)	<=	'1' when C > "0000000000101111" else '0' or signoX;	--47
	distancia(9)	<=	'1' when C > "0000000000101011" else '0' or signoX;	--43
	distancia(8)	<=	'1' when C > "0000000000100110" else '0' or signoX;	--38
	distancia(7)	<=	'1' when C > "0000000000100010" else '0' or signoX;	--34
	distancia(6)	<=	'1' when C > "0000000000011101" else '0' or signoX;	--29
	distancia(5)	<=	'1' when C > "0000000000011001" else '0' or signoX;	--25
	
	distancia(4)	<=	'1' when C > "0000000000010100" else '0' or signoX;	--20
	distancia(3)	<=	'1' when C > "0000000000010000" else '0' or signoX;	--16
	distancia(2)	<=	'1' when C > "0000000000001011" else '0' or signoX;	--11
	distancia(1)	<=	'1' when C > "0000000000000111" else '0' or signoX;	--7
	distancia(0)	<=	'1' when C > "0000000000000010" else '0' or signoX;	--2


	distancia(45)	<=	'1' when C > "0000000100000101" else '0' or signoX; --261 -- 0
	distancia(46)	<=	'1' when C > "0000000100001110" else '0' or signoX;	--270 -- 1
	distancia(47)	<=	'1' when C > "0000000100010111" else '0' or signoX;	--279
	distancia(48)	<=	'1' when C > "0000000100100001" else '0' or signoX;	--289
	distancia(49)	<=	'1' when C > "0000000100101100" else '0' or signoX;	--300
	distancia(50)	<=	'1' when C > "0000000100110111" else '0' or signoX;	--311
	distancia(51)	<=	'1' when C > "0000000101000010" else '0' or signoX;	--322
	distancia(52)	<=	'1' when C > "0000000101001110" else '0' or signoX;	--334
	distancia(53)	<=	'1' when C > "0000000101011010" else '0' or signoX;	--346
	distancia(54)	<=	'1' when C > "0000000101100111" else '0' or signoX;	--359
	
	distancia(55)	<=	'1' when C > "0000000101110100" else '0' or signoX;	--372
	distancia(56)	<=	'1' when C > "0000000110000011" else '0' or signoX;	--387
	distancia(57)	<=	'1' when C > "0000000110010010" else '0' or signoX;	--402
	distancia(58)	<=	'1' when C > "0000000110100010" else '0' or signoX;	--418
	distancia(59)	<=	'1' when C > "0000000110110011" else '0' or signoX;	--435	
	distancia(60)	<=	'1' when C > "0000000111000100" else '0' or signoX;	--452
	distancia(61)	<=	'1' when C > "0000000111010111" else '0' or signoX;	--471
	distancia(62)	<=	'1' when C > "0000000111101100" else '0' or signoX;	--492
	distancia(63)	<=	'1' when C > "0000001000000001" else '0' or signoX;	--513
	distancia(64)	<=	'1' when C > "0000001000011001" else '0' or signoX;	--537
	
	distancia(65)	<=	'1' when C > "0000001000110010" else '0' or signoX;	--562
	distancia(66)	<=	'1' when C > "0000001001001101" else '0' or signoX;	--589
	distancia(67)	<=	'1' when C > "0000001001101010" else '0' or signoX;	--618
	distancia(68)	<=	'1' when C > "0000001010001010" else '0' or signoX;	--650
	distancia(69)	<=	'1' when C > "0000001010101101" else '0' or signoX;	--685
	distancia(70)	<=	'1' when C > "0000001011010011" else '0' or signoX;	--723
	distancia(71)	<=	'1' when C > "0000001011111101" else '0' or signoX;	--765
	distancia(72)	<=	'1' when C > "0000001100101100" else '0' or signoX;	--812
	distancia(73)	<=	'1' when C > "0000001101100000" else '0' or signoX;	--864
	distancia(74)	<=	'1' when C > "0000001110011011" else '0' or signoX;	--923
	
	distancia(75)	<=	'1' when C > "0000001111011110" else '0' or signoX;	--990
	distancia(76)	<=	'1' when C > "0000010000101010" else '0' or signoX;	--1066
	distancia(77)	<=	'1' when C > "0000010010000011" else '0' or signoX;	--1155
	distancia(78)	<=	'1' when C > "0000010011101010" else '0' or signoX;	--1258
	distancia(79)	<=	'1' when C > "0000010101100101" else '0' or signoX;	--1381
	distancia(80)	<=	'1' when C > "0000010111111010" else '0' or signoX;	--1530
	distancia(81)	<=	'1' when C > "0000011010110001" else '0' or signoX;	--1713
	distancia(82)	<=	'1' when C > "0000011110011001" else '0' or signoX;	--1945
	distancia(83)	<=	'1' when C > "0000100011000111" else '0' or signoX;	--2247
	distancia(84)	<=	'1' when C > "0000101001100011" else '0' or signoX;	--2659
	
	distancia(85)	<=	'1' when C > "0000110010110101" else '0' or signoX;	--3253
	distancia(86)	<=	'1' when C > "0001000001011001" else '0' or signoX;	--4185
	distancia(87)	<=	'1' when C > "0001011011100111" else '0' or signoX;	--5863
	distancia(88)	<=	'1' when C > "0010011000110000" else '0' or signoX;	--9776
	distancia(89)	<=	'1' when C > "0111001010010111" else '0' or signoX;	--29335

	--MAyores a 90°
	distancia(135)	<=	'1' and signoX when C < "0000000011111100" else '0';	--252 -- 0
	distancia(136)	<=	'1' and signoX when C < "0000000011110011" else '0';	--243 -- 1
	distancia(137)	<=	'1' and signoX when C < "0000000011101011" else '0';	--235
	distancia(138)	<=	'1' and signoX when C < "0000000011100010" else '0';	--226
	distancia(139)	<=	'1' and signoX when C < "0000000011011011" else '0';	--219
	distancia(140)	<=	'1' and signoX when C < "0000000011010011" else '0';	--211
	distancia(141)	<=	'1' and signoX when C < "0000000011001100" else '0';	--204
	distancia(142)	<=	'1' and signoX when C < "0000000011000100" else '0';	--196
	distancia(143)	<=	'1' and signoX when C < "0000000010111101" else '0';	--189
	distancia(144)	<=	'1' and signoX when C < "0000000010110111" else '0';	--183
	
	distancia(145)	<=	'1' and signoX when C < "0000000010110000" else '0';	--176
	distancia(146)	<=	'1' and signoX when C < "0000000010101001" else '0';	--169
	distancia(147)	<=	'1' and signoX when C < "0000000010100011" else '0';	--163
	distancia(148)	<=	'1' and signoX when C < "0000000010011101" else '0';	--157
	distancia(149)	<=	'1' and signoX when C < "0000000010010111" else '0';	--151	
	distancia(150)	<=	'1' and signoX when C < "0000000010010001" else '0';	--145
	distancia(151)	<=	'1' and signoX when C < "0000000010001011" else '0';	--139
	distancia(152)	<=	'1' and signoX when C < "0000000010000101" else '0';	--133
	distancia(153)	<=	'1' and signoX when C < "0000000010000000" else '0';	--128
	distancia(154)	<=	'1' and signoX when C < "0000000001111010" else '0';	--122
	
	distancia(155)	<=	'1' and signoX when C < "0000000001110101" else '0';	--117
	distancia(156)	<=	'1' and signoX when C < "0000000001101111" else '0';	--111
	distancia(157)	<=	'1' and signoX when C < "0000000001101010" else '0';	--106
	distancia(158)	<=	'1' and signoX when C < "0000000001100101" else '0';	--101
	distancia(159)	<=	'1' and signoX when C < "0000000001100000" else '0';	--96
	distancia(160)	<=	'1' and signoX when C < "0000000001011011" else '0';	--91
	distancia(161)	<=	'1' and signoX when C < "0000000001010110" else '0';	--86
	distancia(162)	<=	'1' and signoX when C < "0000000001010001" else '0';	--81
	distancia(163)	<=	'1' and signoX when C < "0000000001001100" else '0';	--76
	distancia(164)	<=	'1' and signoX when C < "0000000001000111" else '0';	--71
	
	distancia(165)	<=	'1' and signoX when C < "0000000001000010" else '0';	--66
	distancia(166)	<=	'1' and signoX when C < "0000000000111101" else '0';	--61
	distancia(167)	<=	'1' and signoX when C < "0000000000111001" else '0';	--57
	distancia(168)	<=	'1' and signoX when C < "0000000000110100" else '0';	--52
	distancia(169)	<=	'1' and signoX when C < "0000000000101111" else '0';	--47
	distancia(170)	<=	'1' and signoX when C < "0000000000101011" else '0';	--43
	distancia(171)	<=	'1' and signoX when C < "0000000000100110" else '0';	--38
	distancia(172)	<=	'1' and signoX when C < "0000000000100010" else '0';	--34
	distancia(173)	<=	'1' and signoX when C < "0000000000011101" else '0';	--29
	distancia(174)	<=	'1' and signoX when C < "0000000000011001" else '0';	--25
	
	distancia(175)	<=	'1' and signoX when C < "0000000000010100" else '0';	--20
	distancia(176)	<=	'1' and signoX when C < "0000000000010000" else '0';	--16
	distancia(177)	<=	'1' and signoX when C < "0000000000001011" else '0';	--11
	distancia(178)	<=	'1' and signoX when C < "0000000000000111" else '0';	--7
	distancia(179)	<=	'1' and signoX when C < "0000000000000010" else '0';	--2


	distancia(134)	<=	'1' and signoX when C < "0000000100000101" else '0'; --261 -- 0
	distancia(133)	<=	'1' and signoX when C < "0000000100001110" else '0';	--270 -- 1
	distancia(132)	<=	'1' and signoX when C < "0000000100010111" else '0';	--279
	distancia(131)	<=	'1' and signoX when C < "0000000100100001" else '0';	--289
	distancia(130)	<=	'1' and signoX when C < "0000000100101100" else '0';	--300
	distancia(129)	<=	'1' and signoX when C < "0000000100110111" else '0';	--311
	distancia(128)	<=	'1' and signoX when C < "0000000101000010" else '0';	--322
	distancia(127)	<=	'1' and signoX when C < "0000000101001110" else '0';	--334
	distancia(126)	<=	'1' and signoX when C < "0000000101011010" else '0';	--346
	distancia(125)	<=	'1' and signoX when C < "0000000101100111" else '0';	--359
	
	distancia(124)	<=	'1' and signoX when C < "0000000101110100" else '0';	--372
	distancia(123)	<=	'1' and signoX when C < "0000000110000011" else '0';	--387
	distancia(122)	<=	'1' and signoX when C < "0000000110010010" else '0';	--402
	distancia(121)	<=	'1' and signoX when C < "0000000110100010" else '0';	--418
	distancia(120)	<=	'1' and signoX when C < "0000000110110011" else '0';	--435	
	distancia(119)	<=	'1' and signoX when C < "0000000111000100" else '0';	--452
	distancia(118)	<=	'1' and signoX when C < "0000000111010111" else '0';	--471
	distancia(117)	<=	'1' and signoX when C < "0000000111101100" else '0';	--492
	distancia(116)	<=	'1' and signoX when C < "0000001000000001" else '0';	--513
	distancia(115)	<=	'1' and signoX when C < "0000001000011001" else '0';	--537
	
	distancia(114)	<=	'1' and signoX when C < "0000001000110010" else '0';	--562
	distancia(113)	<=	'1' and signoX when C < "0000001001001101" else '0';	--589
	distancia(112)	<=	'1' and signoX when C < "0000001001101010" else '0';	--618
	distancia(111)	<=	'1' and signoX when C < "0000001010001010" else '0';	--650
	distancia(110)	<=	'1' and signoX when C < "0000001010101101" else '0';	--685
	distancia(109)	<=	'1' and signoX when C < "0000001011010011" else '0';	--723
	distancia(108)	<=	'1' and signoX when C < "0000001011111101" else '0';	--765
	distancia(107)	<=	'1' and signoX when C < "0000001100101100" else '0';	--812
	distancia(106)	<=	'1' and signoX when C < "0000001101100000" else '0';	--864
	distancia(105)	<=	'1' and signoX when C < "0000001110011011" else '0';	--923
	
	distancia(104)	<=	'1' and signoX when C < "0000001111011110" else '0';	--990
	distancia(103)	<=	'1' and signoX when C < "0000010000101010" else '0';	--1066
	distancia(102)	<=	'1' and signoX when C < "0000010010000011" else '0';	--1155
	distancia(101)	<=	'1' and signoX when C < "0000010011101010" else '0';	--1258
	distancia(100)	<=	'1' and signoX when C < "0000010101100101" else '0';	--1381
	distancia(99)	<=	'1' and signoX when C < "0000010111111010" else '0';	--1530
	distancia(98)	<=	'1' and signoX when C < "0000011010110001" else '0';	--1713
	distancia(97)	<=	'1' and signoX when C < "0000011110011001" else '0';	--1945
	distancia(96)	<=	'1' and signoX when C < "0000100011000111" else '0';	--2247
	distancia(95)	<=	'1' and signoX when C < "0000101001100011" else '0';	--2659
	
	distancia(94)	<=	'1' and signoX when C < "0000110010110101" else '0';	--3253
	distancia(93)	<=	'1' and signoX when C < "0001000001011001" else '0';	--4185
	distancia(92)	<=	'1' and signoX when C < "0001011011100111" else '0';	--5863
	distancia(91)	<=	'1' and signoX when C < "0010011000110000" else '0';	--9776
	distancia(90)	<=	'1' and signoX when C < "0111001010010111" else '0';	--29335


	--obtener angulo desde la diagonal
	XOR_array:
	for i in 1 to 179 generate
		oh(i)	<=	distancia(i) xor distancia(i-1);
	end generate;
	oh(0)		<=	distancia(0) nor	distancia(1);
	oh(180)	<=	distancia(178) and	distancia(179);

	nDistancia(0)	<=	oh(1) or oh(3) or oh(5) or oh(7) or oh(9) or oh(11) or oh(13) or oh(15) or oh(17) or oh(19) or oh(21) or oh(23) or oh(25) or oh(27) or oh(29) or oh(31) or oh(33) or oh(35) or oh(37) or oh(39) or oh(41) or oh(43) or oh(45) or oh(47) or oh(49) or oh(51) or oh(53) or oh(55) or oh(57) or oh(59) or oh(61) or oh(63) or oh(65) or oh(67) or oh(69) or oh(71) or oh(73) or oh(75) or oh(77) or oh(79) or oh(81) or oh(83) or oh(85) or oh(87) or oh(89) or oh(91) or oh(93) or oh(95) or oh(97) or oh(99) or oh(101) or oh(103) or oh(105) or oh(107) or oh(109) or oh(111) or oh(113) or oh(115) or oh(117) or oh(119) or oh(121) or oh(123) or oh(125) or oh(127) or oh(129) or oh(131) or oh(133) or oh(135) or oh(137) or oh(139) or oh(141) or oh(143) or oh(145) or oh(147) or oh(149) or oh(151) or oh(153) or oh(155) or oh(157) or oh(159) or oh(161) or oh(163) or oh(165) or oh(167) or oh(169) or oh(171) or oh(173) or oh(175) or oh(177) or oh(179);
	nDistancia(1)	<=	oh(2) or oh(3) or oh(6) or oh(7) or oh(10) or oh(11) or oh(14) or oh(15) or oh(18) or oh(19) or oh(22) or oh(23) or oh(26) or oh(27) or oh(30) or oh(31) or oh(34) or oh(35) or oh(38) or oh(39) or oh(42) or oh(43)or oh(46) or oh(47) or oh(50) or oh(51) or oh(54) or oh(55) or oh(58) or oh(59) or oh(62) or oh(63) or oh(66) or oh(67) or oh(70) or oh(71) or oh(74) or oh(75) or oh(78) or oh(79) or oh(82) or oh(83) or oh(86) or oh(87) or oh(90) or oh(91) or oh(94) or oh(95) or oh(98) or oh(99) or oh(102) or oh(103) or oh(106) or oh(107) or oh(110) or oh(111) or oh(114) or oh(115) or oh(118) or oh(119) or oh(122) or oh(123) or oh(126) or oh(127) or oh(130) or oh(131) or oh(134) or oh(135) or oh(138) or oh(139) or oh(142) or oh(143) or oh(146) or oh(147) or oh(150) or oh(151) or oh(154) or oh(155) or oh(158) or oh(159) or oh(162) or oh(163) or oh(166) or oh(167) or oh(170) or oh(171) or oh(174) or oh(175) or oh(178) or oh(179);
	nDistancia(2)	<=	oh(4) or oh(5) or oh(6) or oh(7) or oh(12) or oh(13) or oh(14) or oh(15) or oh(20) or oh(21) or oh(22) or oh(23) or oh(28) or oh(29) or oh(30) or oh(31) or oh(36) or oh(37) or oh(38) or oh(39) or oh(44) or oh(45) or oh(46) or oh(47) or oh(52) or oh(53) or oh(54) or oh(55) or oh(60) or oh(61) or oh(62) or oh(63) or oh(68) or oh(69) or oh(70) or oh(71) or oh(76) or oh(77) or oh(78) or oh(79) or oh(84) or oh(85) or oh(86) or oh(87) or oh(92) or oh(93) or oh(94) or oh(95) or oh(100) or oh(101) or oh(102) or oh(103) or oh(108) or oh(109) or oh(110) or oh(111) or oh(116) or oh(117) or oh(118) or oh(119) or oh(124) or oh(125) or oh(126) or oh(127) or oh(132) or oh(133) or oh(134) or oh(135) or oh(140) or oh(141) or oh(142) or oh(143) or oh(148) or oh(149) or oh(150) or oh(151) or oh(156) or oh(157) or oh(158) or oh(159) or oh(164) or oh(165) or oh(166) or oh(167) or oh(172) or oh(173) or oh(174) or oh(175);
	nDistancia(3)	<=	oh(8) or oh(9) or oh(10) or oh(11) or oh(12) or oh(13) or oh(14) or oh(15) or oh(24) or oh(25) or oh(26) or oh(27) or oh(28) or oh(29) or oh(30) or oh(31) or oh(40) or oh(41) or oh(42) or oh(43) or oh(44) or oh(45) or oh(46) or oh(47) or oh(56) or oh(57) or oh(58) or oh(59) or oh(60) or oh(61) or oh(62) or oh(63) or oh(72) or oh(73) or oh(74) or oh(75) or oh(76) or oh(77) or oh(78) or oh(79) or oh(88) or oh(89) or oh(90) or oh(91) or oh(92) or oh(93) or oh(94) or oh(95) or oh(104) or oh(105) or oh(106) or oh(107) or oh(108) or oh(109) or oh(110) or oh(111) or oh(120) or oh(121) or oh(122) or oh(123) or oh(124) or oh(125) or oh(126) or oh(127) or oh(136) or oh(137) or oh(138) or oh(139) or oh(140) or oh(141) or oh(142) or oh(143) or oh(152) or oh(153) or oh(154) or oh(155) or oh(156) or oh(157) or oh(158) or oh(159) or oh(168) or oh(169) or oh(170) or oh(171) or oh(172) or oh(173) or oh(174) or oh(175);
	nDistancia(4)	<=	oh(16) or oh(17) or oh(18) or oh(19) or oh(20) or oh(21) or oh(22) or oh(23) or oh(24) or oh(25) or oh(26) or oh(27) or oh(28) or oh(29) or oh(30) or oh(31) or oh(48) or oh(49) or oh(50) or oh(51) or oh(52) or oh(53) or oh(54) or oh(55) or oh(56) or oh(57) or oh(58) or oh(59) or oh(60) or oh(61) or oh(62) or oh(63) or oh(80) or oh(81) or oh(82) or oh(83) or oh(84) or oh(85) or oh(86) or oh(87) or oh(88) or oh(89) or oh(90) or oh(91) or oh(92) or oh(93) or oh(94) or oh(95) or oh(112) or oh(113) or oh(114) or oh(115) or oh(116) or oh(117) or oh(118) or oh(119) or oh(120) or oh(121) or oh(122) or oh(123) or oh(124) or oh(125) or oh(126) or oh(127) or oh(144) or oh(145) or oh(146) or oh(147) or oh(148) or oh(149) or oh(150) or oh(151) or oh(152) or oh(153) or oh(154) or oh(155) or oh(156) or oh(157) or oh(158) or oh(159) or oh(176) or oh(177) or oh(178) or oh(179);
	nDistancia(5)	<=	oh(32) or oh(33) or oh(34) or oh(35) or oh(36) or oh(37) or oh(38) or oh(39) or oh(40) or oh(41) or oh(42) or oh(43) or oh(44) or oh(45) or oh(46) or oh(47) or oh(48) or oh(49) or oh(50) or oh(51) or oh(52) or oh(53) or oh(54) or oh(55) or oh(56) or oh(57) or oh(58) or oh(59) or oh(60) or oh(61) or oh(62) or oh(63) or oh(96) or oh(97) or oh(98) or oh(99) or oh(100) or oh(101) or oh(102) or oh(103) or oh(104) or oh(105) or oh(106) or oh(107) or oh(108) or oh(109) or oh(110) or oh(111) or oh(112) or oh(113) or oh(114) or oh(115) or oh(116) or oh(117) or oh(118) or oh(119) or oh(120) or oh(121) or oh(122) or oh(123) or oh(124) or oh(125) or oh(126) or oh(127) or oh(160) or oh(161) or oh(162) or oh(163) or oh(164) or oh(165) or oh(166) or oh(167) or oh(168) or oh(169) or oh(170) or oh(171) or oh(172) or oh(173) or oh(174) or oh(175) or oh(176) or oh(177) or oh(178) or oh(179);
	nDistancia(6)	<=	oh(64) or oh(65) or oh(66) or oh(67) or oh(68) or oh(69) or oh(70) or oh(71) or oh(72) or oh(73) or oh(74) or oh(75) or oh(76) or oh(77) or oh(78) or oh(79) or oh(80) or oh(81) or oh(82) or oh(83) or oh(84) or oh(85) or oh(86) or oh(87) or oh(88) or oh(89) or oh(90) or oh(91) or oh(92) or oh(93) or oh(94) or oh(95) or oh(96) or oh(97) or oh(98) or oh(99) or oh(100) or oh(101) or oh(102) or oh(103) or oh(104) or oh(105) or oh(106) or oh(107) or oh(108) or oh(109) or oh(110) or oh(111) or oh(112) or oh(113) or oh(114) or oh(115) or oh(116) or oh(117) or oh(118) or oh(119) or oh(120) or oh(121) or oh(122) or oh(123) or oh(124) or oh(125) or oh(126) or oh(127);
	nDistancia(7)	<=	oh(128) or oh(129) or oh(130) or oh(131) or oh(132) or oh(133) or oh(134) or oh(135) or oh(136) or oh(137) or oh(138) or oh(139) or oh(140) or oh(141) or oh(142) or oh(143) or oh(144) or oh(145) or oh(146) or oh(147) or oh(148) or oh(149) or oh(150) or oh(151) or oh(152) or oh(153) or oh(154) or oh(155) or oh(156) or oh(157) or oh(158) or oh(159) or oh(160) or oh(161) or oh(162) or oh(163) or oh(164) or oh(165) or oh(166) or oh(167) or oh(168) or oh(169) or oh(170) or oh(171) or oh(172) or oh(173) or oh(174) or oh(175) or oh(176) or oh(177) or oh(178) or oh(179);
	
	--obtener angulo final
	angulo	<=	nDistancia;
--	op1	<=	45 - nDistancia;
--	op2	<=	45 + nDistancia;
--	op3	<=	135 - nDistancia;
--	op4	<=	135 + nDistancia;
--	selector		<=	signoX & mayor;
--	with	(selector)	select
--		angulo	<=	op1	when "00",
--						op2	when "01",
--						op3	when "11",
--						op4	when "10";
	
--	angulo	<=	45 - nDistancia	when	(signoX='0' and mayor='0')	else
--					45 + nDistancia	when	(signoX='0' and mayor='1')	else
--					135 - nDistancia	when	(signoX='1' and mayor='1')	else
--					135 + nDistancia	when	(signoX='1' and mayor='0')	else
--					(others => '0');
	
	
--	decoder_oh:
--	for i in 0 to 44 generate
--		comparador_if:
--		if	(one_hot(i) = '1') generate
--			nDistancia	<=	std_logic_vector(i+1);
--		end generate;
----		one_hot	<=	distancia(i) xor distancia(i+1);
--	end generate;
----	nDistancia(0)	<=	'1' when C > "0000000100000101" else '0';
	
	
--	process (distancia)
--	begin
--		case distancia is
--			when	"000000000000000000000000000000000000000000000"	=>		nDistancia		<=	"00000000";
--			when	"000000000000000000000000000000000000000000001"	=>		nDistancia		<=	"00000001";
--			when	"000000000000000000000000000000000000000000011"	=>		nDistancia		<=	"00000010";
--			when	"000000000000000000000000000000000000000000111"	=>		nDistancia		<=	"00000011";
--			when	"000000000000000000000000000000000000000001111"	=>		nDistancia		<=	"00000100";
--			when	"000000000000000000000000000000000000000011111"	=>		nDistancia		<=	"00000101";
--			when	"000000000000000000000000000000000000000111111"	=>		nDistancia		<=	"00000110";
--			when	"000000000000000000000000000000000000001111111"	=>		nDistancia		<=	"00000111";
--			when	"000000000000000000000000000000000000011111111"	=>		nDistancia		<=	"00001000";
--			when	"000000000000000000000000000000000000111111111"	=>		nDistancia		<=	"00001001";
--			when	"000000000000000000000000000000000001111111111"	=>		nDistancia		<=	"00001010";
--			when	"000000000000000000000000000000000011111111111"	=>		nDistancia		<=	"00001011";
--			when	"000000000000000000000000000000000111111111111"	=>		nDistancia		<=	"00001100";
--			when	"000000000000000000000000000000001111111111111"	=>		nDistancia		<=	"00001101";
--			when	"000000000000000000000000000000011111111111111"	=>		nDistancia		<=	"00001110";
--			when	"000000000000000000000000000000111111111111111"	=>		nDistancia		<=	"00001111";
--			
--			when	"000000000000000000000000000001111111111111111"	=>		nDistancia		<=	"00010000";
--			when	"000000000000000000000000000011111111111111111"	=>		nDistancia		<=	"00010001";
--			when	"000000000000000000000000000111111111111111111"	=>		nDistancia		<=	"00010010";
--			when	"000000000000000000000000001111111111111111111"	=>		nDistancia		<=	"00010011";
--			when	"000000000000000000000000011111111111111111111"	=>		nDistancia		<=	"00010100";
--			when	"000000000000000000000000111111111111111111111"	=>		nDistancia		<=	"00010101";
--			when	"000000000000000000000001111111111111111111111"	=>		nDistancia		<=	"00010110";
--			when	"000000000000000000000011111111111111111111111"	=>		nDistancia		<=	"00010111";
--			when	"000000000000000000000111111111111111111111111"	=>		nDistancia		<=	"00011000";
--			when	"000000000000000000001111111111111111111111111"	=>		nDistancia		<=	"00011001";
--			when	"000000000000000000011111111111111111111111111"	=>		nDistancia		<=	"00011010";
--			when	"000000000000000000111111111111111111111111111"	=>		nDistancia		<=	"00011011";
--			when	"000000000000000001111111111111111111111111111"	=>		nDistancia		<=	"00011100";
--			when	"000000000000000011111111111111111111111111111"	=>		nDistancia		<=	"00011101";
--			when	"000000000000000111111111111111111111111111111"	=>		nDistancia		<=	"00011110";
--			when	"000000000000001111111111111111111111111111111"	=>		nDistancia		<=	"00011111";
--			
--			when	"000000000000011111111111111111111111111111111"	=>		nDistancia		<=	"00100000";
--			when	"000000000000111111111111111111111111111111111"	=>		nDistancia		<=	"00100001";
--			when	"000000000001111111111111111111111111111111111"	=>		nDistancia		<=	"00100010";
--			when	"000000000011111111111111111111111111111111111"	=>		nDistancia		<=	"00100011";
--			when	"000000000111111111111111111111111111111111111"	=>		nDistancia		<=	"00100100";
--			when	"000000001111111111111111111111111111111111111"	=>		nDistancia		<=	"00100101";
--			when	"000000011111111111111111111111111111111111111"	=>		nDistancia		<=	"00100110";
--			when	"000000111111111111111111111111111111111111111"	=>		nDistancia		<=	"00100111";
--			
--			when	"000001111111111111111111111111111111111111111"	=>		nDistancia		<=	"00101000";
--			when	"000011111111111111111111111111111111111111111"	=>		nDistancia		<=	"00101001";
--			when	"000111111111111111111111111111111111111111111"	=>		nDistancia		<=	"00101010";
--			when	"001111111111111111111111111111111111111111111"	=>		nDistancia		<=	"00101011";
--			when	"011111111111111111111111111111111111111111111"	=>		nDistancia		<=	"00101100";
--			when	"111111111111111111111111111111111111111111111"	=>		nDistancia		<=	"00101101";
--			
--			when others	=>	nDistancia		<=	"11111111";
--		end case;
--	end process;
	
--	nDistancia		<=	"00000000" when distancia = "000000000000000000000000000000000000000000000" else
--							"00000001" when distancia = "000000000000000000000000000000000000000000001" else
--							"00000010" when distancia = "000000000000000000000000000000000000000000011" else
--							"00000011" when distancia = "000000000000000000000000000000000000000000111" else
--							"00000100" when distancia = "000000000000000000000000000000000000000001111" else
--							"00000101" when distancia = "000000000000000000000000000000000000000011111" else
--							"00000110" when distancia = "000000000000000000000000000000000000000111111" else
--							"00000111" when distancia = "000000000000000000000000000000000000001111111" else
--							"00001000" when distancia = "000000000000000000000000000000000000011111111" else
--							"00001001" when distancia = "000000000000000000000000000000000000111111111" else
--							"00001010" when distancia = "000000000000000000000000000000000001111111111" else
--							"00001011" when distancia = "000000000000000000000000000000000011111111111" else
--							"00001100" when distancia = "000000000000000000000000000000000111111111111" else
--							"00001101" when distancia = "000000000000000000000000000000001111111111111" else
--							"00001110" when distancia = "000000000000000000000000000000011111111111111" else
--							"00001111" when distancia = "000000000000000000000000000000111111111111111" else
--							
--							"00010000" when distancia = "000000000000000000000000000001111111111111111" else
--							"00010001" when distancia = "000000000000000000000000000011111111111111111" else
--							"00010010" when distancia = "000000000000000000000000000111111111111111111" else
--							"00010011" when distancia = "000000000000000000000000001111111111111111111" else
--							"00010100" when distancia = "000000000000000000000000011111111111111111111" else
--							"00010101" when distancia = "000000000000000000000000111111111111111111111" else
--							"00010110" when distancia = "000000000000000000000001111111111111111111111" else
--							"00010111" when distancia = "000000000000000000000011111111111111111111111" else
--							"00011000" when distancia = "000000000000000000000111111111111111111111111" else
--							"00011001" when distancia = "000000000000000000001111111111111111111111111" else
--							"00011010" when distancia = "000000000000000000011111111111111111111111111" else
--							"00011011" when distancia = "000000000000000000111111111111111111111111111" else
--							"00011100" when distancia = "000000000000000001111111111111111111111111111" else
--							"00011101" when distancia = "000000000000000011111111111111111111111111111" else
--							"00011110" when distancia = "000000000000000111111111111111111111111111111" else
--							"00011111" when distancia = "000000000000001111111111111111111111111111111" else
--							
--							"00100000" when distancia = "0000000000000" else
--							"00100001" when distancia = "0000000000001" else
--							"00100010" when distancia = "0000000000011" else
--							"00100011" when distancia = "0000000000111" else
--							"00100100" when distancia = "0000000001111" else
--							"00100101" when distancia = "0000000011111" else
--							"00100110" when distancia = "0000000111111" else
--							"00100111" when distancia = "0000001111111" else
--							"00101000" when distancia = "0000011111111" else
--							"00101001" when distancia = "0000111111111" else
--							"00101010" when distancia = "0001111111111" else
--							"00101011" when distancia = "0011111111111" else
--							"00101100" when distancia = "0111111111111" else
--							"00101101" when distancia = "1111111111111" else
--							"11111111";
	
	
--	process (distancia)
--		variable	acum : std_logic_vector(7 downto 0)	:= "00000000";
--	begin
--		acum	:=	"00000000";
--		for i in 0 to 44 loop
--			if(distancia(i) = '1') then
--				acum	:= acum + 1;
--			else
--				acum	:= acum;
--			end if;
--		end loop;
--		nDistancia	<=	acum;
--	end process;				

	signo		<=	signoY;
	--angulo	<=	nDistancia;
	--flag		<=	mayor;
end rtl;