`timescale 1ns/1ps

module divisor_restoring_7bits;

    logic clk = 0;
    logic rst = 0;
    logic start = 0;

    logic [6:0] A_in;
    logic [6:0] B_in;

    wire [6:0] Q;
    wire [6:0] R;
    wire done;

    // ========= Instancia del divisor =========
    divisor_restoring_7bits dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A_in(A_in),
        .B_in(B_in),
        .Q(Q),
        .R(R),
        .done(done)
    );

    // ==== reloj 50MHz ====
    always #10 clk = ~clk;

    // ==== tarea genérica para probar un caso ====
    task test_case(input [6:0] A, input [6:0] B);
        begin
            A_in = A;
            B_in = B;

            // pulso de start
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;

            // esperar a que termine
            wait(done == 1);

            $display("A=%0d  B=%0d  →  Q=%0d  R=%0d", A, B, Q, R);

            // esperar un poco antes del siguiente test
            repeat(10) @(posedge clk);
        end
    endtask

    // ==== SECUENCIA DE PRUEBAS ====
    initial begin
      $dumpfile("tb_divisor_7bits.vcd");
      $dumpvars(0,tb_divisor_7bits);

        rst = 0;
        #50;
        rst = 1;
        #50;

        $display("\n=== INICIO PRUEBAS DIVISOR ===");

        test_case(127, 30);
        test_case(60 , 60);
        test_case(10 , 2 );
        test_case(0  , 10);

        $display("\n=== FIN PRUEBAS ===");
        $finish;
    end

endmodule
