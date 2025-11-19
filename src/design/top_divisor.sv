module top_divisor (
    input  logic        clk,       // 27 MHz
    input  logic        rst_n,

    // Teclado 4x4
    output logic [3:0]  filas,
    input  logic [3:0]  columnas,

    // Display 7 segmentos
    output logic [3:0]  anodo,
    output logic [6:0]  seven,

    // Selector: 0 = cociente, 1 = residuo
    input  logic        sel_residuo
);



    logic [3:0] key_value;
    logic       key_valid;

    keypad_reader kb (
        .clk(clk),
        .rst_n(rst_n),
        .filas(filas),
        .columnas(columnas),
        .key_value(key_value),
        .key_valid(key_valid)
    );



    typedef enum logic [1:0] {
        WAIT_FIRST,
        WAIT_SECOND,
        READY
    } input_state_t;

    input_state_t input_state;

    logic [3:0] d2_A, d1_A, d0_A;
    logic [3:0] d2_B, d1_B, d0_B;

    logic load_A, load_B;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_state <= WAIT_FIRST;
            d2_A <= 0; d1_A <= 0; d0_A <= 0;
            d2_B <= 0; d1_B <= 0; d0_B <= 0;
        end else begin

            case (input_state)

                WAIT_FIRST: begin
                    if (key_valid && key_value <= 9) begin
                        // desplazar BCD A
                        d2_A <= d1_A;
                        d1_A <= d0_A;
                        d0_A <= key_value;
                    end

                    if (key_valid && key_value == 'hA) begin
                        input_state <= WAIT_SECOND;
                    end
                end

                WAIT_SECOND: begin
                    if (key_valid && key_value <= 9) begin
                        d2_B <= d1_B;
                        d1_B <= d0_B;
                        d0_B <= key_value;
                    end

                    if (key_valid && key_value == 'hA) begin
                        input_state <= READY;
                    end
                end

                READY: begin
                    input_state <= WAIT_FIRST;
                end

            endcase
        end
    end

    assign load_A = (input_state == READY);
    assign load_B = (input_state == READY);



    logic [10:0] A_bin, B_bin;

    bcd_to_bin convA (
        .clk(clk),
        .en(load_A),
        .d2(d2_A), .d1(d1_A), .d0(d0_A),
        .value(A_bin)
    );

    bcd_to_bin convB (
        .clk(clk),
        .en(load_B),
        .d2(d2_B), .d1(d1_B), .d0(d0_B),
        .value(B_bin)
    );

    // ------------------------------------------------------------
    // 4. DIVISOR DE 7 BITS (núcleo del proyecto)
    // ------------------------------------------------------------

    logic [6:0] Q, R;
    logic       div_start, div_done;

    assign div_start = (input_state == READY);

    divisor_7bit divcore (
        .clk(clk),
        .rst_n(rst_n),
        .start(div_start),
        .dividendo(A_bin[6:0]),   // solo 7 bits del valor
        .divisor(B_bin[6:0]),
        .cociente(Q),
        .residuo(R),
        .done(div_done)
    );



    logic [3:0] q3,q2,q1,q0;
    logic [3:0] r3,r2,r1,r0;
    logic       start_bcd, done_bcd_Q, done_bcd_R;

    assign start_bcd = div_done;

    bin_to_bcd bcd_Q (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_bcd),
        .bin_in({4'd0, Q}),   // expando a 11 bits
        .bcd3(q3), .bcd2(q2), .bcd1(q1), .bcd0(q0),
        .done(done_bcd_Q)
    );

    bin_to_bcd bcd_R (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_bcd),
        .bin_in({4'd0, R}),
        .bcd3(r3), .bcd2(r2), .bcd1(r1), .bcd0(r0),
        .done(done_bcd_R)
    );



    logic [3:0] d3,d2,d1,d0;

    always_comb begin
        if (sel_residuo == 1'b0) begin
            // mostrar cociente
            d3 = q3; d2 = q2; d1 = q1; d0 = q0;
        end else begin
            // mostrar residuo
            d3 = r3; d2 = r2; d1 = r1; d0 = r0;
        end
    end



    display_mux disp (
        .clk(clk),
        .rst_n(rst_n),
        .d3(d3), .d2(d2), .d1(d1), .d0(d0),
        .anodo(anodo),
        .seven(seven)
    );

endmodule
