`timescale 1ns/1ps

module tb_top_divisor;

    logic clk = 0;
    logic rst = 0;

    logic [3:0] fil;  // FILAS (entradas)
    logic [3:0] col;  // COLUMNAS (salidas)

    logic [3:0] anodo;
    logic [6:0] seven;

    always #5 clk = ~clk;

    top_divisor dut (
        .clk(clk),
        .rst(rst),
        .fil(fil),
        .col(col),
        .anodo(anodo),
        .seven(seven)
    );

    initial begin
        $dumpfile("tb_top_divisor.vcd");
        $dumpvars(0,tb_top_divisor);

        rst = 0;
        fil = 4'b1111;   // sin presionar tecla
        #50 rst = 1;

        // ============================
        // Simular ingreso de A = 0x7F
        // ============================

        press_key(4'b0111); // 7
        press_key(4'b1110); // F

        // ============================
        // Simular ingreso de B = 0x05
        // ============================

        press_key(4'b0101); // 5
        press_key(4'b0000); // *

        #200000;

        $display("FIN SIMULACIÓN TOP");
        $finish;
    end

    // Simula una tecla presionada durante 2 ms
    task press_key(input logic [3:0] key);
        begin
            fil = key;
            #(2000); // tiempo presionada
            fil = 4'b1111; // liberar tecla
            #(2000);
        end
    endtask

endmodule
