module hit_verifier(
    input  logic [7:0] boton_presionado,
    input  logic [7:0] led_encendido,
    output logic       golpe_correcto,
    output logic       golpe_incorrecto
);

    logic comparacion;

    always_comb begin
        comparacion = (boton_presionado == led_encendido);
        case (boton_presionado)
            8'b0000_0001,
            8'b0000_0010,
            8'b0000_0100,
            8'b0000_1000,
            8'b0001_0000,
            8'b0010_0000,
            8'b0100_0000,
            8'b1000_0000: begin
                if (comparacion) begin
                    golpe_correcto = 1'b1;
                    golpe_incorrecto = 1'b0;
                end else begin
                    golpe_correcto = 1'b0;
                    golpe_incorrecto = 1'b1;
                end
            end

            default: begin
                golpe_correcto = 1'b0;
                golpe_incorrecto = 1'b0;
            end
        endcase

    end

endmodule