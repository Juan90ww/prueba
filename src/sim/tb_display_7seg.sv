`timescale 1ns/1ps

module tb_display_7seg;

    logic clk = 0;
    logic rst = 0;
    logic [15:0] digito;
    logic [3:0] anodo;
    logic [6:0] seven;

    always #5 clk = ~clk;

    display_7seg uut (
        .clk(clk),
        .rst(rst),
        .digito(digito),
        .anodo(anodo),
        .seven(seven)
    );

    initial begin
        $dumpfile("tb_display_7seg.vcd");
        $dumpvars(0,tb_display_7seg);

        rst = 0;
        digito = 16'h0123;
        #20 rst = 1;

        #20000 digito = 16'h9876;
        #20000 digito = 16'hFACE;

        #100000 $finish;
    end

endmodule
