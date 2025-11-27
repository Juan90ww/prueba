`timescale 1ns/1ps

module tb_top_divisor_printf;

    // Señales del sistema
    logic clk = 0;
    logic rst = 0;

    // Señales del teclado simulado
    logic [3:0] fil;
    wire  [3:0] col;  

    // Señales del display (no se analizan)
    wire [3:0] anodo;
    wire [6:0] seven;

    // ----------------------------------------------------------
    //   Instancia del DUT (top_divisor)
    // ----------------------------------------------------------
    top_divisor dut(
        .clk(clk),
        .rst(rst),
        .fil(fil),
        .col(col),
        .anodo(anodo),
        .seven(seven)
    );

    // ----------------------------------------------------------
    // Clock  (50 MHz sim → 20 ns)
    // ----------------------------------------------------------
    always #10 clk = ~clk;

    // ----------------------------------------------------------
    // Procedimiento para simular una tecla presionada
    // ----------------------------------------------------------
    task press_key(input [3:0] code);
        begin
            // El módulo "teclado" produce tecla_hex = code
            // cuando detecta una fila baja.
            fil = 4'b0111;  // fila simulada baja
            force dut.tecla_hex = code;
            #100_000;       // tiempo suficiente para debounce
            fil = 4'b1111;  // liberar
            #50_000;
        end
    endtask

    // ----------------------------------------------------------
    // Enviar un byte hex como dos teclas
    // Ej: send_hex(8'h4F) → tecla '4', tecla 'F'
    // ----------------------------------------------------------
    task send_hex(input [7:0] val);
        begin
            press_key(val[7:4]);
            press_key(val[3:0]);
        end
    endtask


    // ----------------------------------------------------------
    // Monitoreo de resultados
    // ----------------------------------------------------------
    initial begin
        $dumpfile("tb_top_divisor_printf.vcd");
        $dumpvars(0, tb_top_divisor_printf);

        // Inicio
        rst = 0; fil = 4'b1111;
        #100;
        rst = 1;

        // ======================================================
        //   PRUEBA 1: A = 45h = 69, B = 07h = 7
        // ======================================================
        $display("=== TEST 1 ===");
        send_hex(8'h45);  // A = 0x45
        send_hex(8'h07);  // B = 0x07

        wait (dut.div_done == 1);

        $display("A = %0d  B = %0d  Q = %0d  R = %0d",
                  dut.A_bin, dut.B_bin,
                  dut.Cociente, dut.Residuo);

        #1000;

        // ======================================================
        //   PRUEBA 2: A = 7Eh = 126, B = 09h = 9
        // ======================================================
        $display("=== TEST 2 ===");
        send_hex(8'h7E);  // A = 126
        send_hex(8'h09);  // B = 9

        wait (dut.div_done == 1);

        $display("A = %0d  B = %0d  Q = %0d  R = %0d",
                  dut.A_bin, dut.B_bin,
                  dut.Cociente, dut.Residuo);

        #1000;

        // ------------------------------------------------------
        // Terminar simulación
        // ------------------------------------------------------
        $display("FIN SIMULACIÓN TOP DIVISOR PRINTF");
        $finish;
    end

endmodule
