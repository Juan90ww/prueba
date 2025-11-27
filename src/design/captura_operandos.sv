module captura_operandos(
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] tecla,        // valor hex debounced
    input  logic       tecla_valida, // 1 ciclo durante LOAD

    output logic [6:0] A_bin,
    output logic [6:0] B_bin,
    output logic       ready_operands
);

    typedef enum logic [2:0] {
        A_MSB,
        A_LSB,
        B_MSB,
        B_LSB,
        READY
    } state_t;

    state_t estado, next;

    logic [3:0] A_hi, A_lo;
    logic [3:0] B_hi, B_lo;

    //==============================
    // FSM NEXT
    //==============================
    always_comb begin
        next = estado;
        case (estado)
            A_MSB: if (tecla_valida) next = A_LSB;
            A_LSB: if (tecla_valida) next = B_MSB;
            B_MSB: if (tecla_valida) next = B_LSB;
            B_LSB: if (tecla_valida) next = READY;
            READY: next = READY;
        endcase
    end

    //==============================
    // FSM + registros
    //==============================
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            estado <= A_MSB;
            A_hi <= 0; A_lo <= 0;
            B_hi <= 0; B_lo <= 0;
        end else begin
            estado <= next;

            if (tecla_valida) begin
                case (estado)
                    A_MSB: A_hi <= tecla;
                    A_LSB: A_lo <= tecla;
                    B_MSB: B_hi <= tecla;
                    B_LSB: B_lo <= tecla;
                endcase
            end
        end
    end

    //==============================
    // Conversión HEX → BIN (7 bits)
    //==============================
    assign A_bin = {A_hi, A_lo};   // 8 bits → usa solo 7 bits efectivos
    assign B_bin = {B_hi, B_lo};

    assign ready_operands = (estado == READY);

endmodule
