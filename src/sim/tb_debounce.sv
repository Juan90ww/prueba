`timescale 1ns/1ps

module tb_debounce;

    localparam int N = 12;
    logic clk, rst, key;
    logic key_pressed;

    debounce #(.N(N)) dut (
        .clk(clk),
        .rst(rst),
        .key(key),
        .key_pressed(key_pressed)
    );

    // Clock 10ns
    always #5 clk = ~clk;

    task wait_cycles(input int n);
        repeat(n) @(posedge clk);
    endtask

    initial begin
        $dumpfile("tb_debounce.vcd");
        $dumpvars(0, tb_debounce);

        clk = 0;
        rst = 0;
        key = 1;   // reposo

        wait_cycles(4);
        rst = 1;

        // Test 1: estable
        wait_cycles(3000);

        if (key_pressed !== 1)
            $error("ERROR: debouncer no detecta reposo");

        // Test 2: pulsación con rebotes
        key = 0;
        repeat(5) begin
            #3 key = ~key;
        end
        key = 0;

        wait_cycles(3000);
        if (key_pressed !== 0)
            $error("ERROR: debouncer no detecta tecla presionada");

        $display("Debouncer OK");
        $finish;
    end
endmodule
