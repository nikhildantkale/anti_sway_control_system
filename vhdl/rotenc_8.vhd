----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:07:04 06/27/2010 
-- Design Name: 
-- Module Name:    rotenc_8 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity rotenc_8 is
	Port ( inc_a : in  STD_LOGIC;
	       inc_b : in  STD_LOGIC;
	   inc_latch : in  STD_LOGIC;
	     clr_pos : in  STD_LOGIC;
	     inc_pos : out  STD_LOGIC_VECTOR (7 downto 0);
	     inc_clk : in  STD_LOGIC;
		inc_reset : in  STD_LOGIC);
end rotenc_8;

architecture Mixed of rotenc_8 is

signal  a0_0, a0_1, b0_0, b0_1 : std_logic;
signal  up_pulse, dn_pulse : std_logic;
signal  ictr, read_buf : std_logic_vector(7 downto 0);
TYPE state_type IS (armed, capture, idle);
SIGNAL  state, next_state : state_type;


begin
	a0_ff: FD
	-- synthesis translate_off
	generic map (INIT => '0')
	-- synthesis translate_on
	port map (Q => a0_0,
	C => inc_clk,
	D => inc_a );

	a1_ff: FD
	-- synthesis translate_off
	generic map (INIT => '0')
	-- synthesis translate_on
	port map (Q => a0_1,
	C => inc_clk,
	D => a0_0 );

	b0_ff: FD
	-- synthesis translate_off
	generic map (INIT => '0')
	-- synthesis translate_on
	port map (Q => b0_0,
	C => inc_clk,
	D => inc_b );

	b1_ff: FD
	-- synthesis translate_off
	generic map (INIT => '0')
	-- synthesis translate_on
	port map (Q => b0_1,
	C => inc_clk,
	D => b0_0 );

	updet_lut: LUT4
	generic map (INIT => X"2814")
	port map( I0 => a0_1,
      	    I1 => a0_0,
         	 I2 => b0_1,
           	 I3 => b0_0,
             O => up_pulse );

	dwndet_lut: LUT4
	generic map (INIT => X"4182")
	port map( I0 => a0_1,
      	    I1 => a0_0,
         	 I2 => b0_1,
             I3 => b0_0,
         	 O => dn_pulse );

	-- position measurement counter
	udcnt : PROCESS(inc_clk, up_pulse, dn_pulse, clr_pos)
	BEGIN
   	IF inc_clk='1' AND inc_clk'event THEN
			IF clr_pos='1' THEN
				ictr <= X"80";
			ELSE
				IF up_pulse='1' THEN
					IF ictr /= x"FF" THEN
						ictr <= ictr + 1;
					END IF;
				ELSIF dn_pulse='1' THEN
					IF ictr /= x"00" THEN
						ictr <= ictr - 1;
					END IF;
				END IF;
			END IF;
   	END IF;
	END PROCESS udcnt;
 
   inc_pos <= read_buf;

	latch_fsm: PROCESS(inc_clk, next_state, inc_reset, ictr)
	BEGIN
		IF inc_clk'event AND inc_clk='1' THEN
			IF inc_reset='1' THEN
				state <= armed;
			ELSE
				IF next_state=capture THEN
					read_buf <= ictr;
				END IF;
				state <= next_state;
			END IF;
		END IF;
	END PROCESS latch_fsm;

   latch_nsl: PROCESS(state, inc_latch)
	BEGIN
		next_state <= state;
		CASE state IS
			WHEN armed =>
				IF inc_latch='1' THEN
					next_state <= capture;
				END IF;
			WHEN capture =>
				next_state <= idle;
			WHEN idle =>
				IF inc_latch='0' THEN
					next_state <= armed;
				END IF;
		END CASE;
	END PROCESS latch_nsl;

end Mixed;
