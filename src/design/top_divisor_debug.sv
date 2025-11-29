// ============================================================
//  TOP DIVISOR DEBUG — versión corregida
//  * Captura de nibbles robusta
//  * Detector de tecla arreglado
//  * División combinacional estable
//  * DONE latched correctamente
// ============================================================

module top_divisor_debug (
    input  logic clk,
    input  logic rst,

    input  logic [3:0] fil,     // entrada del testbench
    output logic [3:0] col,     // no usado, pero requerido por top

    output logic [3:0] anodo,
    output logic [6:0] seven,

    // Señales de debug para el testbench
    output logic [7:0] A_bin_debug,
    output logic [7:0] B_bin_debug,
    output logic [6:0] Q_debug,
    output logic [6:0] R_debug,
    output logic       div_done_debug
);

    // =====================================================
    // 1) BYPASS DEL TECLADO (simplemente usar FIL)
    // =====================================================
    logic [3:0] tecla_hex;
    assign tecla_hex = fil;

    // =====================================================
    // 2) CAPTURA DE 2 BYTES (A y B) con FSM
    // =====================================================
    typedef enum logic [2:0] { A_H, A_L, B_H, B_L, READY } st_t;
    st_t estado;

    logic [3:0] A_hi, A_lo;
    logic [3:0] B_hi, B_lo;

    logic tecla_valida;
    logic [3:0] last_hex;

    // --- Detector de tecla válida (CORREGIDO) ---
    //
    // El error original: last_hex iniciaba en 0xF
    // pero fil también inicia en 0xF → nunca había cambio.
    // Esto dejaba la FSM congelada.
    //
    // Solución: inicializar last_hex en un valor distinto.
    //
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            last_hex     <= 4'hE;       // *** FIX CLAVE ***
            tecla_valida <= 1'b0;
        end else begin
            tecla_valida <= (tecla_hex != last_hex);
            last_hex     <= tecla_hex;
        end
    end

    // --- FSM que captura A y B ---
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            estado <= A_H;
            A_hi <= 0; A_lo <= 0;
            B_hi <= 0; B_lo <= 0;
        end else begin
            if (tecla_valida  && tecla_hex != 4'hF) begin
                case (estado)
                    A_H:   begin A_hi <= tecla_hex; estado <= A_L; end
                    A_L:   begin A_lo <= tecla_hex; estado <= B_H; end
                    B_H:   begin B_hi <= tecla_hex; estado <= B_L; end
                    B_L:   begin B_lo <= tecla_hex; estado <= READY; end
                    READY: estado <= A_H;
                endcase
            end
        end
    end

    assign A_bin_debug = {A_hi, A_lo};
    assign B_bin_debug = {B_hi, B_lo};

    // =====================================================
    // 3) GENERACIÓN DE start_div (pulso limpio)
    // =====================================================
    logic start_div;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            start_div <= 0;
        else
            start_div <= (estado == B_L) && tecla_valida && tecla_hex != 4'hF;
    end

    // =====================================================
    // 4) DIVISIÓN (combinacional, con DONE latched)
    // =====================================================
    logic [7:0] A8, B8;
    assign A8 = A_bin_debug;
    assign B8 = B_bin_debug;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            Q_debug <= 0;
            R_debug <= 0;
            div_done_debug <= 0;
        end else begin
            if (start_div)
                div_done_debug <= 0;   // limpiar previo

            if (start_div) begin
                if (B8 == 0) begin
                    Q_debug <= 0;
                    R_debug <= A8[6:0];
                end else begin
                    Q_debug <= A8 / B8;
                    R_debug <= A8 % B8;
                end

                div_done_debug <= 1;  // DONE queda en 1
            end
        end
    end

    // =====================================================
    // 5) CONVERSIÓN BIN→BCD (cociente)
    // =====================================================
    logic [3:0] b3, b2, b1, b0;
    logic bcd_done;

    bin2bcd #(.N(7)) conv(
        .clk(clk),
        .rst(rst),
        .start(div_done_debug),
        .bin(Q_debug),
        .bcd3(b3), .bcd2(b2),
        .bcd1(b1), .bcd0(b0),
        .done(bcd_done)
    );

    // =====================================================
    // 6) DISPLAY
    // =====================================================
    logic [15:0] digito;
    assign digito = {b3, b2, b1, b0};

    display_7seg dsp(
        .clk(clk),
        .rst(rst),
        .digito(digito),
        .anodo(anodo),
        .seven(seven)
    );

    assign col = 4'b0000;

endmodule

