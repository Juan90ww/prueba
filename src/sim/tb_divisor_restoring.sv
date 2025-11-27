`timescale 1ns/1ps

module tb_divisor_restoring;

    logic clk, rst, start;
    logic [6:0] A, B;
    logic [6:0] Q, R;
    logic done;

    divisor_restoring dut(
        .clk(clk), .rst(rst),
        .start(start),
        .A_in(A), .B_in(B),
        .Q(Q), .R(R), .done(done)
    );

    always #5 clk = ~clk;

    task dividir(input int a, input int b);
        A = a;
        B = b;
        start = 1;
        @(posedge clk);
        start = 0;

        wait(done);
        int q = a / b;
        int r = a % b;

        if (Q !== q || R !== r)
            $error("ERROR %0d/%0d -> got Q=%0d R=%0d expected Q=%0d R=%0d",
                    a,b,Q,R,q,r);
        else
            $display("OK %0d/%0d = Q=%0d R=%0d", a,b,Q,R);
    endtask

    initial begin
        $dumpfile("tb_divisor_restoring.vcd");
        $dumpvars(0, tb_divisor_restoring);

        clk = 0; rst = 0; start = 0;
        repeat(4) @(posedge clk);
        rst = 1;

        dividir(50, 7);
        dividir(35, 5);
        dividir(63, 8);
        dividir(100, 15);

        $finish;
    end

endmodule

