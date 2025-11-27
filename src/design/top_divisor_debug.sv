module top_divisor_debug(
    input  logic clk,
    input  logic rst,

    // Teclado matricial
    input  logic [3:0] fil,
    output logic [3:0] col,

    // Display 7 segmentos
    output logic [3:0] anodo,
    output logic [6:0] seven,

    // ======= SEÑALES DEBUG PARA TESTBENCH =======
    output logic [7:0] A_bin_debug,
    output logic [7:0] B_bin_debug,
    output logic [6:0] Q_debug,
    output logic [6:0] R_debug,
    output logic       div_done_debug
);

    //-----------------------------------------
    // 1) Debounce (4 señales independientes)
    //-----------------------------------------
    logic [3:0] filas_db;

    debounce db0(.clk(clk), .rst(rst), .key(fil[0]), .key_pressed(filas_db[0]));
    debounce db1(.clk(clk), .rst(rst), .key(fil[1]), .key_pressed(filas_db[1]));
    debounce db2(.clk(clk), .rst(rst), .key(fil[2]), .key_pressed(filas_db[2]));
    debounce db3(.clk(clk), .rst(rst), .key(fil[3]), .key_pressed(filas_db[3]));

    //-----------------------------------------
    // 2) Keypad scanning → tecla en HEX
    //-----------------------------------------
    logic [3:0] tecla_hex;

    teclado tecla_inst(
        .clk(clk),
        .filas(filas_db),
        .columnas(col),
        .boton(tecla_hex)
    );

    //-----------------------------------------
    // 3) FSM para generar tecla_valida (1 ciclo)
    //-----------------------------------------
    logic tecla_activa = (filas_db != 4'b1111);

    typedef enum logic [1:0] {SCAN, LOAD, RELEASE} st_t;
    st_t est, next;

    always_comb begin
        next = est;
        case (est)
            SCAN:    if (tecla_activa && tecla_hex != 4'b1111) next = LOAD;
            LOAD:    next = RELEASE;
            RELEASE: if (!tecla_activa) next = SCAN;
        endcase
    end

    logic tecla_valida;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            est <= SCAN;
            tecla_valida <= 0;
        end else begin
            est <= next;
            tecla_valida <= (est == LOAD);
        end
    end

    //-----------------------------------------
    // 4) Captura operandos HEX
    //-----------------------------------------
    logic [7:0] A_bin, B_bin; 
    logic operands_ready;
    logic operands_ready_d;
    logic start_div;

    captura_operandos capt(
        .clk(clk),
        .rst(rst),
        .tecla(tecla_hex),
        .tecla_valida(tecla_valida),
        .A_bin(A_bin),
        .B_bin(B_bin),
        .ready_operands(operands_ready)
    );

    // pulso start_div
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            operands_ready_d <= 0;
            start_div <= 0;
        end else begin
            operands_ready_d <= operands_ready;
            start_div <= operands_ready & ~operands_ready_d;
        end
    end

    //-----------------------------------------
    // 5) Divisor
    //-----------------------------------------
    logic [6:0] Cociente, Residuo;
    logic div_done;

    divisor_restoring_7bits divi(
        .clk(clk),
        .rst(rst),
        .start(start_div),
        .dividendo(A_bin[6:0]),
        .divisor(B_bin[6:0]),
        .cociente(Cociente),
        .resto(Residuo),
        .done(div_done)
    );

    //-----------------------------------------
    // 6) BIN → BCD para display
    //-----------------------------------------
    logic [3:0] bcd3, bcd2, bcd1, bcd0;
    logic bcd_done;

    bin2bcd #(.N(7)) conv(
        .clk(clk),
        .rst(rst),
        .start(div_done),
        .bin(Cociente),
        .bcd3(bcd3), .bcd2(bcd2),
        .bcd1(bcd1), .bcd0(bcd0),
        .done(bcd_done)
    );

    //-----------------------------------------
    // 7) Display 7 segmentos
    //-----------------------------------------
    logic [15:0] digito = {bcd3, bcd2, bcd1, bcd0};

    display_7seg mux(
        .clk(clk),
        .rst(rst),
        .digito(digito),
        .anodo(anodo),
        .seven(seven)
    );

    //-----------------------------------------
    // 8) Señales DEBUG para testbench
    //-----------------------------------------
    assign A_bin_debug = A_bin;
    assign B_bin_debug = B_bin;
    assign Q_debug     = Cociente;
    assign R_debug     = Residuo;
    assign div_done_debug = div_done;

endmodule
