`timescale 1ns/1ps

module tb_bin2bcd;

    logic clk, rst, start, done;
    logic [6:0] bin;
    logic [3:0] d3,d2,d1,d0;

    bin2bcd #(.N(7)) dut(
        .clk(clk), .rst(rst),
        .start(start),
        .bin(bin),
        .bcd3(d3), .bcd2(d2), .bcd1(d1), .bcd0(d0),
        .done(done)
    );

    always #5 clk = ~clk;

    task convertir(input int value);
        bin = value;
        start = 1;
        @(posedge clk);
        start = 0;

        wait(done);

        int result = d3*1000 + d2*100 + d1*10 + d0;
        if (result !== value)
            $error("ERROR %0d -> BCD=%0d", value, result);
        else
            $display("OK %0d -> BCD=%0d", value, result);
    endtask

    initial begin
        $dumpfile("tb_bin2bcd.vcd");
        $dumpvars(0, tb_bin2bcd);

        clk=0; rst=0; start=0;
        repeat(3) @(posedge clk);
        rst=1;

        convertir(0);
        convertir(57);
        convertir(99);

        $finish;
    end
endmodule
