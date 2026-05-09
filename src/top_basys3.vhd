--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        btnL    :   in std_logic; -- clk reset
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals

  component sevenseg_decoder is
        port (
            i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
            o_seg_n : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component sevenseg_decoder;
    
    component TDM4 is
	generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
    Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	);
    end component TDM4;
    
    component clock_divider is
	generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
											   -- Effectively, you divide the clk double this 
											   -- number (e.g., k_DIV := 2 --> clock divider of 4)
	port ( 	i_clk    : in std_logic;
			i_reset  : in std_logic;		   -- asynchronous
			o_clk    : out std_logic		   -- divided (slow) clock
	);
    end component clock_divider;
    
    component ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
    end component ALU;
    
    component controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
    end component controller_fsm;
    
    component twos_comp is
    port (
        i_bin: in std_logic_vector(7 downto 0);
        o_sign: out std_logic;
        o_hund: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0)
    );
    end component twos_comp;
    
    component button_debounce is
	Port(	clk: in  STD_LOGIC;
			reset : in  STD_LOGIC;
			button: in STD_LOGIC;
			action: out STD_LOGIC);
    end component button_debounce;
    
    signal w_A : std_logic_vector ( 7 downto 0);
    signal w_B : std_logic_vector ( 7 downto 0);
    signal w_state : std_logic_vector ( 3 downto 0);
    signal w_tdm_clk : std_logic;
    signal w_op : std_logic_vector ( 2 downto 0);
    signal w_result : std_logic_vector ( 7 downto 0);
    signal w_flags : std_logic_vector ( 3 downto 0);
    signal w_disp : std_logic_vector ( 7 downto 0);
    signal w_hund : std_logic_vector ( 3 downto 0);
    signal w_ten : std_logic_vector ( 3 downto 0);
    signal w_one : std_logic_vector ( 3 downto 0);
    signal w_sign : std_logic;
    signal w_sign_processed : std_logic_vector ( 3 downto 0);
    signal w_tdm_data : std_logic_vector ( 3 downto 0);
    signal w_sevensego : std_logic_vector ( 6 downto 0);
    signal w_BtnC_one : std_logic;
begin
	-- PORT MAPS ----------------------------------------
    debounce : button_debounce
	Port map(	
	        clk => clk,
			reset => '0',
			button => BtnC,
			action => w_BtnC_one
			);
    
    
    fsm : controller_fsm
    Port map( 
           i_reset => BtnU,
           i_adv => w_BtnC_one,
           o_cycle => w_state
           );
           
    clk_1 : clock_divider 
    generic map(
        K_DIV => 5000
        )
        port map (
            i_clk    => clk,
            i_reset  => BtnL,		   -- asynchronous
            o_clk    => w_tdm_clk
    );
    
    get_A : process (w_state, sw)
        begin
        
        if w_state = "0001" then
            w_A <= sw (7 downto 0);
            end if;
            
	end process get_A;
	
	get_B : process (w_state, sw)
        begin
        
        if w_state = "0010" then
            w_B <= sw (7 downto 0);
            end if;
            
	end process get_B;
	
	get_op : process (w_state, sw)
        begin
        
        if w_state = "0100" then
            w_op <= sw (2 downto 0);
            end if;
            
	end process get_op;
	
	Logic_unit : ALU
	   Port map ( 
	       i_A => w_A,
           i_B => w_B,
           i_op => w_op,
           o_result => w_result,
           o_flags => w_flags
           );
           
    disp_mux : process (w_state,w_A,w_B,w_result)
        begin
        
        if w_state = "0001" then
            w_disp <= "00000000";
        elsif w_state = "0010" then
            w_disp <= w_A;
        elsif w_state = "0100" then
            w_disp <= w_B;
        elsif w_state = "1000" then
            w_disp <= w_result;
        else 
            w_disp <= "00000000";
        end if;
        
        end process disp_mux;
        
    twos_comp_0 :  twos_comp
    port map(
        i_bin => w_disp,
        o_sign => w_sign,
        o_hund => w_hund,
        o_tens => w_ten,
        o_ones => w_one
    );
    
    handle_sign : process (w_sign)
        begin
        
        if w_sign = '1' then  --negative
            w_sign_processed <= "1111";
        elsif w_sign = '0' then --positive
            w_sign_processed <= "1100";
        end if;
        
    end process handle_sign;
    
    
    TDM : TDM4 
	   generic map(k_WIDTH => 4) -- bits in input and output
        Port map( 
          i_clk	=> w_tdm_clk,
          i_reset	=> '0',
          i_D3 => w_sign_processed,
		  i_D2 => w_hund,
		  i_D1 => w_ten,
		  i_D0 => w_one,
		  o_data	=> w_tdm_data,
		  o_sel => an (3 downto 0)
	   );
	
	sevenseg : sevenseg_decoder
        port map(
            i_Hex => w_tdm_data,
            o_seg_n => w_sevensego
        );
	
	
	
    sign_disp : process (w_tdm_data,w_sevensego,w_state)
        begin
        
        if w_tdm_data = "1111" then
            seg (6 downto 0) <= "0111111";
        elsif w_tdm_data = "1100" then
            seg (6 downto 0) <= "1111111";
        else 
            seg (6 downto 0) <= w_sevensego;
        end if;
        if w_state = "0001" then
            seg (6 downto 0) <= "1111111";
        end if;
    end process sign_disp;
         

	-- CONCURRENT STATEMENTS ----------------------------
	led(3 downto 0) <= w_state;
	led(15 downto 12) <= w_flags;
	led(11 downto 4) <= "00000000";
	
end top_basys3_arch;
