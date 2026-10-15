LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY fifo_tb IS
END ENTITY;

ARCHITECTURE sim OF fifo_tb IS
    CONSTANT ADDR_WIDTH : INTEGER := 3; -- 8 posiciones (2^3 = 8)[cite: 2, 3]
    CONSTANT DATA_WIDTH : INTEGER := 8;
    CONSTANT CLK_PERIOD : TIME := 10 ns;

    SIGNAL clk    : STD_LOGIC := '0';
    SIGNAL reset  : STD_LOGIC := '1';
    SIGNAL rd     : STD_LOGIC := '0';
    SIGNAL wr     : STD_LOGIC := '0';
    SIGNAL w_data : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL empty  : STD_LOGIC;
    SIGNAL full   : STD_LOGIC;
    SIGNAL r_data : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);

BEGIN

    -- Instanciación del top-level entity (fifo)
    uut: ENTITY work.fifo
        GENERIC MAP (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH
        )
        PORT MAP (
            clk    => clk,
            reset  => reset,
            rd     => rd,
            wr     => wr,
            w_data => w_data,
            empty  => empty,
            full   => full,
            r_data => r_data
        );

    -- Generador de Reloj
    clk_process: PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR CLK_PERIOD / 2;
        clk <= '1';
        WAIT FOR CLK_PERIOD / 2;
    END PROCESS;

    -- Proceso de estímulos basado en la Figura 3
    stimulus_process: PROCESS
        PROCEDURE write_fifo(data_val : IN INTEGER) IS
        BEGIN
            WAIT UNTIL rising_edge(clk);
            wr <= '1';
            rd <= '0';
            w_data <= STD_LOGIC_VECTOR(to_unsigned(data_val, DATA_WIDTH));
        END PROCEDURE;

        PROCEDURE read_fifo IS
        BEGIN
            WAIT UNTIL rising_edge(clk);
            wr <= '0';
            rd <= '1';
        END PROCEDURE;

        PROCEDURE nop_fifo IS
        BEGIN
            WAIT UNTIL rising_edge(clk);
            wr <= '0';
            rd <= '0';
        END PROCEDURE;
    BEGIN
        -- (a) Inicial (vacía)[cite: 3]
        reset <= '1';
        wr <= '0';
        rd <= '0';
        WAIT FOR CLK_PERIOD * 2;
        reset <= '0';
        WAIT FOR CLK_PERIOD;

        -- (b) Después de 1 escritura[cite: 3]
        write_fifo(11);

        -- (c) 3 escrituras más[cite: 3]
        write_fifo(22);
        write_fifo(33);
        write_fifo(44);

        -- (d) Después de 1 lectura[cite: 3]
        read_fifo;

        -- (e) 4 escrituras más[cite: 3]
        write_fifo(55);
        write_fifo(66);
        write_fifo(77);
        write_fifo(88);

        -- (f) 1 escritura más (llena)[cite: 3]
        write_fifo(99);

        -- (g) 2 lecturas[cite: 3]
        read_fifo;
        read_fifo;

        -- (h) 5 lecturas más[cite: 3]
        read_fifo;
        read_fifo;
        read_fifo;
        read_fifo;
        read_fifo;

        -- (i) 1 lectura más (vacía)[cite: 3]
        read_fifo;

        nop_fifo;
        WAIT FOR CLK_PERIOD * 5;
        WAIT;
    END PROCESS;

END ARCHITECTURE;