`timescale 1ns/1ps

module tb_top_divisor_printf;

    logic clk = 0;
    logic rst = 0;

    logic [3:0] fil;
    wire  [3:0] col;

    wire [3:0] anodo;
    wire [6:0] seven;

    top_divisor dut(
        .clk(clk),
        .rst(rst),
        .fil(fil),
        .col(col),
        .anodo(anodo),
        .seven(seven)
    );

    // Clock 50 MHz
    always #10 clk = ~clk;

    // ============================================================
    // SIMULAR UNA TECLA:
    //  Bajamos una fila, dependiendo de la columna activa
    // ============================================================
    task press_key(input [3:0] hex);
        begin
            // Esperar a que el módulo teclado seleccione una columna
            repeat (4000) @(posedge clk);

            // Forzamos filas en función del key requested
            case(hex)
                4'h1: fil = 4'b0111;
                4'h2: fil = 4'b0111;
                4'h3: fil = 4'b0111;

                4'h4: fil = 4'b1011;
                4'h5: fil = 4'b1011;
                4'h6: fil = 4'b1011;

                4'h7: fil = 4'b1101;
                4'h8: fil = 4'b1101;
                4'h9: fil = 4'b1101;

                4'h0: fil = 4'b1110;

                4'hA: fil = 4'b1110;
                4'hB: fil = 4'b1110;
                4'hC: fil = 4'b1110;
                4'hD: fil = 4'b1110;

                default: fil = 4'b1111;
            endcase

            // Tiempo de presión
            repeat (5000) @(posedge clk);

            // Liberar tecla
            fil = 4'b1111;
            repeat (5000) @(posedge clk);
        end
    endtask

    task send_hex(input [7:0] val);
        begin
            press_key(val[7:4]); // MSB
            press_key(val[3:0]); // LSB
        end
    endtask

    // ============================================================
    // TEST
    // ============================================================
    initial begin
        $dumpfile("tb_top_divisor_printf.vcd");
        $dumpvars(0, tb_top_divisor_printf);

        fil = 4'b1111;

        #100;
        rst = 1;
        #1000;

        // ===========================
        //  TEST 1:  A = 0x45 , B = 0x07
        // ===========================
        $display("\n=== TEST 1: A=0x45, B=0x07 ===");

        send_hex(8'h45); // A
        send_hex(8'h07); // B

        wait (dut.div_done == 1);

        $display("A=%0d  B=%0d  Q=%0d  R=%0d",
            dut.A_bin, dut.B_bin,
            dut.Cociente, dut.Residuo);

        #10000;

        // ===========================
        //  TEST 2:  A = 0x7E , B = 0x09
        // ===========================
        $display("\n=== TEST 2: A=0x7E, B=0x09 ===");

        send_hex(8'h7E); // A
        send_hex(8'h09); // B

        wait (dut.div_done == 1);

        $display("A=%0d  B=%0d  Q=%0d  R=%0d",
            dut.A_bin, dut.B_bin,
            dut.Cociente, dut.Residuo);

        #50000;

        $display("\nFIN SIMULACIÓN TOP DIVISOR");
        $finish;
    end

endmodule

