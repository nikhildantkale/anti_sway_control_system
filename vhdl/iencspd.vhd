----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:18:17 11/30/2012 
-- Design Name: 
-- Module Name:    iencspd - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
--arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity iencspd is
	 generic(IECTR_size : integer := 16);
    Port ( iclk : in  STD_LOGIC;
           ireset : in  STD_LOGIC;
           iclear : in  STD_LOGIC;
           tra : in  STD_LOGIC;
           trb : in  STD_LOGIC;
           latchp : in  STD_LOGIC;
           sumreg : out  STD_LOGIC_VECTOR (IECTR_size-1 downto 0);
           impreg : out  STD_LOGIC_VECTOR (IECTR_size-1 downto 0);
           tmrreg : out  STD_LOGIC_VECTOR (19 downto 0));
end iencspd;

architecture Mixed of iencspd is

constant  TIMER_WORD : integer := 20;
subtype register_imp is std_logic_vector(IECTR_size-1 downto 0);
subtype register_tmr is std_logic_vector(TIMER_WORD-1 downto 0);

signal  a0_0, a0_1, b0_0, b0_1 : std_logic;
signal  up_pulse, dn_pulse : std_logic;
signal  sctr, ictr, sum_buf, imp_buf : register_imp;
signal  itmr, tmr_buf : register_tmr;
signal  tmr_gate : std_logic;
TYPE state_type IS (armed, capture, idle);
SIGNAL  state, next_state : state_type;


begin
	a0_ff: FD
	-- synthesis translate_off
	generic map (INIT => '0')
	-- synthesis translate_on
	port map (Q => a0_0,
	C => iclk,
	D => tra );

	a1_ff: FD
	-- synthesis translate_off
	generic map (INIT => '0')
	-- synthesis translate_on
	port map (Q => a0_1,
	C => iclk,
	D => a0_0 );

	b0_ff: FD
	-- synthesis translate_off
	generic map (INIT => '0')
	-- synthesis translate_on
	port map (Q => b0_0,
	C => iclk,
	D => trb );

	b1_ff: FD
	-- synthesis translate_off
	generic map (INIT => '0')
	-- synthesis translate_on
	port map (Q => b0_1,
	C => iclk,
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
 
   sumreg <= sum_buf;
   impreg <= imp_buf;
   tmrreg <= tmr_buf;

	seq_fsm: PROCESS(iclk, next_state, ireset, iclear,
						  up_pulse, dn_pulse, sctr, ictr, itmr)
	BEGIN
		IF iclk'event AND iclk='1' THEN
			IF ireset='1' OR iclear='1' THEN
				sctr <= (others => '0');
				ictr <= (others => '0');
				itmr <= (others => '0');
				tmr_gate <= '0';
				state <= armed;
			ELSE
				IF up_pulse='1' THEN
					sctr <= sctr + 1;
				ELSIF dn_pulse='1' THEN
					sctr <= sctr - 1;
				END IF;
				IF next_state=armed THEN
					IF tmr_gate='1' THEN
						itmr <= itmr + 1;
					END IF;
					IF up_pulse='1' THEN
						tmr_gate <= '1';
						ictr <= ictr + 1;
						imp_buf <= ictr;
						tmr_buf <= itmr;
					ELSIF dn_pulse='1' THEN
						tmr_gate <= '1';
						ictr <= ictr - 1;
						imp_buf <= ictr;
						tmr_buf <= itmr;
					END IF;
				ELSIF next_state=capture THEN
					sum_buf <= sctr;
					tmr_gate <= '0';
					ictr <= (others => '0');
					itmr <= (others => '0');
				END IF;
				state <= next_state;
			END IF;
		END IF;
	END PROCESS seq_fsm;

   comb_fsm: PROCESS(state, latchp)
	BEGIN
		next_state <= state;
		CASE state IS
			WHEN armed =>
				IF latchp='1' THEN
					next_state <= capture;
				END IF;
			WHEN capture =>
				next_state <= idle;
			WHEN idle =>
				IF latchp='0' THEN
					next_state <= armed;
				END IF;
		END CASE;
	END PROCESS comb_fsm;

end Mixed;
