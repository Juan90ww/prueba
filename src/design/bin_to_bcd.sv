module bin_to_bcd #(
    parameter IN_WIDTH = 11,
    parameter DIGITS   = 4
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic [IN_WIDTH-1:0] bin_in,

    output logic [3:0] bcd3, bcd2, bcd1, bcd0,
    output logic       done
);

    localparam SHIFT_W = IN_WIDTH + 4*DIGITS;

    logic [SHIFT_W-1:0] shift_reg;
    logic [$clog2(IN_WIDTH+1)-1:0] bit_cnt;

    integer i;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 0;
            bit_cnt   <= 0;
            done      <= 0;
        end else begin
            if (start) begin
                shift_reg <= { {(4*DIGITS){1'b0}}, bin_in };
                bit_cnt   <= 0;
                done      <= 0;
            end else if (!done) begin
                // add-3
                for (i = 0; i < DIGITS; i++) begin
                    if (shift_reg[IN_WIDTH + 4*i +: 4] >= 5)
                        shift_reg[IN_WIDTH + 4*i +: 4] <=
                            shift_reg[IN_WIDTH + 4*i +: 4] + 3;
                end

                shift_reg <= shift_reg << 1;
                bit_cnt   <= bit_cnt + 1;

                if (bit_cnt + 1 == IN_WIDTH)
                    done <= 1;
            end
        end
    end

    assign bcd3 = shift_reg[IN_WIDTH + 12 +: 4];
    assign bcd2 = shift_reg[IN_WIDTH +  8 +: 4];
    assign bcd1 = shift_reg[IN_WIDTH +  4 +: 4];
    assign bcd0 = shift_reg[IN_WIDTH +  0 +: 4];

endmodule
