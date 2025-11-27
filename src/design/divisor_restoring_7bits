module divisor_restoring_7bits (
    input  logic        clk,
    input  logic        rst,       // activo en 0
    input  logic        start,     // inicia la división
    input  logic [6:0]  dividendo,
    input  logic [6:0]  divisor,

    output logic [6:0]  cociente,
    output logic [6:0]  resto,
    output logic        done       // =1 cuando termina
);

    // =========================================================
    //            DECLARACIÓN DE ESTADOS
    // =========================================================
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        INIT  = 2'b01,
        STEP  = 2'b10,
        FIN   = 2'b11
    } state_t;

    state_t estado, next;

    // =========================================================
    //                REGISTROS INTERNOS
    // =========================================================

    logic [6:0] Q;          // cociente parcial
    logic [7:0] A;          // acumulador/resto parcial (8 bits para resta)
    logic [6:0] M;          // divisor
    logic [2:0] bit_count;  // 0–6 (7 iteraciones)

    // =========================================================
    //          LOGICA DE ESTADO SIGUIENTE (FSM)
    // =========================================================
    always_comb begin
        next = estado;
        case (estado)

            IDLE: begin
                if (start)
                    next = INIT;
            end

            INIT: begin
                next = STEP;
            end

            STEP: begin
                if (bit_count == 3'd6)
                    next = FIN;
                else
                    next = STEP;
            end

            FIN: begin
                next = IDLE;    // retornar a reposo
            end
        endcase
    end

    // =========================================================
    //            REGISTROS SECUENCIALES
    // =========================================================
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            estado    <= IDLE;
            A         <= 8'd0;
            Q         <= 7'd0;
            M         <= 7'd0;
            bit_count <= 3'd0;
            done      <= 1'b0;
        end
        else begin
            estado <= next;

            case (estado)

                // -----------------------------------------------------
                // IDLE: esperando start
                // -----------------------------------------------------
                IDLE: begin
                    done <= 1'b0;
                end

                // -----------------------------------------------------
                // INIT: cargar valores
                // -----------------------------------------------------
                INIT: begin
                    A         <= 8'd0;      // acumulador a 0
                    Q         <= dividendo; // cociente inicia como el dividendo
                    M         <= divisor;   // divisor fijo
                    bit_count <= 0;
                    done      <= 1'b0;
                end

                // -----------------------------------------------------
                // STEP: algoritmo RESTORING
                // -----------------------------------------------------
                STEP: begin
                    // 1) Desplazar A:Q a la izquierda
                    A <= {A[6:0], Q[6]};
                    Q <= {Q[5:0], 1'b0};

                    // 2) Intentar restar
                    A <= A - {1'b0, M};

                    // 3) Comprobar signo
                    if (A[7] == 1'b1) begin
                        // Resta negativa: restaurar
                        A <= A + {1'b0, M};
                        Q[0] <= 1'b0;
                    end else begin
                        // Resta válida
                        Q[0] <= 1'b1;
                    end

                    // Incrementar contador
                    bit_count <= bit_count + 1'b1;
                end

                // -----------------------------------------------------
                // FIN: cargar salidas
                // -----------------------------------------------------
                FIN: begin
                    cociente <= Q;
                    resto    <= A[6:0];
                    done     <= 1'b1;
                end

            endcase
        end
    end

endmodule
