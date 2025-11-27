`timescale 1ns/1ps
module tb_bin2bcd;

    logic clk = 0;
    logic rst = 0;
    logic start;
    logic [6:0] bin;
    logic [3:0] bcd3,bcd2,bcd1,bcd0;
    logic done;

    always #5 clk = ~clk;

    bin2bcd #(.N(7)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .bin(bin),
        .bcd3(bcd3), .bcd2(bcd2),
        .bcd1(bcd1), .bcd0(bcd0),
        .done(done)
    );

    initial begin
        $dumpfile("tb_bin2bcd.vcd");
        $dumpvars(0,tb_bin2bcd);

        rst=0; start=0; bin=0;
        #20 rst=1;

        test_bcd(7);
        test_bcd(53);
        test_bcd(99);
        test_bcd(120);

        $display("FIN TEST BCD");
        $finish;
    end

    task test_bcd(input int x);
        begin
            @(posedge clk);
            bin = x;
            start = 1;
            @(posedge clk) start = 0;

            wait(done);
            $display("bin=%0d -> BCD = %0d %0d %0d %0d",
                x, bcd3,bcd2,bcd1,bcd0);
        end
    endtask

endmodule
