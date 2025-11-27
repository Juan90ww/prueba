`timescale 1ns/1ps

module tb_divisor_auto;

    logic clk = 0;
    logic rst = 0;
    logic start;

    logic [6:0] A_in, B_in;
    logic [6:0] Q, R;
    logic done;

    // reloj 10ns
    always #5 clk = ~clk;

    divisor_restoring_7bits uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A_in(A_in),
        .B_in(B_in),
        .Q(Q),
        .R(R),
        .done(done)
    );

    initial begin
        $dumpfile("tb_divisor_auto.vcd");
        $dumpvars(0, tb_divisor_auto);

        rst = 0;
        start = 0;
        #20 rst = 1;

        test_case( 7 , 2 );
        test_case( 50, 7 );
        test_case( 99, 5 );
        test_case(120, 10 );

        $display("FIN DE SIMULACION DIVISOR");
        $finish;
    end

    task test_case(input int A, input int B);
        begin
            @(posedge clk);
            A_in = A;
            B_in = B;
            start = 1;
            @(posedge clk);
            start = 0;

            wait(done);
            $display("A=%0d B=%0d  => Q=%0d R=%0d", A_in,B_in,Q,R);
        end
    endtask

endmodule
