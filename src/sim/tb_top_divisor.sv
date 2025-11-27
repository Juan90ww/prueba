`timescale 1ns/1ps

module tb_top_divisor;

    logic clk, rst;
    logic [3:0] fil;
    logic [3:0] col;
    logic [3:0] anodo;
    logic [6:0] seven;

    top_divisor dut(
        .clk(clk), .rst(rst),
        .fil(fil), .col(col),
        .anodo(anodo), .seven(seven)
    );

    always #5 clk = ~clk;

    task press(input [3:0] fila, input [3:0] tecla_hex);
        fil = fila;
        repeat(5) @(posedge clk);
        fil = 4'b1111;
        repeat(5) @(posedge clk);
    endtask

    initial begin
        $dumpfile("tb_top_divisor.vcd");
        $dumpvars(0, tb_top_divisor);

        clk=0; rst=0; fil=4'b1111;
        repeat(5) @(posedge clk);
        rst=1;

        // A = 45 → tecla 4 y 5
        press(4'b1011, 4'h4);
        press(4'b1011, 4'h5);

        // B = 12 → tecla 1 y 2
        press(4'b0111, 4'h1);
        press(4'b0111, 4'h2);

        repeat(2000) @(posedge clk);

        $display("Simulación TOP completa");
        $finish;
    end

endmodule

