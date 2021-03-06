-- This file is part of the Omega CPU Core
-- Copyright 2015 - 2016 Joseph Shetaye

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use IEEE.Numeric_std.all;

entity MemoryController is

  port (
    CLK         : in  std_logic;
    Address     : in  word;
    Enable      : in  std_logic;
    ToWrite     : in  word;
    FromRead    : out word;
    Instruction : in  word;
    Reset       : in  std_logic;
    Done        : out std_logic;
	 SRAM_addr     : out std_logic_vector(20 downto 0);
    SRAM_OE       : out std_logic;
    SRAM_CE       : out std_logic;
    SRAM_WE       : out std_logic;
    SRAM_data     : inout  std_logic_vector(7 downto 0);
	 Status_Debug  : out std_logic_vector(7 downto 0)
	 );
  
end MemoryController;

architecture Behavioral of MemoryController is

 constant LoadByteUnsigned : Operator := "000";
 constant LoadByteSigned : Operator := "001";
 constant LoadHalfWordUnsigned : Operator := "010";
 constant LoadHalfWordSigned : Operator := "011";
 constant LoadWord : Operator := "100";
 constant StoreByte : Operator := "101";
 constant StoreHalfWord : Operator := "110";
 constant StoreWord : Operator := "111";
 
 -- outputTest (absolute jump)
 --constant BootImage : MemoryArray := ("01000001","00000000","00100000","00100100","00000000","00000000","00100001","10110100","00000001","00000000","00000000","11000100","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000");
 -- outputTest (relative jump)
 constant BootImage : MemoryArray := ("01000001","00000000","00100000","00100100","00000000","00000000","00100001","10110100","11111111","11111111","11111111","11001011","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000");
 -- ROT13
 --constant BootImage : MemoryArray := ("00000000","00000000","10000001","10100100","01000001","00000000","00100100","01110100","00001010","00000000","00100000","11011000","01011011","00000000","00100100","01110100","00001001","00000000","00100000","11011000","01100001","00000000","00100100","01110100","00000110","00000000","00100000","11011000","01111011","00000000","00100100","01110100","00001100","00000000","00100000","11011000","00000011","00000000","00000000","11001000","00000000","00000000","10000001","10110100","11110101","11111111","11111111","11001011","11111110","11111111","11111111","11001011","10111111","11111111","10000100","00100100","00001101","00000000","10000100","00100100","00011010","00000000","00100100","01110100","00000010","00000000","00100000","11011000","11100110","11111111","10000100","00100100","01000001","00000000","10000100","00100100","11110111","11111111","11111111","11001011","10011111","11111111","10000100","00100100","00001101","00000000","10000100","00100100","00011010","00000000","00100100","01110100","00000010","00000000","00100000","11011000","11100110","11111111","10000100","00100100","01100001","00000000","10000100","00100100","11110000","11111111","11111111","11001011","00000000","00000000","00000000");--(others => (others => '0'));
 signal FromRead_S : Word := (others => '0');
 signal NeedsInit : std_logic := '1';
 signal BootImageIndex : Integer := 0;
 signal Done_s : std_logic := '0';
 signal SRAM_addr_s : std_logic_vector(20 downto 0) := (others => '0');
 signal SRAM_data_s : std_logic_vector(7 downto 0); --:= (others => 'Z');
 signal SRAM_OE_s : std_logic := '1';
 signal SRAM_WE_s : std_logic := '1';
 signal SRAM_CE_s : std_logic := '1';
 signal AddressOffset : integer := 0;
 signal Status_Debug_s : std_logic_vector(7 downto 0) := (others => '0');
begin  -- Behavioral

  SRAM_addr <= SRAM_addr_s;
  SRAM_data <= SRAM_data_s when SRAM_OE_s = '1' else (others => 'Z');
  SRAM_OE <= SRAM_OE_s;
  SRAM_WE <= SRAM_WE_s;
  SRAM_CE <= '0';
    FromRead <= FromRead_S;
	 Done <= Done_s;
	 Status_Debug <= Status_Debug_S;
  
  process (CLK)--(Enable, Instruction, Address, Reset)
