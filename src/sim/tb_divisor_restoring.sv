module tb_divisor_restoring;

    logic clk, rst, start;
    logic [7:0] A_in, B_in;
    logic [7:0] Q, R;
    logic done;

    divisor_restoring dut(
        .clk(clk), .rst(rst),
        .start(start),
        .A_in(A_in), .B_in(B_in),
        .Q(Q), .R(R),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic run_div(input int A, input int B);
        begin
            A_in = A;
            B_in = B;
            start = 1;
            @(posedge clk);
            start = 0;

            wait(done);
            $display("A=%0d  B=%0d  →  Q=%0d  R=%0d", A, B, Q, R);
            @(posedge clk);
        end
    endtask

    initial begin
        rst = 0; @(posedge clk); rst = 1;

        run_div(64, 40);
        run_div(55, 10);
        run_div(13, 3);
        run_div(99, 8);

        $finish;
    end

endmodule


