module display_7seg_mux (
    input  logic       clk,
    input  logic [7:0] aciertos,
    input  logic [7:0] fallos,
    output logic [6:0] display_7seg,
    output logic [3:0] select_7seg
);

    logic [3:0] numero;
    logic [1:0] count;

    // Activa los displays de aciertos y fallos
    always_ff @(posedge clk) begin
        if (count == 2'b11) begin
            count <= 2'b00;
        end else begin
            count <= count + 1;
        end
    end

    // Selector de digito para 7 segmentos (Activo en bajo)
    always_comb begin
        case (count)
            2'b00: begin 
                numero = aciertos[7:4]; // Decenas de aciertos
                select_7seg = 4'b1110; // Activa el display Decenas de aciertos
            end

            2'b01: begin
                numero = aciertos[3:0]; // Unidades de aciertos
                select_7seg = 4'b1101; // Activa el display Unidades de aciertos
            end

            2'b10: begin
                numero = fallos[7:4]; // Decenas de fallos
                select_7seg = 4'b1011; // Activa el display Decenas de fallos
            end

            2'b11: begin
                numero = fallos[3:0]; // Unidades de fallos
                select_7seg = 4'b0111; // Activa el display Unidades de fallos
            end

            default: begin
                numero = 4'b0;
                select_7seg = 4'b0000;
            end
        endcase
    end
    
    // Decodificador BCD a 7 segmentos
    always_comb begin
        case (numero)
            4'd0: display_7seg[6:0] = 7'b000_0001; // 0
            4'd1: display_7seg[6:0] = 7'b100_1111; // 1
            4'd2: display_7seg[6:0] = 7'b001_0010; // 2
            4'd3: display_7seg[6:0] = 7'b000_0110; // 3
            4'd4: display_7seg[6:0] = 7'b100_1100; // 4
            4'd5: display_7seg[6:0] = 7'b010_0100; // 5
            4'd6: display_7seg[6:0] = 7'b010_0000; // 6
            4'd7: display_7seg[6:0] = 7'b000_1111; // 7
            4'd8: display_7seg[6:0] = 7'b000_0000; // 8
            4'd9: display_7seg[6:0] = 7'b000_0100; // 9
            default: display_7seg[6:0] = 7'b111_1111;
        endcase
    end
    
endmodule