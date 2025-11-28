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

    // Instanciamos el TOP correcto
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

    always #10 clk = ~clk; // 50MHz

    // --- ENVÍO DE NIBBLES ---

    task send_nibble(input [3:0] val);
        begin
            fil = val;
            @(posedge clk); @(posedge clk);
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
        #50;
        rst = 1;

        $display("\n=== TEST: A=0x45, B=0x07 ===");

        send_hex(8'h45);
        send_hex(8'h07);

        wait(done_debug == 1);

        $display("A=%0d  B=%0d  Q=%0d  R=%0d",
            A_debug, B_debug, Q_debug, R_debug
        );

        #100;
        $display("\nFIN SIMULACIÓN");
        $finish;
    end

endmodule
