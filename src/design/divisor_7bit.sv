module divisor_7bit (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic [6:0]  dividendo,
    input  logic [6:0]  divisor,

    output logic [6:0]  cociente,
    output logic [6:0]  residuo,
    output logic        done,
    output logic        busy
);

    // Registros internos
    logic [6:0] A_reg;       // dividendo
    logic [6:0] B_reg;       // divisor
    logic [7:0] R;           // residuo extendido (1 bit más)
    logic [6:0] Q;           // cociente
    logic [3:0] counter;     // hasta 7 ciclos

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        RUN,
        FINISH
    } state_t;

    state_t state, next_state;

    // Máquina de estados
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Transiciones
    always_comb begin
        next_state = state;
        case (state)
            IDLE:   if (start) next_state = LOAD;
            LOAD:   next_state = RUN;
            RUN:    if (counter == 0) next_state = FINISH;
            FINISH: next_state = IDLE;
        endcase
    end

    // Señales de estado
    assign busy = (state == RUN);
    assign done = (state == FINISH);

    // Datapath
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            R <= 0;
            Q <= 0;
            counter <= 0;
            A_reg <= 0;
            B_reg <= 0;
        end else begin

            case (state)

                LOAD: begin
                    A_reg <= dividendo;
                    B_reg <= divisor;
                    R <= 0;
                    Q <= 0;
                    counter <= 7;   // 7 bits → 7 iteraciones
                end

                RUN: begin
                    // 1) SHIFT del residuo e ingreso del bit MSB de A
                    R <= {R[6:0], A_reg[counter-1]};

                    // 2) Prueba de resta
                    if (R >= B_reg) begin
                        R <= R - B_reg;
                        Q[counter-1] <= 1;
                    end else begin
                        Q[counter-1] <= 0;
                    end

                    counter <= counter - 1;
                end

                FINISH: begin
                    // Nada especial
                end

            endcase
        end
    end

    assign cociente = Q;
    assign residuo  = R[6:0];

endmodule
