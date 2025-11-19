module display_mux (
    input  logic        clk,
    input  logic        rst_n,

    input  logic [3:0]  d3,
    input  logic [3:0]  d2,
    input  logic [3:0]  d1,
    input  logic [3:0]  d0,

    output logic [3:0]  anodo,
    output logic [6:0]  seven
);

    logic [1:0] sel;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sel <= 0;
        else
            sel <= sel + 1;
    end

    logic [3:0] num;

    always_comb begin
        case (sel)
            2'd0: begin anodo = 4'b1110; num = d0; end
            2'd1: begin anodo = 4'b1101; num = d1; end
            2'd2: begin anodo = 4'b1011; num = d2; end
            2'd3: begin anodo = 4'b0111; num = d3; end
        endcase
    end

    always_comb begin
        case (num)
            0: seven = 7'b1000000;
            1: seven = 7'b1111001;
            2: seven = 7'b0100100;
            3: seven = 7'b0110000;
            4: seven = 7'b0011001;
            5: seven = 7'b0010010;
            6: seven = 7'b0000010;
            7: seven = 7'b1111000;
            8: seven = 7'b0000000;
            9: seven = 7'b0010000;
            default: seven = 7'b1111111;
        endcase
    end

endmodule
