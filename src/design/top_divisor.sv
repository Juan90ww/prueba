module top_divisor(
    input  logic clk,
    input  logic rst,

    // Teclado matricial
    input  logic [3:0] fil,
    output logic [3:0] col,

    // Display 7 segmentos
    output logic [3:0] anodo,
    output logic [6:0] seven
);

    //-----------------------------------------
    // 1) Debounce para las filas del keypad
    //-----------------------------------------
    logic [3:0] filas_db;

    debounce d0(.clk(clk), .rst(rst), .key(fil[0]), .key_pressed(filas_db[0]));
    debounce d1(.clk(clk), .rst(rst), .key(fil[1]), .key_pressed(filas_db[1]));
    debounce d2(.clk(clk), .rst(rst), .key(fil[2]), .key_pressed(filas_db[2]));
    debounce d3(.clk(clk), .rst(rst), .key(fil[3]), .key_pressed(filas_db[3]));

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
    // 3) FSM SCAN / LOAD / RELEASE
    //-----------------------------------------
    logic tecla_activa = (filas_db != 4'b1111);

    typedef enum logic [1:0] {SCAN, LOAD, RELEASE} st_t;
    st_t est, next;

    always_comb begin
        next = est;
        case (est)
            SCAN:
                if (tecla_activa && tecla_hex != 4'b1111)
                    next = LOAD;

            LOAD:
                next = RELEASE;

            RELEASE:
                if (!tecla_activa)
                    next = SCAN;
        endcase
    end

    logic tecla_valida;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            est <= SCAN;
            tecla_valida <= 0;
        end else begin
            est <= next;
            tecla_valida <= (est == LOAD);   // 1 ciclo pulso
        end
    end

    //-----------------------------------------
    // 4) Captura operandos (A y B en HEX)
    //-----------------------------------------
    logic [7:0] A_bin, B_bin;   // 8 bits, coincide con captura_operandos
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

    // Generar pulso start_div cuando ready_operands sube
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            operands_ready_d <= 0;
            start_div <= 0;
        end else begin
            operands_ready_d <= operands_ready;
            start_div <= operands_ready & ~operands_ready_d;  // detección de flanco
        end
    end

    //-----------------------------------------
    // 5) Divisor RESTORING
    //-----------------------------------------
    logic [6:0] Cociente, Residuo;
    logic div_done;

    divisor_restoring divi(
        .clk(clk),
        .rst(rst),
        .start(start_div),
        .A_in(A_bin[6:0]),   // Se toma solo 7 bits
        .B_in(B_bin[6:0]),
        .Q(Cociente),
        .R(Residuo),
        .done(div_done)
    );

    //-----------------------------------------
    // 6) Convertir binario → BCD (para display)
    //-----------------------------------------
    logic [3:0] d3, d2, d1, d0;
    logic bcd_done;

    bin2bcd #(.N(7)) conv(
        .clk(clk),
        .rst(rst),
        .start(div_done),
        .bin(Cociente),       // Se muestra el cociente
        .bcd3(d3),
        .bcd2(d2),
        .bcd1(d1),
        .bcd0(d0),
        .done(bcd_done)
    );

    //-----------------------------------------
    // 7) Multiplexor del display 7 segmentos
    //-----------------------------------------
    logic [15:0] digito = {d3, d2, d1, d0};

    display_7seg mux(
        .clk(clk),
        .rst(rst),
        .digito(digito),
        .anodo(anodo),
        .seven(seven)
    );

endmodule


