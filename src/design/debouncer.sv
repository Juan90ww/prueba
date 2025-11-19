module debouncer #(
    parameter N = 20  // ajuste según frecuencia: 20 → ~1 ms a 27 MHz
)(
    input  logic clk,
    input  logic rst_n,
    input  logic noisy_in,
    output logic clean_out
);

    logic [N-1:0] cnt;
    logic sync_0, sync_1;
    logic state;

    // Sincronizador de 2 FF
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_0 <= 0;
            sync_1 <= 0;
        end else begin
            sync_0 <= noisy_in;
            sync_1 <= sync_0;
        end
    end

    // Debouncer
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            state <= 0;
        end else begin
            if (sync_1 != state) begin
                cnt <= cnt + 1;
                if (cnt == {N{1'b1}}) begin
                    state <= sync_1;
                    cnt <= 0;
                end
            end else begin
                cnt <= 0;
            end
        end
    end

    assign clean_out = state;

endmodule
