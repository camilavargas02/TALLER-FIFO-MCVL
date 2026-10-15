LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY fifo_ctrl IS
    GENERIC (ADDR_WIDTH: natural);
    PORT (
        clk         : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC;
        rd          : IN  STD_LOGIC;
        wr          : IN  STD_LOGIC;
        empty       : OUT STD_LOGIC;
        full        : OUT STD_LOGIC;
        w_addr      : OUT STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
        r_addr      : OUT STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
        r_addr_next : OUT STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch OF fifo_ctrl IS
    SIGNAL w_ptr_reg, w_ptr_next, w_ptr_succ : STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
    SIGNAL r_ptr_reg, r_ptr_next, r_ptr_succ : STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
    SIGNAL full_reg, full_next             : STD_LOGIC;
    SIGNAL empty_reg, empty_next           : STD_LOGIC;
    SIGNAL wr_op                           : STD_LOGIC_VECTOR (1 DOWNTO 0);
BEGIN

    -- Incremento de apuntadores (sucesores)
    w_ptr_succ <= STD_LOGIC_VECTOR(unsigned(w_ptr_reg) + 1);
    r_ptr_succ <= STD_LOGIC_VECTOR(unsigned(r_ptr_reg) + 1);

    -- Operación combinada de escritura y lectura
    wr_op <= wr & rd;

    -- Registro secuencial para los apuntadores y banderas de estado
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            w_ptr_reg  <= (OTHERS => '0');
            r_ptr_reg  <= (OTHERS => '0');
            full_reg   <= '0';
            empty_reg  <= '1';
        ELSIF (rising_edge(clk)) THEN
            w_ptr_reg  <= w_ptr_next;
            r_ptr_reg  <= r_ptr_next;
            full_reg   <= full_next;
            empty_reg  <= empty_next;
        END IF;
    END PROCESS;

    -- Lógica de estado siguiente para apuntadores y banderas
    PROCESS(w_ptr_reg, w_ptr_succ, r_ptr_reg, r_ptr_succ, wr_op, empty_reg, full_reg)
    BEGIN
        w_ptr_next <= w_ptr_reg;
        r_ptr_next <= r_ptr_reg;
        full_next  <= full_reg;
        empty_next <= empty_reg;

        CASE wr_op IS
            WHEN "00" => -- No op
                NULL;

            WHEN "01" => -- Read
                IF (empty_reg = '0') THEN
                    r_ptr_next <= r_ptr_succ;
                    full_next  <= '0';
                    IF (r_ptr_succ = w_ptr_reg) THEN
                        empty_next <= '1';
                    END IF;
                END IF;

            WHEN "10" => -- Write
                IF (full_reg = '0') THEN
                    w_ptr_next <= w_ptr_succ;
                    empty_next <= '0';
                    IF (w_ptr_succ = r_ptr_reg) THEN
                        full_next <= '1';
                    END IF;
                END IF;

            WHEN OTHERS => -- Write / Read simultaneos ("11")
                IF (empty_reg = '1') THEN
                    w_ptr_next <= w_ptr_succ;
                    empty_next <= '0';
                ELSIF (full_reg = '1') THEN
                    r_ptr_next <= r_ptr_succ;
                    full_next  <= '0';
                ELSE
                    w_ptr_next <= w_ptr_succ;
                    r_ptr_next <= r_ptr_succ;
                END IF;
        END CASE;
    END PROCESS;

    -- Asignación de salidas
    w_addr      <= w_ptr_reg;
    r_addr      <= r_ptr_reg;
    full        <= full_reg;
    empty       <= empty_reg;
    r_addr_next <= r_ptr_next;

END ARCHITECTURE;