`timescale 1ns/1ps

module tb_captura_operandos;

    logic clk, rst;
    logic [3:0] tecla;
    logic tecla_valida;
    logic [6:0] A_bin, B_bin;
    logic ready;

    captura_operandos dut(
        .clk(clk), .rst(rst),
        .tecla(tecla),
        .tecla_valida(tecla_valida),
        .A_bin(A_bin),
        .B_bin(B_bin),
        .ready_operands(ready)
    );

    always #5 clk = ~clk;

    task press(input [3:0] t);
        tecla = t;
        tecla_valida = 1;
        @(posedge clk);
        tecla_valida = 0;
        @(posedge clk);
    endtask

    initial begin
        $dumpfile("tb_captura_operandos.vcd");
        $dumpvars(0, tb_captura_operandos);

        clk = 0; rst = 0; tecla = 0; tecla_valida = 0;
        repeat(3) @(posedge clk);
        rst = 1;

        // A = 45
        press(4'h4); // A_hi
        press(4'h5); // A_lo

        // B = 23
        press(4'h2); // B_hi
        press(4'h3); // B_lo

        @(posedge clk);

        if (!ready) $error("No llegó a estado READY");
        if (A_bin !== 7'h45) $error("A_bin incorrecto");
        if (B_bin !== 7'h23) $error("B_bin incorrecto");

        $display("captura_operandos OK");
        $finish;
    end

endmodule

