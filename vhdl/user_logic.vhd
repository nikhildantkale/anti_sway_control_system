------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Thu Nov 13 14:26:31 2014 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--   C_NUM_REG                    -- Number of software accessible registers
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_SLV_DWIDTH                   : integer              := 32;
    C_NUM_REG                      : integer              := 10
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
	 cpcu_Leds : out std_logic_vector(7 downto 0);
	 cpcu_Switch : in std_logic_vector(3 downto 0);
	 cpcu_Pushb : in std_logic_vector(2 downto 0);
	 cpcu_Rotbtn : in std_logic;
	 cpcu_Rotbk : in std_logic_vector(0 to 1);
	 cpcu_Cartp : in std_logic_vector(0 to 1);
	 cpcu_Penda : in std_logic_vector(0 to 1);
	 cpcu_Sw_left : in std_logic;
	 cpcu_Sw_right : in std_logic;
	 cpcu_Amp_ok : in std_logic;
	 cpcu_Amp_ena : out std_logic;
	 cpcu_Lcd : out std_logic_vector(0 to 6);
	 cpcu_SPI_MOSI : out std_logic;
	 cpcu_SPI_SCLK : out std_logic;
	 cpcu_DAC_CS : out std_logic;
	 cpcu_DAC_CLR : out std_logic;
	 cpcu_SPI_SS_B : out std_logic;
	 cpcu_AMP_CS : out std_logic;
	 cpcu_AD_CONV : out std_logic;
	 cpcu_FPGA_INIT_B : out std_logic;
    --USER ports added here
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(0 to C_SLV_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_SLV_DWIDTH/8-1);
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    IP2Bus_Data                    : out std_logic_vector(0 to C_SLV_DWIDTH-1);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Reset  : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

  --USER signal declarations added here, as needed for user logic
  	--
	-- declaration rotor encoder interface
	--
	component rotenc_8
		Port ( inc_a : in  STD_LOGIC;
				 inc_b : in  STD_LOGIC;
			inc_latch : in  STD_LOGIC;
			  clr_pos : in  STD_LOGIC;
			  inc_pos : out  STD_LOGIC_VECTOR (7 downto 0);
			  inc_clk : in  STD_LOGIC;
			inc_reset : in  STD_LOGIC);
	end component;

  	--
	-- incremental encoder (generic)
	--
	component iencspd is
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
	end component;

  	--
	-- declaration of SPI transmitter for DAC
	--
	component spis24 is
		Port ( sysclk : in  STD_LOGIC;
			  sreset : in STD_LOGIC;
			  spistart : in  STD_LOGIC;
			  spdin : in  STD_LOGIC_VECTOR (23 downto 0);
			  sck : out STD_LOGIC;
			  sdo : out STD_LOGIC;
			  spidone : out  STD_LOGIC);
	end component;


	signal rotpos_i : std_logic_vector(0 to 7);
	signal switch_r : std_logic_vector(3 downto 0);
	signal pushb_r : std_logic_vector(2 downto 0);
	signal rotbtn_r : std_logic;
	signal spidone_i : std_logic;
	signal pos16_i, imp16_i : std_logic_vector(0 to 15);
	signal pos20_i, imp20_i : std_logic_vector(0 to 19);
	signal timer_lin, timer_ang : std_logic_vector(0 to 19);


  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg1                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg2                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg3                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg4                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg5                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg6                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg7                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg8                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg9                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg_write_sel              : std_logic_vector(0 to 9);
  signal slv_reg_read_sel               : std_logic_vector(0 to 9);
  signal slv_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

