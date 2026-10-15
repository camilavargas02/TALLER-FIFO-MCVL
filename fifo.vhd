LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY fifo IS
    GENERIC (
        ADDR_WIDTH : INTEGER := 3;
        DATA_WIDTH : INTEGER := 8
    );
    PORT (
        clk    : IN  STD_LOGIC;
        reset  : IN  STD_LOGIC;
        rd     : IN  STD_LOGIC;
        wr     : IN  STD_LOGIC;
        w_data : IN  STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
        empty  : OUT STD_LOGIC;
        full   : OUT STD_LOGIC;
        r_data : OUT STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE structural OF fifo IS
    SIGNAL full_s   : STD_LOGIC;
    SIGNAL wr_en_s  : STD_LOGIC;
    SIGNAL w_addr_s : STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
    SIGNAL r_addr_s : STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
BEGIN

    -- Write enable solo cuando la FIFO no está llena[cite: 4]
    wr_en_s <= wr AND (NOT full_s);
    full    <= full_s;

    -- Instanciación de la unidad de control (fifo_ctrl)[cite: 4]
    ctrl_unit: ENTITY work.fifo_ctrl
        GENERIC MAP (
            ADDR_WIDTH => ADDR_WIDTH
        )
        PORT MAP (
            clk         => clk,
            reset       => reset,
            rd          => rd,
            wr          => wr,
            empty       => empty,
            full        => full_s,
            w_addr      => w_addr_s,
            r_addr      => r_addr_s,
            r_addr_next => OPEN
        );

    -- Instanciación del archivo de registros (register_file)[cite: 4]
    reg_file_unit: ENTITY work.register_file
        GENERIC MAP (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH
        )
        PORT MAP (
            clk    => clk,
            w_addr => w_addr_s,
            r_addr => r_addr_s,
            w_data => w_data,
            r_data => r_data,
            wr_en  => wr_en_s
        );

END ARCHITECTURE;