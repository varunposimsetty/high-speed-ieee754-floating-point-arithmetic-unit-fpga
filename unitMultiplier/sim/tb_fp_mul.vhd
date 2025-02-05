library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity tb is 
end entity tb;

architecture bhv of tb is
    signal clk : std_ulogic := '0';
    signal rst : std_ulogic := '0';
    signal num_1 : std_ulogic_vector(63 downto 0) := (others => '0');
    signal num_2 : std_ulogic_vector(63 downto 0) := (others => '0');
    signal result : std_ulogic_vector(63 downto 0) := (others => '0');

    begin 

    FU_ADDER : entity work.fp_mul(RTL) 
    port map(
        i_clk_100MHz => clk,
        i_nrst_async => rst,
        i_operand_1  => num_1,
        i_operand_2  => num_2,
        o_result     => result
    );

    proc_clock_gen : process is
        begin
            wait for 5 ns;
            clk <= not clk;
        end process proc_clock_gen;

    proc_tb : process is 
        begin 
            wait for 100 ns;
            rst <= '1';
            wait for 50 ns;
            num_1 <=  x"3FE0000000000000";
            wait for 200 ns;
            num_2 <= x"3FF0000000000000";
            wait for 200 ns;
            num_1 <= x"4000000000000000"; 
            wait for 200 ns;
            num_2 <= x"4010000000000000";
            wait for 200 ns;
            num_1 <= x"3FD0000000000000";
            wait for 200 ns;
            num_2 <= x"4020000000000000";
            wait for 200 ns;
            num_1 <= x"3FA3B4C6E8D9F123";
            wait for 300 ns;
            num_2 <= x"A1D39048F263E7B6";
            wait for 300 ns;
            num_1 <= x"5CFD28B739A0D1E4";
            wait for 300 ns;
            num_2 <= x"8BD5E7A9C24F6B18";
            wait for 200 ns;
            num_1 <= x"4F1A3C7E9B2D8F65";
            wait for 300 ns;
            num_2 <=  x"9C5E1A48B7D2F036";
            wait for 200 ns;
            num_1 <= x"7A3F6E8D5C2B9A14";
            wait for 200 ns;
            num_2 <= x"D8A3C9B5617E4F02";
            wait for 200 ns;
            num_1 <= x"E4B9A7D5C2F1386B";
            wait for 300 ns;
            num_2 <= x"D3A7C9E5F1B68408";
            wait for 200 ns;
            num_1 <= x"4040000000000000";
            wait for 200 ns;
            num_2 <= x"BFE0000000000000";
            wait for 200 ns;
            num_1 <= x"BFE0000000000000";
            wait for 200 ns;
            num_2 <=  x"3FE0000000000000";
            wait for 200 ns;
            num_1 <= x"BFF0000000000000";
            wait for 200 ns;
            num_2 <= x"8000000000000001";
            wait for 200 ns;
            num_1 <= x"3FF0000000000000";
            wait for 200 ns;
            num_2 <= x"0000000000000001";
            wait for 200 ns;
            num_1 <= x"BFF0000000000000";
            wait for 200 ns;
            num_1 <= x"3FF0000000000000"; 
            wait for 200 ns;
            num_2 <= x"BFF0000000000000";
            wait for 200 ns;
            num_1 <= x"4000000000000000"; 
            wait for 200 ns;
            num_2 <= x"3FF0000000000000"; 
            wait for 200 ns;
            num_1 <= x"0000000000000001"; 
            wait for 200 ns;
            num_2 <= x"3FF0000000000000"; 
            wait for 200 ns; 
            num_1 <= x"0000000000000001"; 
            wait for 200 ns;
            num_2 <= x"0000000000000002"; 
            wait for 200 ns;
            num_1 <= x"BFF0000000000000"; 
            wait for 200 ns;
            num_2 <= x"FFEFFFFFFFFFFFFF"; 
            wait for 200 ns;
            num_1 <= x"3FF0000000000000"; 
            wait for 200 ns;
            num_2 <= x"7FEFFFFFFFFFFFFF"; 
            wait for 200 ns;
            num_1 <= x"7FF8000000000000"; 
            wait for 200 ns;
            num_2 <= x"0000000000000000"; 
            wait for 200 ns;
            wait;
    end process proc_tb;
end architecture bhv;


