module debounce (
    input  logic clk,
    input  logic rst,
    input  logic key,
    output logic key_pressed
);

    parameter int N = 12;
    logic [N-1:0] reg_sat, reg_next;
    logic SAMPLE1, SAMPLE2;
    logic reg_reset, reg_add;
    logic key_stable;

    assign reg_reset = (SAMPLE1 ^ SAMPLE2);
    assign reg_add   = ~reg_sat[N-1];

    always_comb begin
        case ({reg_reset, reg_add})
            2'b00: reg_next = reg_sat;
            2'b01: reg_next = reg_sat + 1'b1;
            default: reg_next = '0;
        endcase
    end

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            SAMPLE1     <= 1'b1;
            SAMPLE2     <= 1'b1;
            reg_sat     <= '0;
            key_stable  <= 1'b1;
            key_pressed <= 1'b1;
        end else begin
            SAMPLE1 <= key;
            SAMPLE2 <= SAMPLE1;
            reg_sat <= reg_next;
            if (reg_sat[N-1])
                key_stable <= SAMPLE2;

            key_pressed <= key_stable ? 1'b1 : 1'b0;
        end
    end
endmodule
