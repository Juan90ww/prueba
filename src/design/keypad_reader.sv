module keypad_reader (
    input  logic        clk,
    input  logic        rst_n,

    output logic [3:0]  filas,
    input  logic [3:0]  columnas,

    output logic [3:0]  key_value,
    output logic        key_valid
);

    // --------------------------------------------------------
    // GENERACIÓN DEL ESCANEO DE FILAS (1 activa por vez)
    // --------------------------------------------------------

    logic [1:0] row_sel;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            row_sel <= 0;
        else
            row_sel <= row_sel + 1;
    end

    always_comb begin
        case (row_sel)
            2'd0: filas = 4'b1110; // fila 0 activa
            2'd1: filas = 4'b1101; // fila 1
            2'd2: filas = 4'b1011; // fila 2
            2'd3: filas = 4'b0111; // fila 3
        endcase
    end

    // --------------------------------------------------------
    // DETECCIÓN (sin rebote por ahora)
    // --------------------------------------------------------

    logic [3:0] col_sample;
    logic       pressed;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_sample <= 4'hF;
        end else begin
            col_sample <= columnas;
        end
    end

    assign pressed = (col_sample != 4'hF);

    // --------------------------------------------------------
    // DECODIFICACIÓN DE TECLA
    // --------------------------------------------------------

    logic [3:0] decode;

    always_comb begin
        decode = 4'hF;

        case (row_sel)
            2'd0: begin
                case (col_sample)
                    4'b1110: decode = 4'd1;
                    4'b1101: decode = 4'd2;
                    4'b1011: decode = 4'd3;
                    4'b0111: decode = 4'hA; // ENTER
                endcase
            end

            2'd1: begin
                case (col_sample)
                    4'b1110: decode = 4'd4;
                    4'b1101: decode = 4'd5;
                    4'b1011: decode = 4'd6;
                    4'b0111: decode = 4'hB;
                endcase
            end

            2'd2: begin
                case (col_sample)
                    4'b1110: decode = 4'd7;
                    4'b1101: decode = 4'd8;
                    4'b1011: decode = 4'd9;
                    4'b0111: decode = 4'hC;
                endcase
            end

            2'd3: begin
                case (col_sample)
                    4'b1110: decode = 4'd0;
                    4'b1101: decode = 4'hD;
                    4'b1011: decode = 4'hE;
                    4'b0111: decode = 4'hF;
                endcase
            end
        endcase
    end


    logic pressed_prev;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pressed_prev <= 0;
        else
            pressed_prev <= pressed;
    end

    assign key_valid = (pressed && !pressed_prev);
    assign key_value = decode;

endmodule

