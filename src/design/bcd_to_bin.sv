module bcd_to_bin (
    input  logic clk,
    input  logic en,
    input  logic [3:0] d2, d1, d0,
    output logic [10:0] value
);
    always_ff @(posedge clk) begin
        if (!en)
            value <= 0;
        else begin
            // 100*d2 + 10*d1 + d0
            value <= (d2 * 7'd100) + (d1 * 7'd10) + d0;
        end
    end
endmodule
