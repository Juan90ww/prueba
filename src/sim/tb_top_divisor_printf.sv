`timescale 1ns/1ps

module tb_top_divisor_printf;

    // ===========================
    //  RELOJ / RESET
    // ===========================
    logic clk = 0;
    logic rst = 0;

    always #10 clk = ~clk;    // 50 MHz

    // ===========================
    //  INSTANCIA DEL TOP DEBUG
    // ===========================
    logic [3:0] fil;

    wire [3:0] col;       // no usado
    wire [3:0] anodo;
    wire [6:0] seven;

    wire [7:0] A_dbg;
    wire [7:0] B_dbg;
    wire [6:0] Q_dbg;
    wire [6:0] R_dbg;
    wire       done_dbg;

    top_divisor_debug dut (
        .clk(clk),
        .rst(rst),
        .fil(fil),
        .col(col),
        .anodo(anodo),
        .seven(seven),

        .A_bin_debug(A_dbg),
        .B_bin_debug(B_dbg),
        .Q_debug(Q_dbg),
        .R_debug(R_dbg),
        .div_done_debug(done_dbg)
    );

    // ===========================
    //  SIMULAR PRESIÓN DE TECLA
    // ===========================
    task press_key(input [3:0] hex);
        begin
            fil = hex;
            repeat (20) @(posedge clk);   // mantener unos ciclos
            fil = 4'hF;                    // "soltar"
            repeat (20) @(posedge clk);
        end
    endtask

    task send_hex(input [7:0] value);
        begin
            press_key(value[7:4]);   // MSB
            press_key(value[3:0]);   // LSB
        end
    endtask


    // ===========================
    //  TEST
    // ===========================
    initial begin
        $dumpfile("tb_top_divisor_printf.vcd");
        $dumpvars(0, tb_top_divisor_printf);

        fil = 4'hF;
        rst = 0;
        repeat (10) @(posedge clk);
        rst = 1;

        $display("\n=== TEST 1: A = 0x45, B = 0x07 ===\n");

        send_hex(8'h45);   // A = 0x45 = 69
        send_hex(8'h07);   // B = 0x07 = 7

        wait(done_dbg);

        $display("A = %0d (0x%0h)", A_dbg, A_dbg);
        $display("B = %0d (0x%0h)", B_dbg, B_dbg);
        $display("Q = %0d", Q_dbg);
        $display("R = %0d\n", R_dbg);

        repeat (200) @(posedge clk);
        $display("FIN SIMULACIÓN");
        $finish;
    end

endmodule

