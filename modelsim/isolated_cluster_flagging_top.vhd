-- isolated cluster flagging module
-- drop in module which can be added or removed from post router.
-- checks whether any clusters have no hits in neighbouring columns and sets a
-- flag bit so that the cluster in question can be bypassed in the CPU.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.AMC40_pack.all;
use work.Constant_Declaration.all;
use work.detector_constant_declaration.all;

library work;
use work.GDP_pack.all;

entity isolated_cluster_flagger_top is
    port (
        --inputs
        -- post_router_top interface
        i_Clock_160MHz      : in  std_logic; -- clk
        i_reset             : in  std_logic; -- reset or bxid delay reset

        i_sppram_id         : in natural range 0 to 15; -- id of the ram giving the data
        i_sppram_id_dv 	    : in std_logic;
        i_ram_counter       : in std_logic_vector(sppram_w_seg_size - 1 downto 0);
        -- inflactionary_block interface
        i_infl_bus          : in std_logic_vector(511 downto 0); -- output of inflactionary_block

        --output
        -- edge_detector interface
        o_sppram_id         : out natural range 0 to 15;
        o_sppram_id_dv 	    : out std_logic;
        o_ram_counter       : out std_logic_vector(sppram_w_seg_size - 1 downto 0);
        -- output_fifo interface
        o_fifo_bus          : out std_logic_vector(511 downto 0)
);
end isolated_cluster_flagger_top;

architecture a of isolated_cluster_flagger_top is

    component icf_processor is
        port (
            i_Clock_160MHz      : in  std_logic;
            i_reset             : in  std_logic;

            i_enable            : in std_logic;
            i_sppram_id_dv 	    : in std_logic;
            i_ram_counter       : in std_logic_vector(sppram_w_seg_size - 1 downto 0);
            i_bus               : in std_logic_vector(511 downto 0)

            o_enable            : out std_logic;
            o_sppram_id_dv 	    : out std_logic;
            o_ram_counter       : out std_logic_vector(sppram_w_seg_size - 1 downto 0)
            o_bus               : out std_logic_vector(511 downto 0)
        );
    end component;

    -- SIGNALS
    signal dp_i_enable          : std_logic_vector(15 downto 0);
    signal dp_o_enable          : std_logic_vector(15 downto 0);

begin
    --generate 16 processors -- their enable determines when they should interact with the shared pipes
    begin gen_processor:
	for i in 0 to 15 generate
		ICF_PROCESSOR : icf_processor
		port map(
            i_Clock_160MHz,
            i_reset,

			dp_i_enable(i),
			i_sppram_id_dv,
			i_ram_counter,
            i_bus, -- shared input data pipe

			o_enable(i),
			o_sppram_id_dv,
			o_ram_counter,
    		o_bus -- shared input data pipe
        );
	end generate;

    -- passthrough stream--
    o_sppram_id     <= i_sppram_id;
    o_sppram_id_dv  <= i_sppram_id_dv;
    o_ram_counter   <= i_ram_counter;
    o_fifo_bus      <= i_infl_bus;
    -----------------------
end a;