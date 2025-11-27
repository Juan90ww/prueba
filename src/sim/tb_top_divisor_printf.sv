`timescale 1ns/1ps

module tb_top_divisor_printf;

    logic clk = 0;
    logic rst = 0;

    logic [3:0] fil = 4'b1111;
    wire  [3:0] col;

    wire [3:0] anodo;
    wire [6:0] seven;

    top_divisor_debug dut(
        .clk(clk),
        .rst(rst),
        .fil(fil),
        .col(col),
        .anodo(anodo),
        .seven(seven)
    );

    // Clock 50 MHz
    always #10 clk = ~clk;

    // =====================================================
    // ESPERAR A QUE EL TECLADO ACTIVE UNA COLUMNA ESPECÍFICA
    // =====================================================
    task wait_column(input [3:0] colcode);
        while (dut.col !== colcode)
            @(posedge clk);
    endtask

    // =====================================================
    // SIMULAR TECLA HEX
    // =====================================================
    task press_key(input [3:0] hex);
        begin
            case(hex)
                4'h1: begin wait_column(4'b1110); fil = 4'b0111; end
                4'h2: begin wait_column(4'b1101); fil = 4'b0111; end
                4'h3: begin wait_column(4'b1011); fil = 4'b0111; end

                4'h4: begin wait_column(4'b1110); fil = 4'b1011; end
                4'h5: begin wait_column(4'b1101); fil = 4'b1011; end
                4'h6: begin wait_column(4'b1011); fil = 4'b1011; end

                4'h7: begin wait_column(4'b1110); fil = 4'b1101; end
                4'h8: begin wait_column(4'b1101); fil = 4'b1101; end
                4'h9: begin wait_column(4'b1011); fil = 4'b1101; end

                4'h0: begin wait_column(4'b0111); fil = 4'b1110; end

                default: fil = 4'b1111;
            endcase

            // mantener la tecla presionada
            repeat (3000) @(posedge clk);

            // soltar tecla
            fil = 4'b1111;
            repeat (3000) @(posedge clk);
        end
    endtask

    // Secuencia HEX de dos dígitos
    task send_hex(input [7:0] value);
        press_key(value[7:4]);
        press_key(value[3:0]);
    endtask


    // =====================================================
    // TEST
    // =====================================================
    initial begin
        $dumpfile("tb_top_divisor_printf.vcd");
        $dumpvars(0, tb_top_divisor_printf);

        rst = 0;
        #100;
        rst = 1;
        #1000;

        $display("\n=== TEST 1: A=0x45, B=0x07 ===");

        send_hex(8'h45);
        send_hex(8'h07);

        wait (dut.div_done == 1);

        $display("A=%0d  B=%0d  Q=%0d  R=%0d",
            dut.A_bin, dut.B_bin,
            dut.Cociente, dut.Residuo);

        #10000;
        $display("\nFIN SIMULACIÓN");
        $finish;
    end

endmodule