--     procedure initialize is begin
--        Memory(0) <= "00000000";
--        Memory(1) <= "00000000";
--        Memory(2) <= "10000001";
--        Memory(3) <= "10100100";
--        Memory(4) <= "01000001";
--        Memory(5) <= "00000000";
--        Memory(6) <= "00100100";
--        Memory(7) <= "01110100";
--        Memory(8) <= "00001010";
--        Memory(9) <= "00000000";
--        Memory(10) <= "00100000";
--        Memory(11) <= "11011000";
--        Memory(12) <= "01011011";
--        Memory(13) <= "00000000";
--        Memory(14) <= "00100100";
--        Memory(15) <= "01110100";
----        Memory(16) <= "00001001";
----        Memory(17) <= "00000000";
----        Memory(18) <= "00100000";
----        Memory(19) <= "11011000";
----        Memory(20) <= "01100001";
----        Memory(21) <= "00000000";
----        Memory(22) <= "00100100";
----        Memory(23) <= "01110100";
----        Memory(24) <= "00000110";
----        Memory(25) <= "00000000";
----        Memory(26) <= "00100000";
----        Memory(27) <= "11011000";
----        Memory(28) <= "01111011";
----        Memory(29) <= "00000000";
----        Memory(30) <= "00100100";
----        Memory(31) <= "01110100";
----        Memory(32) <= "00001100";
----        Memory(33) <= "00000000";
----        Memory(34) <= "00100000";
----        Memory(35) <= "11011000";
----        Memory(36) <= "00000011";
----        Memory(37) <= "00000000";
----        Memory(38) <= "00000000";
----        Memory(39) <= "11001000";
----        Memory(40) <= "00000000";
----        Memory(41) <= "00000000";
----        Memory(42) <= "10000001";
----        Memory(43) <= "10110100";
----        Memory(44) <= "11110101";
----        Memory(45) <= "11111111";
----        Memory(46) <= "11111111";
----        Memory(47) <= "11001011";
----        Memory(48) <= "11111110";
----        Memory(49) <= "11111111";
----        Memory(50) <= "11111111";
----        Memory(51) <= "11001011";
----        Memory(52) <= "10111111";
----        Memory(53) <= "11111111";
----        Memory(54) <= "10000100";
----        Memory(55) <= "00100100";
----        Memory(56) <= "00001101";
----        Memory(57) <= "00000000";
----        Memory(58) <= "10000100";
----        Memory(59) <= "00100100";
----        Memory(60) <= "00011010";
----        Memory(61) <= "00000000";
----        Memory(62) <= "00100100";
----        Memory(63) <= "01110100";
----        Memory(64) <= "00000010";
----        Memory(65) <= "00000000";
----        Memory(66) <= "00100000";
----        Memory(67) <= "11011000";
----        Memory(68) <= "11100110";
----        Memory(69) <= "11111111";
----        Memory(70) <= "10000100";
----        Memory(71) <= "00100100";
----        Memory(72) <= "01000001";
----        Memory(73) <= "00000000";
----        Memory(74) <= "10000100";
----        Memory(75) <= "00100100";
----        Memory(76) <= "11110111";
----        Memory(77) <= "11111111";
----        Memory(78) <= "11111111";
----        Memory(79) <= "11001011";
----        Memory(80) <= "10011111";
----        Memory(81) <= "11111111";
----        Memory(82) <= "10000100";
----        Memory(83) <= "00100100";
----        Memory(84) <= "00001101";
----        Memory(85) <= "00000000";
----        Memory(86) <= "10000100";
----        Memory(87) <= "00100100";
----        Memory(88) <= "00011010";
----        Memory(89) <= "00000000";
----        Memory(90) <= "00100100";
----        Memory(91) <= "01110100";
----        Memory(92) <= "00000010";
----        Memory(93) <= "00000000";
----        Memory(94) <= "00100000";
----        Memory(95) <= "11011000";
----        Memory(96) <= "11100110";
----        Memory(97) <= "11111111";
----        Memory(98) <= "10000100";
----        Memory(99) <= "00100100";
----        Memory(100) <= "01100001";
----        Memory(101) <= "00000000";
----        Memory(102) <= "10000100";
----        Memory(103) <= "00100100";
----        Memory(104) <= "11110000";
----        Memory(105) <= "11111111";
----        Memory(106) <= "11111111";
----        Memory(107) <= "11001011";
--      --for I in 100 to 4095 loop
--		--	Memory(I) <= "00000000";
--		--end loop;
--     end procedure initialize;
	  variable current_operator : std_logic_vector(2 downto 0);
  begin  -- process
  if rising_edge(CLK) then
    if NeedsInit = '1' then
	   if BootImageIndex = BootImage'Length then
			SRAM_we_s <= '1';
