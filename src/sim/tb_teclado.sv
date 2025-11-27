`timescale 1ns/1ps

module tb_teclado;

    logic clk;
    logic [3:0] filas;
    logic [3:0] col;
    logic [3:0] boton;

    teclado dut (
        .clk(clk),
        .filas(filas),
        .columnas(col),
        .boton(boton)
    );

    always #5 clk = ~clk;

    task press(input [3:0] fila, input [3:0] esperado);
        filas = fila;
        repeat(20) begin
            @(posedge clk);
            if (boton == esperado) begin
                $display("OK tecla encontrada %b", esperado);
                disable press;
            end
        end
        $error("No se detectó tecla %b", esperado);
    endtask

    initial begin
        $dumpfile("tb_teclado.vcd");
        $dumpvars(0, tb_teclado);

        clk = 0;
        filas = 4'b1111;

        repeat(10) @(posedge clk);

        press(4'b0111, 4'b0001); // tecla 1
        press(4'b1011, 4'b0101); // tecla 5
        press(4'b1101, 4'b0111); // tecla 7

        $finish;
    end
endmodule
