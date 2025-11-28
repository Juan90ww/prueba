`timescale 1ns/1ps

module tb_top_divisor_debug;

    logic clk = 0;
    logic rst = 0;

    logic [3:0] fil = 4'hF;

    wire [3:0] col;
    wire [3:0] anodo;
    wire [6:0] seven;

    wire [7:0] A_debug;
    wire [7:0] B_debug;
    wire [6:0] Q_debug;
    wire [6:0] R_debug;
    wire       done_debug;

    // Instancia del TOP
    top_divisor_debug dut(
        .clk(clk),
        .rst(rst),
        .fil(fil),
        .col(col),
        .anodo(anodo),
        .seven(seven),
        .A_bin_debug(A_debug),
        .B_bin_debug(B_debug),
        .Q_debug(Q_debug),
        .R_debug(R_debug),
        .div_done_debug(done_debug)
    );

    always #10 clk = ~clk;  // 50 MHz

    // --- ENVÍO DE NIBBLES ---
    task send_nibble(input [3:0] val);
        begin
            fil = val;
            @(posedge clk);
            @(posedge clk);
            fil = 4'hF;
            repeat(3) @(posedge clk);
        end
    endtask

    task send_hex(input [7:0] val);
        begin
            send_nibble(val[7:4]);
            send_nibble(val[3:0]);
        end
    endtask

    initial begin
        $dumpfile("tb_top_divisor_debug.vcd");
        $dumpvars(0, tb_top_divisor_debug);

        rst = 0;
        repeat(8) @(posedge clk);
        rst = 1;
        repeat(8) @(posedge clk);

        $display("\n=== TEST: A= 45, B= 07 ===");

        send_hex(8'h1);
        send_hex(8'h1);

        fork
            begin
                @(posedge done_debug);
                $display("A=%0d  B=%0d  Q=%0d  R=%0d",
                    A_debug, B_debug, Q_debug, R_debug);
            end
            begin
                #2000000;
                $fatal("ERROR: Timeout esperando done_debug");
            end
        join_any
        disable fork;

        repeat(50) @(posedge clk);
        $display("FIN SIMULACIÓN");
        $finish;
    end

endmodule

