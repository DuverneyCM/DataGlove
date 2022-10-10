library ieee;
use ieee.std_logic_1164.all;
use work.spi_param.all;

entity spi_fsm_controller is

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
		
--		output	: out	std_logic_vector(1 downto 0)
	);

end entity;

architecture rtl of spi_fsm_controller is
	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3);
	-- Register to hold the current state
	signal	state		:	state_type;
	signal	setup		:	std_logic;
	signal	cnt		:	integer range 0 to 31;
	signal	sDataOut	:	std_logic_vector(15 downto 0);
	
	constant	Setup_step	:	natural	:=	14;
	constant	step_end		:	natural	:=	19;

begin

	-- Logic to advance to the next state
	process (clk, reset)
	begin
		if reset = '0' then
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
					if iSPI_END = '1' then
						state <= s2;
					else
						state <= s1;
					end if;
				when s2=>
					if	cnt < Setup_step	then
						cnt	<=	cnt + 1;
						setup <= '1';
						state <= s3;
					else
						if cnt	= step_end then
							cnt	<=	Setup_step;
							state <= s0;
						else
							cnt	<=	cnt + 1;
							state <= s3;
						end if;
						setup	<=	'0'; 
					end if;
					
				when s3=>
					state <= s1;
					
				when others	=>	null;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state)
	begin
		case state is
			when s0 =>
				oSPI_go <= '0';
			when s1 =>
				oSPI_go <= '1';
			when s2 =>
				oSPI_go <= '0';
			when s3 =>
				oSPI_go <= '0';
		end case;
	end process;
	
	process (cnt)
	begin
		case cnt is
			--config, setup = 1
			when 0 =>
				sDataOut	<=	"00" & THRESH_ACT & "00100000";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	THRESH_ACT;		Data	<=	"00100000";
			when 1 =>
				sDataOut	<=	"00" & THRESH_INACT & "00000011";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	THRESH_INACT;	Data	<=	"00000011";
			when 2 =>
				sDataOut	<=	"00" & TIME_INACT & "00000001";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	TIME_INACT;		Data	<=	"00000001";
			when 3 =>
				sDataOut	<=	"00" & ACT_INACT_CTL & "01111111";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	ACT_INACT_CTL;	Data	<=	"01111111";
			when 4 =>
				sDataOut	<=	"00" & THRESH_FF & "00001001";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	THRESH_FF;		Data	<=	"00001001";
			when 5 =>
				sDataOut	<=	"00" & TIME_FF & "01000110";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	TIME_FF;			Data	<=	"01000110";
			when 6 =>
				sDataOut	<=	"00" & BW_RATE & "00001010";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	BW_RATE;			Data	<=	"00001001"; --1110 -> 1600Hz		1010 -> 100Hz
			when 7 =>
				sDataOut	<=	"00" & INT_ENABLE & "00010000";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	INT_ENABLE;		Data	<=	"00010000";
			when 8 =>
				sDataOut	<=	"00" & INT_MAP & "00010000";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	INT_MAP;			Data	<=	"00010000";
			when 9 =>
				sDataOut	<=	"00" & DATA_FORMAT & "01001011";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	DATA_FORMAT;	Data	<=	"01001011"; --11 -> 16g		1 -> full Res		1 -> 3wire
			when 10	=>
				sDataOut	<=	"00" & POWER_CONTROL & "00001000";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	POWER_CONTROL;	Data	<=	"00001000"; --1 -> meseaure
			---------------------------------------------------------------------------------------------------
			when 11	=>
				sDataOut	<=	"00" & OFSX & "00000000";
			when 12	=>
				sDataOut	<=	"00" & OFSX & "00000000";
			when 13	=>
				sDataOut	<=	"00" & OFSX & "00000000";
			
			--fin de setup, setup=0
			--Lectura de registros
			when 14	=>
				sDataOut	<=	"10" & X_HB & "10101010";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	X_HB;				Data	<=	"10101010";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	X_LB;				Data	<=	"00000000";
			when 15	=>
				sDataOut	<=	"10" & X_LB & "10101010";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	X_LB;				Data	<=	"00000000";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	X_HB;				Data	<=	"10101010";
			when 16	=>
				sDataOut	<=	"10" & Y_HB & "10101010";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	Y_HB;				Data	<=	"00000000";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	Y_LB;				Data	<=	"01010101";
			when 17	=>
				sDataOut	<=	"10" & Y_LB & "10101010";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	Y_LB;				Data	<=	"00000000";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	Y_HB;				Data	<=	"00000000";
			when 18	=>
				sDataOut	<=	"10" & Z_HB & "10101010";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	Z_HB;				Data	<=	"00000000";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	Z_LB;				Data	<=	"00000000";
			when 19	=>
				sDataOut	<=	"10" & Z_LB & "10101010";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	Z_LB;				Data	<=	"00000000";
				--R_nW	<=	'1';		MB	<=	'0';	Address	<=	Z_HB;				Data	<=	"00000000";
			
			when others	=>
				sDataOut	<=	"00" & "000000" & "00000000";
				--R_nW	<=	'0';		MB	<=	'0';	Address	<=	"000000";	Data	<=	"00000000";
		end case;
				
	end process;
	
	R_nW		<=	sDataOut(15);
	MB			<=	sDataOut(14);
	Address	<=	sDataOut(13 downto 8);
	Data		<=	sDataOut(7 downto 0);

end rtl;