begin

  --USER logic implementation added here
  cpcu_Leds <= slv_reg0(24 to 31);
  cpcu_DAC_CS <= NOT slv_reg2(0);	-- DAC chip select = '1'!
  cpcu_DAC_CLR <= NOT slv_reg2(1);	-- DAC clear all = '1'!
  cpcu_Amp_ena <= slv_reg5(31);		-- bit 0 of reg 5 enables servo amp
  cpcu_SPI_SS_B <= '1';					-- disable SPI flash
  cpcu_AMP_CS <= '1';					-- disable pre-amplifier
  cpcu_AD_CONV <= '0';					-- disable ADC
  cpcu_FPGA_INIT_B <= '1';			-- disable writing to platform flash ROM

  -- LCD interface (bit notations for software!)
  -- -------------------------------------------------------------------
  -- |   6   |    5   |   4    |    3    |    2    |    1    |    0    |
  -- -------------------------------------------------------------------
  -- | LCD_E | LCD_RS | LCD_RW | LCD_DB7 | LCD_DB6 | LCD_DB5 | LCD_DB4 |
  -- -------------------------------------------------------------------
  cpcu_Lcd <= slv_reg1(25 to 31);
  -- onboard rotary knob
  rot8if: rotenc_8
	port map ( inc_a => cpcu_Rotbk(0),
			     inc_b => cpcu_Rotbk(1),
		    inc_latch => slv_reg3(31),
		      clr_pos => slv_reg3(30),
		      inc_pos => rotpos_i,
		      inc_clk => Bus2IP_Clk,
		    inc_reset => Bus2IP_Reset);

  incre_16: iencspd
  generic map (IECTR_size => 16)
  port map ( iclk => Bus2IP_Clk,
           ireset => Bus2IP_Reset,
           iclear => slv_reg3(30),
           tra => cpcu_Penda(0),
           trb => cpcu_Penda(1),
           latchp => slv_reg3(31),
           sumreg => pos16_i,
           impreg => imp16_i,
           tmrreg => timer_ang);

  incre_20: iencspd
  generic map (IECTR_size => 20)

  port map ( iclk => Bus2IP_Clk,
           ireset => Bus2IP_Reset,
           iclear => slv_reg3(30),
           tra => cpcu_Cartp(0),
           trb => cpcu_Cartp(1),
           latchp => slv_reg3(31),
           sumreg => pos20_i,
           impreg => imp20_i,
           tmrreg => timer_lin);

  dacif: spis24
  port map ( sysclk => Bus2IP_Clk,
			  sreset => Bus2IP_Reset,
			  spistart => slv_reg2(2),
			  spdin => slv_reg2(8 to 31),
			  sck => cpcu_SPI_SCLK,
			  sdo => cpcu_SPI_MOSI,
			  spidone => spidone_i);


  -- avoid signal change during read access
  syncread : PROCESS (Bus2IP_Clk, rotpos_i) is
  BEGIN
		IF Bus2IP_Clk'event AND Bus2IP_Clk = '1' THEN
			IF slv_read_ack = '0' THEN
				switch_r <= cpcu_Switch;
				pushb_r <= cpcu_Pushb;
				rotbtn_r <= cpcu_Rotbtn;
			END IF;
		END IF;
  END PROCESS syncread;


  ------------------------------------------
  -- Example code to read/write user logic slave model s/w accessible registers
  -- 
  -- Note:
  -- The example code presented here is to show you one way of reading/writing
  -- software accessible registers implemented in the user logic slave model.
  -- Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  -- to one software accessible register by the top level template. For example,
  -- if you have four 32 bit software accessible registers in the user logic,
  -- you are basically operating on the following memory mapped registers:
  -- 
  --    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  --                     "1000"   C_BASEADDR + 0x0
  --                     "0100"   C_BASEADDR + 0x4
  --                     "0010"   C_BASEADDR + 0x8
  --                     "0001"   C_BASEADDR + 0xC
  -- 
  ------------------------------------------
  slv_reg_write_sel <= Bus2IP_WrCE(0 to 9);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 to 9);
  slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2) or Bus2IP_WrCE(3) or Bus2IP_WrCE(4) or Bus2IP_WrCE(5) or Bus2IP_WrCE(6) or Bus2IP_WrCE(7) or Bus2IP_WrCE(8) or Bus2IP_WrCE(9);
  slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2) or Bus2IP_RdCE(3) or Bus2IP_RdCE(4) or Bus2IP_RdCE(5) or Bus2IP_RdCE(6) or Bus2IP_RdCE(7) or Bus2IP_RdCE(8) or Bus2IP_RdCE(9);

  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Reset = '1' then
        slv_reg0 <= (others => '0');
        slv_reg1 <= (others => '0');
        slv_reg2 <= (others => '0');
        slv_reg3 <= (others => '0');
        slv_reg4 <= (others => '0');
        slv_reg5 <= (others => '0');
        slv_reg6 <= (others => '0');
        slv_reg7 <= (others => '0');
        slv_reg8 <= (others => '0');
        slv_reg9 <= (others => '0');
      else
        case slv_reg_write_sel is
          when "1000000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0100000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg1(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0010000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg2(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0001000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg3(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000100000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg4(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000010000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg5(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000001000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg6(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000000100" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg7(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000000010" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg8(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000000001" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg9(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0, slv_reg1, slv_reg2, slv_reg3,
											slv_reg4, slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9,
											spidone_i, pos20_i, pos16_i, imp20_i, imp16_i,
											timer_lin, timer_ang,
											rotpos_i, switch_r, pushb_r, rotbtn_r,
											cpcu_Sw_left, cpcu_Sw_right, cpcu_Amp_ok) is
  begin

    case slv_reg_read_sel is
      when "1000000000" => slv_ip2bus_data <= slv_reg0(0 to 24) & pushb_r & switch_r;
      when "0100000000" => slv_ip2bus_data <= slv_reg1(0 to 22) & rotbtn_r & rotpos_i;
      when "0010000000" => slv_ip2bus_data <= slv_reg2(0 to 30) & spidone_i;
      when "0001000000" => slv_ip2bus_data <= "000000000000" & pos20_i;
      when "0000100000" => slv_ip2bus_data <= "0000000000000000" & pos16_i;
      when "0000010000" => slv_ip2bus_data 
				<= "00000000000000000000000000000" & cpcu_Sw_left & cpcu_Sw_right & cpcu_Amp_ok;
      when "0000001000" => slv_ip2bus_data <= "000000000000" & imp20_i;
      when "0000000100" => slv_ip2bus_data <= "000000000000" & timer_lin;
      when "0000000010" => slv_ip2bus_data <= "0000000000000000" & imp16_i;
      when "0000000001" => slv_ip2bus_data <= "000000000000" & timer_ang;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  (others => '0');

  IP2Bus_WrAck <= slv_write_ack;
  IP2Bus_RdAck <= slv_read_ack;
  IP2Bus_Error <= '0';

end IMP;
