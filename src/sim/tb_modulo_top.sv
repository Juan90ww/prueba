module tb_divisor;

    logic clk;
    logic rst_n;
    logic start;
    logic [6:0] A, B;
    logic [6:0] Q, R;
    logic done;

    divisor_7bit dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(A),
        .B(B),
        .Q(Q),
        .R(R),
        .done(done)
    );

    // clock
    always #5 clk = ~clk;

    task run_test(input int a, input int b);
    begin
        A = a;
        B = b;
        start = 1;
        @(posedge clk);
        start = 0;

        wait (done);

        $display("A=%0d  B=%0d  =>  Q=%0d  R=%0d", A, B, Q, R);
        @(posedge clk);
    end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        @(posedge clk);
        rst_n = 1;

        // Caso 1
        run_test(0, 5);

        // Caso 2
        run_test(123, 3);

        // Caso 3
        run_test(127, 7);

        $finish;
    end

endmodule

