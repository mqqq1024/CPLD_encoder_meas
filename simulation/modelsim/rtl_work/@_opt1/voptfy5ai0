library verilog;
use verilog.vl_types.all;
entity encoder_meas is
    port(
        clk             : in     vl_logic;
        mcu_n_rst       : in     vl_logic;
        mcu_start       : in     vl_logic;
        mcu_end         : out    vl_logic;
        mcu_sync        : out    vl_logic;
        mcu_rd_clk      : in     vl_logic;
        mcu_data        : out    vl_logic_vector(7 downto 0);
        mcu_data_sel    : in     vl_logic_vector(2 downto 0);
        ch_sgn_in       : in     vl_logic_vector(14 downto 0);
        ch_c_in         : in     vl_logic_vector(2 downto 0);
        ch_sync         : in     vl_logic;
        ram_nrd         : out    vl_logic;
        ram_nwr         : out    vl_logic;
        ram_ncs         : out    vl_logic;
        ram_addr        : out    vl_logic_vector(19 downto 0);
        ram_data        : inout  vl_logic_vector(7 downto 0)
    );
end encoder_meas;
