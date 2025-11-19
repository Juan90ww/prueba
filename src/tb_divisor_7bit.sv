module tb_divisor_7bit;

    timeunit 1ns; timeprecision 1ps;

    logic clk;
    logic rst_n;
    logic start;
    logic [6:0] A, B;

    logic [6:0] Q, R;
    logic done, busy;

    // Clock 10ns
    always #5 clk = ~clk;

    divisor_7bit dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .dividendo(A),
        .divisor(B),
        .cociente(Q),
        .residuo(R),
        .done(done),
        .busy(busy)
    );

    task do_test(input [6:0] a, input [6:0] b);
    begin
        A = a;
        B = b;
        start = 1;
        @(posedge clk);
        start = 0;

        wait(done);
        $display("DIVISION: %0d / %0d = COCIENTE %0d, RESIDUO %0d",
                 a, b, Q, R);
        @(posedge clk);
    end
    endtask

    initial begin
        $dumpfile("div_7bit.vcd");
        $dumpvars(0, tb_divisor_7bit);

        clk = 0;
        rst_n = 0;
        start = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        $display("===== CASO 1: 50 / 5 =====");
        do_test(50, 5);

        $display("===== CASO 2: 100 / 7 =====");
        do_test(100, 7);

        $display("===== CASO 3: 127 / 3 =====");
        do_test(127, 3);

        $finish;
    end

endmodule


