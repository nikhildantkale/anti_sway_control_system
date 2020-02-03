----------------------------------------------------------------------------------
-- Company:        Univ Bremerhaven
-- Engineer:       Kai Mueller
-- 
-- Create Date:    21:12:23 06/25/2011 
-- Design Name: 
-- Module Name:    spis24 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:    24 bit SPI write state machine (for LTC2624 DAC)
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spis24 is
    Port ( sysclk : in  STD_LOGIC;
			  sreset : in STD_LOGIC;
           spistart : in  STD_LOGIC;
           spdin : in  STD_LOGIC_VECTOR (23 downto 0);
			  sck : out STD_LOGIC;
			  sdo : out STD_LOGIC;
           spidone : out  STD_LOGIC);
end spis24;


architecture Behavioral of spis24 is
CONSTANT TXBITS : NATURAL := 24;
TYPE state_type IS (idle, txs0, txs1, leadout);
SIGNAL  state, next_state : state_type;
SIGNAL  tx_count : NATURAL RANGE 0 TO TXBITS-1;
SIGNAL  sck_i, sdo_i : STD_LOGIC;

begin

	-- outputs
	sdo <= sdo_i;
	sck <= sck_i;

	-- sequential block of transmitter
	txproc : PROCESS(sysclk, sreset, state, next_state)
	BEGIN
		IF sysclk'event AND sysclk='1' THEN
			sck_i <= '0';
			IF sreset='1' THEN
				state <= idle;
			ELSE
				state <= next_state;
				IF state=idle THEN
					tx_count <= 23;
					sdo_i <= '0';
				ELSIF state=txs0 THEN
					sdo_i <= spdin(tx_count);
				ELSIF state=txs1 THEN
					sck_i <= '1';
					tx_count <= tx_count - 1;
				END IF;
			END IF;
		END IF;
	END PROCESS txproc;

	-- combinational logic block of tansmitter
	clproc : PROCESS (state, spistart, tx_count)
	BEGIN
		next_state <= state;
		spidone <= '0';
		case state IS
			WHEN idle =>
				spidone <= '1';
				IF spistart='1' THEN
					next_state <= txs0;
				END IF;
			WHEN txs0 =>
				next_state <= txs1;
			WHEN txs1 =>
				IF tx_count=0 THEN
					next_state <= leadout;
				ELSE
					next_state <= txs0;
				END IF;
			WHEN leadout =>
				next_state <= idle;
		END CASE;
	END PROCESS clproc;

end Behavioral;
