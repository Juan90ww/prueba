module display_bin_hex (
    input  logic [3:0] switch,
    output logic [6:0] seven
);
    always_comb begin
        seven = 7'b1111111;
        case (switch)
            4'h0: seven = 7'b0000001;
            4'h1: seven = 7'b1001111;
            4'h2: seven = 7'b0010010;
            4'h3: seven = 7'b0000110;
            4'h4: seven = 7'b1001100;
            4'h5: seven = 7'b0100100;
            4'h6: seven = 7'b0100000;
            4'h7: seven = 7'b0001111;
            4'h8: seven = 7'b0000000;
            4'h9: seven = 7'b0000100;
            4'hA: seven = 7'b0001000;
            4'hB: seven = 7'b1100000;
            4'hC: seven = 7'b0110001;
            4'hD: seven = 7'b1000010;
            4'hE: seven = 7'b0110000;
            4'hF: seven = 7'b1111111; 
        endcase
    end
endmodule
