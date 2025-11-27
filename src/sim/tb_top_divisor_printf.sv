`timescale 1ns/1ps

module tb_top_divisor_printf;

    logic clk = 0;
    logic rst = 0;

    logic [3:0] fil = 4'hF;
    logic [3:0] col;

    logic [3:0] anodo;
    logic [6:0] seven;

    logic [7:0] A_bin_debug, B_bin_debug;
    logic [6:0] Q_debug, R_debug;
    logic       div_done_debug;

    // Instanciamos el TOP DE DEBUG (IMPORTANTE)
    top_divisor_debug dut(
        .clk(clk),
        .rst(rst),
        .fil(fil),
        .col(col),
        .anodo(anodo),
        .seven(seven),

        .A_bin_debug(A_bin_debug),
        .B_bin_debug(B_bin_debug),
        .Q_debug(Q_debug),
        .R_debug(R_debug),
        .div_done_debug(div_done_debug)
    );

    // Clock 50 MHz
    always #10 clk = ~clk;

    // Simular presionar un nibble HEX directamente (bypass)
    task press_hex(input [3:0] h);
        begin
            fil = h;
            repeat (5) @(posedge clk);
            fil = 4'hF;
            repeat (5) @(posedge clk);
        end
    endtask

    // A = dos nibbles, B = dos nibbles
    task send_hex2(input [7:0] v);
        press_hex(v[7:4]);
        press_hex(v[3:0]);
    endtask

    initial begin
        $dumpfile("tb_top_divisor_printf.vcd");
        $dumpvars(0, tb_top_divisor_printf);

        rst = 0;
        repeat(10) @(posedge clk);
        rst = 1;
        repeat(20) @(posedge clk);

        $display("\n=== TEST 1: A=0x45, B=0x07 ===");

        send_hex2(8'h45);
        send_hex2(8'h07);

        wait(div_done_debug == 1);

        $display("A=%0d  B=%0d  Q=%0d  R=%0d",
            A_bin_debug, B_bin_debug,
            Q_debug, R_debug);

        repeat(100) @(posedge clk);
        $display("\nFIN SIMULACIÓN");
        $finish;
    end

endmodule
