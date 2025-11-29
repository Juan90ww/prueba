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

    logic [7:0] A;       // A es 8 bits (bit extra para signo)
    logic [6:0] Q;
    logic [6:0] M;
    logic [2:0] count;   // 3 bits -> 0..7

    //=====================================================
    //  FSM siguiente estado
    //=====================================================
    always_comb begin
        next = estado;
        case (estado)
            IDLE: if (start) next = INIT;

            INIT: next = STEP;

            STEP: if (count == 3'd7) 
                        next = FIN;
                  else 
                        next = STEP;

            FIN: next = IDLE;
        endcase
    end

    //=====================================================
    //  Secuencial
    //=====================================================
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            estado   <= IDLE;
            A        <= 0;
            Q        <= 0;
            M        <= 0;
            count    <= 0;
            cociente <= 0;
            resto    <= 0;
            done     <= 0;
        end else begin
            estado <= next;
            done   <= 0;

            case (estado)

                IDLE: begin
                    // no hacer nada
                end

                INIT: begin
                    A     <= 0;
                    Q     <= dividendo;
                    M     <= divisor;
                    count <= 0;
                end

                STEP: begin
                    // Shift left conjunto A:Q
                    logic [14:0] concat;
                    logic [14:0] shifted;
                    logic [7:0]  trialA;

                    concat  = {A, Q};                // 8 bits A + 7 bits Q
                    shifted = concat << 1;           // shift conjunto
                    trialA  = shifted[14:7] - {1'b0, M};

                    if (trialA[7] == 1'b1) begin
                        // resultado negativo → Restoring
                        A <= shifted[14:7];
                        Q <= {shifted[6:1], 1'b0};   // bit generado es 0
                    end else begin
                        // resultado positivo → aceptar resta
                        A <= trialA;
                        Q <= {shifted[6:1], 1'b1};   // bit generado es 1
                    end

                    count <= count + 1;
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

