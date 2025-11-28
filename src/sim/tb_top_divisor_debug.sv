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
            @(posedge clk);    // sincronizado
            fil = val;
            @(posedge clk);    // mantenerlo 1 ciclo completo
            fil = 4'hF;
            @(posedge clk);    // volver a idle

        // tiempo extra para que la FSM procese
            @(posedge clk);
            @(posedge clk);
        end
    endtask


    initial begin
        $dumpfile("tb_top_divisor_debug.vcd");
        $dumpvars(0, tb_top_divisor_debug);

        // DEBUG: confirmar que el TB arranca
        $display("TB arrancando...");

        rst = 0;
        repeat(8) @(posedge clk);
        rst = 1;
        repeat(8) @(posedge clk);

        $display("\n=== TEST: A=0x45, B=0x07 ===");

        send_hex(8'h45);
        send_hex(8'h07);

        // esperar flanco de done (robusto frente a pulsos cortos)
        @(posedge done_debug);

        $display("A=%0d  B=%0d  Q=%0d  R=%0d",
            A_debug, B_debug, Q_debug, R_debug
        );

        #100;
        $display("\nFIN SIMULACIÓN");
        $finish;
    end

endmodule

