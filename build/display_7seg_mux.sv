module display_7seg_mux #(
    parameter CLK_FREQ = 100_000_000
)(
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] aciertos,
    input  logic [7:0] fallos,
    output logic [6:0] display_7seg,
    output logic [3:0] select_7seg
);

    logic [3:0] numero;
    logic [1:0] count;

    // Divisor de frecuencia para el multiplexado
    logic [16:0] contador_mux;

    localparam MUX_COUNT = CLK_FREQ / 4_000;

    // =========================================================
    // DIVISOR DE FRECUENCIA
    // =========================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            contador_mux <= 0;
            count <= 2'b00;
        end
        else begin
            if (contador_mux == MUX_COUNT - 1) begin
                contador_mux <= 0;

                if (count == 2'b11) begin
                    count <= 2'b00;
                end
                else begin
                    count <= count + 1;
                end
            end
            else begin
                contador_mux <= contador_mux + 1;
            end
        end
    end

    // =========================================================
    // SELECTOR DE DIGITO PARA 7 SEGMENTOS
    // Activo en bajo
    // =========================================================
    always_comb begin
        case (count)

            2'b00: begin 
                numero = aciertos[7:4];
                select_7seg = 4'b1110;
            end

            2'b01: begin
                numero = aciertos[3:0];
                select_7seg = 4'b1101;
            end

            2'b10: begin
                numero = fallos[7:4];
                select_7seg = 4'b1011;
            end

            2'b11: begin
                numero = fallos[3:0];
                select_7seg = 4'b0111;
            end

            default: begin
                numero = 4'b0;
                select_7seg = 4'b0000;
            end

        endcase
    end
    
    // =========================================================
    // DECODIFICADOR BCD A 7 SEGMENTOS
    // =========================================================
    always_comb begin
        case (numero)

            4'd0: display_7seg[6:0] = 7'b000_0001;
            4'd1: display_7seg[6:0] = 7'b100_1111;
            4'd2: display_7seg[6:0] = 7'b001_0010;
            4'd3: display_7seg[6:0] = 7'b000_0110;
            4'd4: display_7seg[6:0] = 7'b100_1100;
            4'd5: display_7seg[6:0] = 7'b010_0100;
            4'd6: display_7seg[6:0] = 7'b010_0000;
            4'd7: display_7seg[6:0] = 7'b000_1111;
            4'd8: display_7seg[6:0] = 7'b000_0000;
            4'd9: display_7seg[6:0] = 7'b000_0100;

            default:
                display_7seg[6:0] = 7'b111_1111;

        endcase
    end
    
endmodule