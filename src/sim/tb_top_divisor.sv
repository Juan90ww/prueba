`timescale 1ns/1ps

module tb_top_divisor;

    logic clk = 0;
    logic rst = 0;

    // Señales del DUT que realmente importan
    logic start_div;
    logic [7:0] A_bin, B_bin;

    wire [6:0] Q;
    wire [6:0] R;
    wire div_done;

    //-----------------------------------------
    // 1) Generar reloj
    //-----------------------------------------
    always #10 clk = ~clk;   // 50 MHz

    //-----------------------------------------
    // 2) Instanciar SOLO el divisor
    //-----------------------------------------
    divisor_restoring dut (
        .clk(clk),
        .rst(rst),
        .start(start_div),
        .A_in(A_bin[6:0]),
        .B_in(B_bin[6:0]),
        .Q(Q),
        .R(R),
        .done(div_done)
    );

    //-----------------------------------------
    // 3) Tarea para probar una división
    //-----------------------------------------
    task test_div(
        input int A,
        input int B
    );
    begin
        A_bin = A;
        B_bin = B;

        $display("\n### Probando A = %0d   B = %0d ###", A, B);

        // Pulso de start
        start_div = 1;
        @(posedge clk);
        start_div = 0;

        // Esperar resultado
        wait(div_done == 1);

        $display("  Q = %0d   R = %0d", Q, R);
    end
    endtask

    //-----------------------------------------
    // 4) Secuencia principal
    //-----------------------------------------
    initial begin
        $dumpfile("tb_top_divisor_auto.vcd");
        $dumpvars(0, tb_top_divisor_auto);

        rst = 0;
        start_div = 0;
        A_bin = 0;
        B_bin = 0;

        repeat (5) @(posedge clk);
        rst = 1;

        // --- PRUEBAS AUTOMÁTICAS ---
        test_div(127, 7);
        test_div(85, 5);
        test_div(64, 8);
        test_div(123, 9);
        test_div(100, 13);
        test_div(99, 10);

        $display("\n=== TODAS LAS PRUEBAS TERMINADAS ===\n");
        $finish;
    end

endmodule


