module teclado #(
    parameter int SCAN_DIV = 1

)(
    input  logic clk,
    input  logic [3:0] filas,
    output logic [3:0] columnas,
    output logic [3:0] boton
);

    localparam [3:0] K_NONE = 4'hF;

    logic [1:0] contador = 0;
    logic [$clog2(SCAN_DIV)-1:0] scan_col = 0;

    always_ff @(posedge clk) begin

        if (scan_col == SCAN_DIV-1) begin
            scan_col <= 0;
            contador <= (contador == 3) ? 0 : contador + 1;
        end 
        else scan_col <= scan_col + 1;

        case (contador)
            0: columnas <= 4'b0111;
            1: columnas <= 4'b1011;
            2: columnas <= 4'b1101;
            3: columnas <= 4'b1110;
        endcase

        boton <= K_NONE;

        case (columnas)
            4'b0111: begin
                if(filas==4'b0111) boton<=4'h1;
                if(filas==4'b1011) boton<=4'h4;
                if(filas==4'b1101) boton<=4'h7;
                if(filas==4'b1110) boton<=4'hE; // *
            end
            4'b1011: begin
                if(filas==4'b0111) boton<=4'h2;
                if(filas==4'b1011) boton<=4'h5;
                if(filas==4'b1101) boton<=4'h8;
                if(filas==4'b1110) boton<=4'h0;
            end
            4'b1101: begin
                if(filas==4'b0111) boton<=4'h3;
                if(filas==4'b1011) boton<=4'h6;
                if(filas==4'b1101) boton<=4'h9;
                if(filas==4'b1110) boton<=4'hF; // #
            end
            4'b1110: begin
                if(filas==4'b0111) boton<=4'hA;
                if(filas==4'b1011) boton<=4'hB;
                if(filas==4'b1101) boton<=4'hC;
                if(filas==4'b1110) boton<=4'hD;
            end
        endcase
    end
endmodule
