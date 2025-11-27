module divisor_restoring_7bits (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [6:0]  dividendo,
    input  logic [6:0]  divisor,

    output logic [6:0]  cociente,
    output logic [6:0]  resto,
    output logic        done
);

    typedef enum logic [1:0] {IDLE, INIT, STEP, FIN} state_t;
    state_t estado, next;

    logic [7:0] A;
    logic [6:0] Q;
    logic [6:0] M;
    logic [3:0] bit_count;

    always_comb begin
        next = estado;
        case (estado)
            IDLE: if (start) next = INIT;
            INIT: next = STEP;
            STEP: if (bit_count == 4'd6) next = FIN;
            FIN:  next = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            estado <= IDLE;
            A <= 0;
            Q <= 0;
            M <= 0;
            bit_count <= 0;
            done <= 0;
            cociente <= 0;
            resto <= 0;
        end else begin
            estado <= next;
            done <= 0;

            case (next)

                INIT: begin
                    A <= 0;
                    Q <= dividendo;
                    M <= divisor;
                    bit_count <= 0;
                end

                STEP: begin
                    logic [7:0] shiftedA;
                    logic [6:0] shiftedQ;
                    logic [7:0] trial;
                    logic [7:0] nextA;
                    logic [6:0] nextQ;

                    shiftedA = {A[6:0], Q[6]};
                    shiftedQ = {Q[5:0], 1'b0};
                    trial = shiftedA - {1'b0, M};

                    if (trial[7]) begin
                        nextA = shiftedA;
                        nextQ = {shiftedQ[6:1], 1'b0};
                    end else begin
                        nextA = trial;
                        nextQ = {shiftedQ[6:1], 1'b1};
                    end

                    A <= nextA;
                    Q <= nextQ;
                    bit_count <= bit_count + 1;
                end

                FIN: begin
                    cociente <= Q;
                    resto    <= A[6:0];
                    done     <= 1;
                end
            endcase
        end
    end
endmodule
