LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY register_file IS
    GENERIC (
        DATA_WIDTH : INTEGER := 8;
        ADDR_WIDTH : INTEGER := 2
    );
    PORT (
        clk    : IN  STD_LOGIC;
        wr_en  : IN  STD_LOGIC;
        w_addr : IN  STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
        r_addr : IN  STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
        w_data : IN  STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
        r_data : OUT STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF register_file IS
    TYPE mem_2d_type IS ARRAY (0 TO (2**ADDR_WIDTH)-1) OF STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
    SIGNAL array_reg : mem_2d_type;
BEGIN
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (wr_en = '1') THEN
                array_reg(to_integer(unsigned(w_addr))) <= w_data;
            END IF;
        END IF;
    END PROCESS;
    
    -- Lectura asíncrona
    r_data <= array_reg(to_integer(unsigned(r_addr)));
END ARCHITECTURE;