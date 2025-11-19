module keypad_reader (
    input  logic clk,
    input  logic rst_n,

    // Señales hacia el teclado
    output logic [3:0] filas,
    input  logic [3:0] columnas,

    output logic [3:0] key_value,  // valor de tecla (0–15)
    output logic       key_valid   // pulso 1 cuando hay tecla nueva
);

    logic [3:0] col_clean;
    genvar i;

    // Debounce para columnas
    generate
        for (i = 0; i < 4; i++) begin
            debouncer db_col (
                .clk(clk),
                .rst_n(rst_n),
                .noisy_in(columnas[i]),
                .clean_out(col_clean[i])
            );
        end
    endgenerate

    // Estado actual de fila a activar
    logic [1:0] fila_sel;
    logic [3:0] reg_filas;

    // Multiplexado de filas
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            fila_sel <= 0;
        else
            fila_sel <= fila_sel + 1;
    end

    always_comb begin
        case (fila_sel)
            2'd0: reg_filas = 4'b1110;
            2'd1: reg_filas = 4'b1101;
            2'd2: reg_filas = 4'b1011;
            2'd3: reg_filas = 4'b0111;
        endcase
        filas = reg_filas;
    end

    // Detección de tecla
    logic [3:0] tecla_raw;
    logic valid_raw;

    always_comb begin
        valid_raw = 0;
        tecla_raw = 4'd0;

        if (col_clean != 4'b1111) begin
            valid_raw = 1;

            casex ({fila_sel, col_clean})
                6'b00_1110: tecla_raw = 1;
                6'b00_1101: tecla_raw = 2;
                6'b00_1011: tecla_raw = 3;
                6'b00_0111: tecla_raw = 'hA;  // A = enviar

                6'b01_1110: tecla_raw = 4;
                6'b01_1101: tecla_raw = 5;
                6'b01_1011: tecla_raw = 6;
                6'b01_0111: tecla_raw = 'hB;

                6'b10_1110: tecla_raw = 7;
                6'b10_1101: tecla_raw = 8;
                6'b10_1011: tecla_raw = 9;
                6'b10_0111: tecla_raw = 'hC;

                6'b11_1110: tecla_raw = '*;
                6'b11_1101: tecla_raw = 0;
                6'b11_1011: tecla_raw = '#;
                6'b11_0111: tecla_raw = 'hD;
            endcase
        end
    end

    // Registro de salida de una tecla estable (un solo pulso)
    logic valid_d;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_d <= 0;
            key_valid <= 0;
            key_value <= 0;
        end else begin
            valid_d <= valid_raw;
            key_valid <= valid_raw & ~valid_d;  // flanco de subida
            if (valid_raw & ~valid_d)
                key_value <= tecla_raw;
        end
    end

endmodule
