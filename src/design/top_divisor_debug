// ===============================================
//  TOP DIVISOR DEBUG — PARA SIMULACIÓN
//  Compatible con tb_top_divisor_printf
//  SIN teclado, SIN debounce, SIN FSM,
//  CON bypass directo de la tecla
// ===============================================

module top_divisor_debug (
    input  logic clk,
    input  logic rst,

    input  logic [3:0] fil,     // entrada del testbench
    output logic [3:0] col,     // ya no usado, pero debe existir
    output logic [3:0] anodo,
    output logic [6:0] seven,

    // Señales visibles en testbench
    output logic [7:0] A_bin_debug,
    output logic [7:0] B_bin_debug,
    output logic [6:0] Q_debug,
    output logic [6:0] R_debug,
    output logic       div_done_debug
);

    // =====================================================
    // 1) BYPASS DIRECTO DE TECLA
    // =====================================================
    //
    // Interpretamos fil como un valor HEX directo:
    // fil = 0000 → tecla 0
    // fil = 0001 → tecla 1
    // ...
    // fil = 1111 → no presionado
    //
    // (tb_top_divisor_printf ya envía valores en ese formato)

    logic [3:0] tecla_hex;
    assign tecla_hex = fil;

    // =====================================================
    // 2) CAPTURA DE 2 BYTES A Y B (MSB y LSB)
    // =====================================================

    typedef enum logic [2:0] { A_H, A_L, B_H, B_L, READY } st_t;
    st_t estado;

    logic [3:0] A_hi, A_lo;
    logic [3:0] B_hi, B_lo;

    logic tecla_valida;
    logic [3:0] last_hex;

    // pulso de tecla válida (cambio)
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            last_hex <= 4'hF;
            tecla_valida <= 0;
        end else begin
            tecla_valida <= (tecla_hex != last_hex);
            last_hex <= tecla_hex;
        end
    end

    // FSM simple
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            estado <= A_H;
            A_hi <= 0; A_lo <= 0;
            B_hi <= 0; B_lo <= 0;
        end else begin
            if (tecla_valida) begin
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

    logic start_div;
    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            start_div <= 0;
        else
            start_div <= (estado == B_L) && tecla_valida;
    end

    // =====================================================
    // 3) DIVISIÓN BYPASS COMBINACIONAL
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
            div_done_debug <= 0;
            if (start_div) begin
                if (B8 == 0) begin
                    Q_debug <= 0;
                    R_debug <= A8[6:0];
                    div_done_debug <= 1;
                end else begin
                    Q_debug <= A8 / B8;
                    R_debug <= A8 % B8;
                    div_done_debug <= 1;
                end
            end
        end
    end

    // =====================================================
    // 4) BIN → BCD (solo el cociente)
    // =====================================================

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

    // =====================================================
    // 5) DISPLAY
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

    // columnas no usadas
    assign col = 4'b0000;

endmodule
