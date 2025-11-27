`timescale 1ns/1ps

module tb_top_divisor;

    logic clk = 0;
    logic rst = 0;

    logic [3:0] fil;
    logic [3:0] col;

    logic [3:0] anodo;
    logic [6:0] seven;

    always #5 clk = ~clk;

    top_divisor dut(
        .clk(clk),
        .rst(rst),
        .fil(fil),
        .col(col),
        .anodo(anodo),
        .seven(seven)
    );

    initial begin
        $dumpfile("tb_top_divisor.vcd");
        $dumpvars(0, tb_top_divisor);

        rst = 0;
        fil = 4'b1111;
        #50 rst = 1;

        press_key(7);  // A = 0x7F
        press_key(15);

        press_key(5);  // B = 0x50
        press_key(0);

        #200000;

        $display("FIN SIMULACIÓN TOP");
        $finish;
    end

    // modelo para keypad
    task press_key(input int hex);
        begin
            repeat(5000) begin
                @(posedge clk);
                fil = fila_por_hex(hex, col);
            end
            fil = 4'b1111;
            repeat(2000) @(posedge clk);
        end
    endtask

    // traduce un valor hex a una fila válida según columna activa
    function logic [3:0] fila_por_hex(input int val, input logic [3:0] col);
        case (col)
            4'b0111: fila_por_hex = (val==1)?4'b0111:(val==4)?4'b1011:(val==7)?4'b1101:(val==14)?4'b1110:4'b1111;
            4'b1011: fila_por_hex = (val==2)?4'b0111:(val==5)?4'b1011:(val==8)?4'b1101:(val==0)?4'b1110:4'b1111;
            4'b1101: fila_por_hex = (val==3)?4'b0111:(val==6)?4'b1011:(val==9)?4'b1101:(val==15)?4'b1110:4'b1111;
            4'b1110: fila_por_hex = (val==10)?4'b0111:(val==11)?4'b1011:(val==12)?4'b1101:(val==13)?4'b1110:4'b1111;
            default: fila_por_hex = 4'b1111;
        endcase
    endfunction

endmodule
