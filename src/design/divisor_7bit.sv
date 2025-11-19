module divisor_7bit (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic [6:0]  A,   // dividendo
    input  logic [6:0]  B,   // divisor

    output logic [6:0]  Q,   // cociente
    output logic [6:0]  R,   // residuo
    output logic        done
);

    logic [6:0] regA, regB, regQ, regR;
    logic [3:0] i;
    logic busy;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            regA <= 0;
            regB <= 0;
            regQ <= 0;
            regR <= 0;
            i    <= 0;
            busy <= 0;
            done <= 0;
        end
        else begin
            if (start && !busy) begin
                regA <= A;
                regB <= B;
                regQ <= 0;
                regR <= 0;
                i    <= 7;   // 7 iteraciones
                busy <= 1;
                done <= 0;
            end
            else if (busy) begin
                {regR, regA} <= {regR, regA} << 1;   // shift
                regR = regR - regB;

                if (regR[6] == 1) begin
                    regR = regR + regB;             // restore
                    regQ[i] <= 0;
                end 
                else begin
                    regQ[i] <= 1;
                end

                if (i == 0) begin
                    busy <= 0;
                    done <= 1;
                end else begin
                    i <= i - 1;
                end
            end
        end
    end

    assign Q = regQ;
    assign R = regR;

endmodule

