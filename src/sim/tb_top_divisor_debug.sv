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

    // Clock
    always #10 clk = ~clk; // 50MHz

    // --- ENVÍO DE NIBBLES ---
   task send_nibble(input [3:0] val);
       begin
           fil = 4'hF;        // garantizar cambio previo
           @(posedge clk);

           fil = val;         // enviar nibble
           @(posedge clk);    // mantener un ciclo

           fil = 4'hF;        // regreso a idle
           @(posedge clk);

           @(posedge clk);    // tiempo extra para FSM
    
       end
    endtask

    task send_hex(input [3:0] val);
        begin
            // 1) Idle estable
            fil = 4'hF;
            repeat (10) @(posedge clk);
            // 2) Valor real estable
            fil = val;
            repeat (10) @(posedge clk);
            // 3) Vuelta a idle estable
            fil = 4'hF;
            repeat (10) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb_top_divisor_debug.vcd");
        $dumpvars(0, tb_top_divisor_debug);

        rst = 0;
        repeat(5) @(posedge clk);
        rst = 1;
        repeat(5) @(posedge clk);

        $display("\n=== TEST: A=0x45, B=0x07 ===");

        send_hex(8'h45);
        send_hex(8'h07);

        @(posedge done_debug);

        $display("A=%0d  B=%0d  Q=%0d  R=%0d",
                 A_debug, B_debug, Q_debug, R_debug);

        #50;
        $display("\nFIN SIMULACIÓN");
        $finish;
    end

endmodule