--			SRAM_addr_s <= "000000000000001101011";
--			SRAM_oe_s <= '0';
--			BootImageIndex <= BootImageIndex + 1;
--		elsif BootImageIndex = (BootImage'Length + 1) then
			NeedsInit <= '0';
--			Status_Debug_S <= SRAM_data xor "11111111";
			SRAM_oe_s <= '1';
		else
			SRAM_data_s <= BootImage(BootImageIndex);
			SRAM_addr_s <= std_logic_vector(to_unsigned(BootImageIndex,21));
		   SRAM_we_s <= '0';
			BootImageIndex <= BootImageIndex + 1;
		end if;
      --Memory <= (others => (others => '0'));
--		initialize;
    elsif Enable = '1' then
	 current_operator := GetOperator(Instruction);
    case current_operator is
      when LoadByteUnsigned =>
		  if SRAM_oe_s = '1' then
				SRAM_addr_s <= Address(20 downto 0);
				SRAM_oe_s <= '0';
				Done_s <= '0';
			else
				FromRead_S <= "000000000000000000000000" & SRAM_data;
				SRAM_oe_s <= '1';
				Done_s <= '1';
			end if;
      when LoadByteSigned =>
		  if SRAM_oe_s = '1' then
				SRAM_addr_s <= Address(20 downto 0);
				SRAM_oe_s <= '0';
				Done_s <= '0';
			else
				FromRead_S <= std_logic_vector(resize(signed(SRAM_data),32));
				SRAM_oe_s <= '1';
				Done_s <= '1';
			end if;
      when LoadHalfWordUnsigned =>
			if SRAM_oe_s = '1' then
				SRAM_addr_s <= Address(20 downto 0);
				SRAM_oe_s <= '0';
				AddressOffset <= 0;
				Done_s <= '0';
		   elsif AddressOffset < 1 then
				SRAM_addr_s <= std_logic_vector(unsigned(Address(20 downto 0)) + to_unsigned(AddressOffset + 1,20));
				AddressOffset <= AddressOffset + 1;
				FromRead_S(8*AddressOffset+7 downto 8*AddressOffset) <= SRAM_data;
			else
				FromRead_S(8*AddressOffset+7 downto 8*AddressOffset) <= SRAM_data;
				FromRead_S(31 downto 16) <= (others => '0');
				AddressOffset <= 0;
				SRAM_oe_s <= '1';
				Done_s <= '1';
			end if;
      when LoadHalfWordSigned =>
			if SRAM_oe_s = '1' then
				SRAM_addr_s <= Address(20 downto 0);
				SRAM_oe_s <= '0';
				AddressOffset <= 0;
				Done_s <= '0';
		   elsif AddressOffset < 1 then
				SRAM_addr_s <= std_logic_vector(unsigned(Address(20 downto 0)) + to_unsigned(AddressOffset + 1,20));
				AddressOffset <= AddressOffset + 1;
				FromRead_S(8*AddressOffset+7 downto 8*AddressOffset) <= SRAM_data;
			else
				FromRead_S(8*AddressOffset+7 downto 8*AddressOffset) <= SRAM_data;
				if SRAM_data(7) = '1' then
				   FromRead_S(31 downto 16) <= "1111111111111111";
				else
				   FromRead_S(31 downto 16) <= "0000000000000000";
				end if;
				AddressOffset <= 0;
				SRAM_oe_s <= '1';
				Done_s <= '1';
			end if;
      when LoadWord =>
			if SRAM_oe_s = '1' then
				SRAM_addr_s <= Address(20 downto 0);
				SRAM_oe_s <= '0';
				AddressOffset <= 0;
				Done_s <= '0';
		   elsif AddressOffset < 3 then
				SRAM_addr_s <= std_logic_vector(unsigned(Address(20 downto 0)) + to_unsigned(AddressOffset+1,20));
				FromRead_S(8*AddressOffset+7 downto 8*AddressOffset) <= SRAM_data;
				AddressOffset <= AddressOffset + 1;
			else
				FromRead_S(8*AddressOffset+7 downto 8*AddressOffset) <= SRAM_data;
				AddressOffset <= 0;
				SRAM_oe_s <= '1';
				Done_s <= '1';
				Status_Debug_S <= Address(9 downto 2) xor "11111111";
			end if;
      when StoreByte =>
--        Memory(to_integer(unsigned(Address))) <= ToWrite(7 downto 0);
         Done_s <= '1';
      when StoreHalfWord =>
--        Memory(to_integer(unsigned(Address))) <= ToWrite(7 downto 0);
--        Memory(to_integer(unsigned(Address)) + 1) <= ToWrite(15 downto 8);
         Done_s <= '1';
      when StoreWord =>
--        Memory(to_integer(unsigned(Address))) <= ToWrite(7 downto 0);
--        Memory(to_integer(unsigned(Address)) + 1) <= ToWrite(15 downto 8);
--        Memory(to_integer(unsigned(Address)) + 2) <= ToWrite(23 downto 16);
--        Memory(to_integer(unsigned(Address)) + 3) <= ToWrite(31 downto 24);
         Done_s <= '1';
      when others => null;
    end case;
  else
    SRAM_oe_s <= '1';
	 SRAM_we_s <= '1';
    Done_s <= '0';
  end if;
  end if;
  end process;

end Behavioral;
