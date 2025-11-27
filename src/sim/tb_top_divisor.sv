module tb_top_divisor;

    logic clk, rst;
    logic [3:0] fil;
    wire  [3:0] col;
    wire [3:0] anodo;
    wire [6:0] seven;

    top_divisor dut(
        .clk(clk), .rst(rst),
        .fil(fil),
        .col(col),
        .anodo(anodo), .seven(seven)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task tecla(input logic [3:0] row);
        begin
            fil = row;
            repeat(20000) @(posedge clk);
            fil = 4'b1111;
            repeat(20000) @(posedge clk);
        end
    endtask

    initial begin
        rst = 0; fil = 4'b1111;
        repeat(5) @(posedge clk);
        rst = 1;

        // Simular A = 42h, B = 08h
        tecla(4'b0111); // tecla 4
        tecla(4'b1011); // tecla 2
        tecla(4'b0111); // tecla 0
        tecla(4'b1101); // tecla 8

        repeat(500000) @(posedge clk);

        $finish;
    end

endmodule
