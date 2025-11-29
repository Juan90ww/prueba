`timescale 1ns/1ps

module tb_divisor_4bits;

    // Señales internas
    logic clk;
    logic rst;
    logic start;
    logic [3:0] dividendo;
    logic [3:0] divisor;
    logic [3:0] cociente;
    logic [3:0] resto;
    logic done;

    // Contadores de verificación
    int errors = 0;
    int tests  = 0;

    // Instancia del DUT
    operacion #(.SCAN_DIV(5)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .dividendo(dividendo),
        .divisor(divisor),
        .cociente(cociente),
        .resto(resto),
        .done(done)
    );

    // Generador de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // periodo 10ns
    end

    // Tarea para ejecutar una división y verificar resultado
    task automatic run_test(input [3:0] A, input [3:0] B);
        int q_expected, r_expected;

        begin
            if (B == 0) begin
                $display("SKIP: divisor = 0 (A=%0d, B=%0d)", A, B);
                return;
            end

            tests++;

            // calcular valores esperados usando SystemVerilog
            q_expected = A / B;
            r_expected = A % B;

            // aplicar estímulo
            dividendo = A;
            divisor   = B;
            start     = 1;

            @(posedge clk);
            start = 0;

            // esperar done
            wait(done);

            // check
            if (cociente !== q_expected || resto !== r_expected) begin
                errors++;
                $display("FAILED: %0d / %0d  Expected Q=%0d R=%0d  Got Q=%0d R=%0d",
                         A, B, q_expected, r_expected, cociente, resto);
            end else begin
                $display("PASSED: %0d / %0d = Q:%0d R:%0d",
                         A, B, cociente, resto);
            end

            // esperar un ciclo antes del siguiente test
            @(posedge clk);
        end
    endtask

    // Secuencia principal
    initial begin
        rst = 1;
        start = 0;
        dividendo = 0;
        divisor = 0;

        repeat(5) @(posedge clk);
        rst = 0;
        repeat(5) @(posedge clk);
        rst = 1;

        $display("=== INICIANDO TESTS ===");

        // Prueba todos los valores 0..15
        for (int A = 0; A < 16; A++) begin
            for (int B = 1; B < 16; B++) begin
                run_test(A, B);
            end
        end

        $display("=== RESULTADOS ===");
        $display("Tests ejecutados: %0d", tests);
        $display("Fallos: %0d", errors);

        if (errors == 0)
            $display("TODAS LAS PRUEBAS PASARON ✔️");
        else
            $display("HUBO ERRORES ❌");

        $finish;
    end

endmodule
