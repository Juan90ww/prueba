module top_divisor_debug (
    input  logic clk,
    input  logic rst,

    input  logic [3:0] fil,     // nibble enviado desde el testbench
    output logic [3:0] col,     // no usado, pero requerido por el top

    output logic [3:0] anodo,
    output logic [6:0] seven,

    // Señales expuestas al testbench
    output logic [7:0] A_bin_debug,
    output logic [7:0] B_bin_debug,
    output logic [6:0] Q_debug,
    output logic [6:0] R_debug,
    output logic       div_done_debug
);

    // =============================================================
    // 1) Entrada directa del "teclado"
    // =============================================================
    logic [3:0] tecla_hex;
    assign tecla_hex = fil;

    // =============================================================
    // 2) DETECTOR DE TECLA (CORREGIDO)
    // =============================================================
    logic [3:0] last_hex;
    logic       tecla_valida;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            last_hex     <= 4'hF;      // referencia a idle
            tecla_valida <= 1'b0;
        end else begin
            tecla_valida <= (tecla_hex != last_hex);  // detectar cambios SIEMPRE
            last_hex     <= tecla_hex;
        end
    end

    // =============================================================
    // 3) FSM CAPTURA DE NIBBLES A_hi, A_lo, B_hi, B_lo
    // =============================================================
    typedef enum logic [2:0] { A_H, A_L, B_H, B_L, READY } st_t;
    st_t estado;

    logic [3:0] A_hi, A_lo;
    logic [3:0] B_hi, B_lo;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            estado <= A_H;
            A_hi <= 0; A_lo <= 0;
            B_hi <= 0; B_lo <= 0;
        end else begin
            // Solo avanzar cuando REALMENTE se envía un nibble válido (= distinto de F)
            if (tecla_valida && tecla_hex != 4'hF) begin
                case (estado)
                    A_H: begin A_hi <= tecla_hex; estado <= A_L; end
                    A_L: begin A_lo <= tecla_hex; estado <= B_H; end
                    B_H: begin B_hi <= tecla_hex; estado <= B_L; end
                    B_L: begin B_lo <= tecla_hex; estado <= READY; end
                    READY: estado <= A_H;
                endcase
            end
        end
    end

    assign A_bin_debug = {A_hi, A_lo};
    assign B_bin_debug = {B_hi, B_lo};

    // =============================================================
    // 4) start_div — pulso limpio cuando se completa B_L
    // =============================================================
    logic start_div;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            start_div <= 0;
        else
            start_div <= (estado == B_L) && tecla_valida && tecla_hex != 4'hF;
    end

    // =============================================================
    // 5) DIVISIÓN (con DONE latched)
    // =============================================================
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            Q_debug         <= 0;
            R_debug         <= 0;
            div_done_debug  <= 0;
        end else begin
            // Limpiar DONE cuando se prepara una nueva división
            if (start_div)
                div_done_debug <= 0;

            // Ejecutar división en el ciclo donde llega start_div
            if (start_div) begin
                if (B_bin_debug == 0) begin
                    Q_debug <= 0;
                    R_debug <= A_bin_debug[6:0];
                end else begin
                    Q_debug <= A_bin_debug / B_bin_debug;
                    R_debug <= A_bin_debug % B_bin_debug;
                end

                div_done_debug <= 1;  // DONE permanece en 1 hasta próxima división
            end
        end
    end

    // =============================================================
    // 6) BIN → BCD (del cociente)
    // =============================================================
    logic [3:0] b3, b2, b1, b0;
    logic bcd_done;

    bin2bcd #(.N(7)) conv(
        .clk(clk),
        .rst(rst),
        .start(div_done_debug),
        .bin(Q_debug),
        .bcd3(b3), .bcd2(b2), .bcd1(b1), .bcd0(b0),
        .done(bcd_done)
    );

    // =============================================================
    // 7) DISPLAY
    // =============================================================
    logic [15:0] digito;
    assign digito = {b3, b2, b1, b0};

    display_7seg dsp(
        .clk(clk),
        .rst(rst),
        .digito(digito),
        .anodo(anodo),
        .seven(seven)
    );

    // El keypad real necesita columnas, pero aquí no se usa
    assign col = 4'b0000;

endmodule
