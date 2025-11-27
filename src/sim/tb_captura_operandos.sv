module tb_captura_operandos;

    logic clk, rst;
    logic [3:0] tecla;
    logic tecla_valida;

    logic [7:0] A_bin, B_bin;
    logic ready_operands;

    captura_operandos dut(
        .clk(clk), .rst(rst),
        .tecla(tecla),
        .tecla_valida(tecla_valida),
        .A_bin(A_bin), .B_bin(B_bin),
        .ready_operands(ready_operands)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task press(input int hex);
        begin
            tecla = hex;
            tecla_valida = 1;
            @(posedge clk);
            tecla_valida = 0;
            @(posedge clk);
        end
    endtask

    initial begin
        rst = 0; @(posedge clk); rst = 1;

        press(4);  // A_MSB
        press(2);  // A_LSB → A=0x42 = 66
        press(0);  // B_MSB
        press(8);  // B_LSB → B=0x08 = 8

        if (ready_operands)
            $display("A_bin=%0d  B_bin=%0d", A_bin, B_bin);

        $finish;
    end

endmodule
