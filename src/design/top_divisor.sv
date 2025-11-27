module top_divisor(
    input  logic clk,
    input  logic rst,

    input  logic [3:0] fil,
    output logic [3:0] col,

    output logic [3:0] anodo,
    output logic [6:0] seven
);

    logic [3:0] filas_db;

    debounce db0(.clk(clk), .rst(rst), .key(fil[0]), .key_pressed(filas_db[0]));
    debounce db1(.clk(clk), .rst(rst), .key(fil[1]), .key_pressed(filas_db[1]));
    debounce db2(.clk(clk), .rst(rst), .key(fil[2]), .key_pressed(filas_db[2]));
    debounce db3(.clk(clk), .rst(rst), .key(fil[3]), .key_pressed(filas_db[3]));

    logic [3:0] tecla_hex;

    teclado key(
        .clk(clk),
        .filas(filas_db),
        .columnas(col),
        .boton(tecla_hex)
    );

    logic tecla_activa = (filas_db != 4'b1111);

    typedef enum logic [1:0] {SCAN, LOAD, RELEASE} st_t;
    st_t est, next;

    always_comb begin
        next = est;
        case (est)
            SCAN:    if (tecla_activa && tecla_hex != 4'hF) next = LOAD;
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

    logic [7:0] A_bin, B_bin; 
    logic operands_ready;
    logic operands_ready_d;
    logic start_div;

    captura_operandos capt(
        .clk(clk), .rst(rst),
        .tecla(tecla_hex),
        .tecla_valida(tecla_valida),
        .A_bin(A_bin),
        .B_bin(B_bin),
        .ready_operands(operands_ready)
    );

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            operands_ready_d <= 0;
            start_div <= 0;
        end else begin
            operands_ready_d <= operands_ready;
            start_div <= operands_ready & ~operands_ready_d;
        end
    end

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

    logic [3:0] bcd3,bcd2,bcd1,bcd0;
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

    logic [15:0] digito;

    assign digito = {bcd3,bcd2,bcd1,bcd0};

    display_7seg disp(
        .clk(clk),
        .rst(rst),
        .digito(digito),
        .anodo(anodo),
        .seven(seven)
    );

endmodule
