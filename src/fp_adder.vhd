library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity fp_adder is 
    generic(
        EXP_WIDTH  : integer := 11; -- EXPONENT WIDTH (Float := 8 , Double := 11 )
        MANT_WIDTH : integer := 52 -- MANTISSA WIDTH (Float := 23, Double := 52 )
    );
    port(
        i_clk_100MHz : in std_ulogic;
        i_nrst_async : in std_ulogic;
        i_operand_a  : in std_ulogic_vector(1+EXP_WIDTH+MANT_WIDTH-1 downto 0);
        i_operand_b  : in std_ulogic_vector(1+EXP_WIDTH+MANT_WIDTH-1 downto 0);
        o_result     : out std_ulogic_vector(1+EXP_WIDTH+MANT_WIDTH-1 downto 0)
        );
end entity fp_adder;

architecture RTL of fp_adder is 
    -- stage 1 signals 
    signal sign_a      : std_ulogic := '0';
    signal sign_b      : std_ulogic := '0';
    signal exponent_a  : std_ulogic_vector(EXP_WIDTH-1 downto 0) := (others => '0');
    signal exponent_b  : std_ulogic_vector(EXP_WIDTH-1 downto 0) := (others => '0');
    signal mantissa_a  : std_ulogic_vector(MANT_WIDTH-1 downto 0) := (others => '0');
    signal mantissa_b  : std_ulogic_vector(MANT_WIDTH-1 downto 0) := (others => '0');
    -- stage 2 signals 
    signal larger_num  : std_ulogic_vector(1+EXP_WIDTH+MANT_WIDTH-1 downto 0) := (others => '0');
    signal smaller_num : std_ulogic_vector(1+EXP_WIDTH+MANT_WIDTH-1 downto 0) := (others => '0');
    signal exponent_diff : std_ulogic_vector(EXP_WIDTH-1 downto 0) := (others => '0');
    signal eq_mag_same_sign_stage2 : std_ulogic := '0';
    signal eq_mag_opp_sign_stage2 : std_ulogic := '0';
    -- stage 3 signals
    signal guard_bit : std_ulogic := '0';
    signal round_bit : std_ulogic := '0';
    signal sticky_bit : std_ulogic := '0';
    signal large_significand : std_ulogic_vector(1+MANT_WIDTH+3-1 downto 0) := (others => '0');
    signal small_significand : std_ulogic_vector(1+MANT_WIDTH+3-1 downto 0) := (others => '0');
    signal result_sign_stage3 : std_ulogic := '0';
    signal eq_mag_same_sign_stage3 : std_ulogic := '0';
    signal eq_mag_opp_sign_stage3 : std_ulogic := '0';
    signal operation : std_ulogic := '0';
    signal result_exponent_stage3 : std_ulogic_vector(EXP_WIDTH-1 downto 0) := (others => '0');
    -- stage 4 signals 
    signal temp_sum : std_ulogic_vector(1+MANT_WIDTH+3-1 downto 0) := (others => '0');
    signal sum : std_ulogic_vector(1+MANT_WIDTH+3-1 downto 0) := (others => '0');
    signal carry : std_ulogic := '0'; 
    signal result_exponent_stage4 : std_ulogic_vector(EXP_WIDTH-1 downto 0) := (others => '0');
    signal result_sign_stage4 : std_ulogic := '0';
    
    

    begin 
        -- Stage 1 : Fetch stage : fetch the sign,exponent and mantissa from the two operands
        proc_fetch : process(i_clk_100MHz,i_nrst_async) is 
            begin 
                if(i_nrst_async = '0') then 
                    sign_a <= '0';
                    sign_b <= '0';
                    exponent_a <= (others => '0');
                    exponent_b <= (others => '0');
                    mantissa_a <= (others => '0');
                    mantissa_b <= (others => '0');
                elsif(rising_edge(i_clk_100MHz)) then 
                    sign_a <= i_operand_a(i_operand_a'high);
                    sign_b <= i_operand_b(i_operand_b'high);
                    exponent_a <= i_operand_a(EXP_WIDTH+MANT_WIDTH-1 downto MANT_WIDTH);
                    exponent_b <= i_operand_b(EXP_WIDTH+MANT_WIDTH-1 downto MANT_WIDTH);
                    mantissa_a <= i_operand_a(MANT_WIDTH-1 downto 0);
                    mantissa_b <= i_operand_b(MANT_WIDTH-1 downto 0);
                end if;
        end process proc_fetch;

        -- Stage 2 : Preparation stage : Identify the Large number, Small number and the Exponent Difference (Shift Amount).
        proc_prep : process(i_clk_100MHz,i_nrst_async) is 
            begin 
                if (i_nrst_async = '0') then 
                    larger_num <= (others => '0');
                    smaller_num <= (others => '0');
                    exponent_diff <= (others => '0');
                    eq_mag_same_sign_stage2 <= '0';
                    eq_mag_opp_sign_stage2 <= '0';
                elsif(rising_edge(i_clk_100MHz)) then 
                    eq_mag_same_sign_stage2 <= '0';
                    eq_mag_opp_sign_stage2 <= '0';
                    if (exponent_a > exponent_b) then 
                        larger_num  <= i_operand_a;
                        smaller_num <= i_operand_b;
                        exponent_diff <= std_ulogic_vector(unsigned(exponent_a)-unsigned(exponent_b));
                    elsif (exponent_a = exponent_b) then 
                        if(mantissa_a > mantissa_b) then 
                            larger_num  <= i_operand_a;
                            smaller_num <= i_operand_b;
                            exponent_diff <= (others => '0');
                        elsif(mantissa_a = mantissa_b) then 
                            if (sign_a = sign_b) then
                                larger_num <= i_operand_a;
                                smaller_num <= i_operand_b;
                                exponent_diff <= (others => '0');
                                eq_mag_same_sign_stage2 <= '1';
                            else 
                                if (sign_a = '1') then 
                                    larger_num <= i_operand_b;
                                    smaller_num <= i_operand_a;
                                else 
                                    larger_num <= i_operand_a;
                                    smaller_num <= i_operand_b;
                                end if;
                                exponent_diff <= (others => '0');
                                eq_mag_opp_sign_stage2 <= '1';
                            end if;
                        else 
                            larger_num  <= i_operand_b;
                            smaller_num <= i_operand_a;
                            exponent_diff <= (others => '0');
                        end if;
                    else  
                        larger_num  <= i_operand_b;
                        smaller_num <= i_operand_a;
                        exponent_diff <= std_ulogic_vector(unsigned(exponent_b)-unsigned(exponent_a));
                    end if;
                end if;
        end process proc_prep;

        -- Stage 3 : Denormalizer stage: Determine the operation, Exponent of the larger #, Significand Large, Significand Small,     
        proc_denormalizer: process(i_clk_100MHz,i_nrst_async) is 
            begin 
                if(i_nrst_async = '0') then 
                    guard_bit <= '0';
                    round_bit <= '0';
                    sticky_bit <= '0';
                    large_significand <= (others => '0');
                    small_significand <= (others => '0');
                    result_sign_stage3 <= '0';
                    eq_mag_same_sign_stage3 <= '0';
                    eq_mag_opp_sign_stage3 <= '0';
                    operation <= '0';
                    result_exponent_stage3 <= (others => '0');
                elsif(rising_edge(i_clk_100MHz)) then 
                    eq_mag_same_sign_stage3 <= eq_mag_same_sign_stage2;
                    eq_mag_opp_sign_stage3 <= eq_mag_opp_sign_stage2;
                    large_significand <= '1' & larger_num(MANT_WIDTH-1 downto 0) & guard_bit & round_bit & sticky_bit;
                    small_significand <= '1' & smaller_num(MANT_WIDTH-1 downto 0) & guard_bit & round_bit & sticky_bit;
                    ----------------------HAVE TO CHANGE THE SHIFT-------------------------------------------------------
                    small_significand <= std_ulogic_vector(unsigned('1' & smaller_num(MANT_WIDTH-1 downto 0) & guard_bit & round_bit & sticky_bit) srl to_integer(unsigned(exponent_diff))); -- HAVE TO CHANGE THIS 
                    ------------------------------------------------------------------------------------------------------
                    operation <= larger_num(0) xor smaller_num(0);
                    result_exponent_stage3 <= larger_num(EXP_WIDTH+MANT_WIDTH-1 downto MANT_WIDTH);
                    result_sign_stage3 <= larger_num(0);
                end if;
        end process proc_denormalizer;

        -- Stage 4: Significand addition : Determine the sum and the carry 
        proc_significand : process(i_clk_100MHz,i_nrst_async) is 
            begin 
                if(i_nrst_async = '0') then 
                    temp_sum <= (others => '0');
                    sum <= (others => '0');
                    carry <= '0';
                    result_exponent_stage4 <= (others => '0');
                    result_sign_stage4 <= '0';
                elsif(rising_edge(i_clk_100MHz)) then
                    result_exponent_stage4 <= result_exponent_stage3;
                    result_sign_stage4 <= result_sign_stage3;
                    ----- FIX THE LOGIC FOR ADDITION AND CAPTURING THE CARRY
                    if (operation = '0') then 
                        temp_sum <= std_ulogic_vector(unsigned(large_significand)+unsigned(small_significand));
                    elsif (operation = '1') then 
                        temp_sum <= std_ulogic_vector(unsigned(large_significand) - unsigned(small_significand)); -- Which is basically the sum of the large_significand and 2's complement of the small_significand
                    end if;
                    sum <= temp_sum(temp_sum'high downto 0);
                    carry <= temp_sum(temp_sum'high);
                end if;
        end process proc_significand;


                    
            
                





                    


    

end architecture RTL;
