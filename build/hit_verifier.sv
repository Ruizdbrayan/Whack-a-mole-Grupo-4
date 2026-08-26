module hit_verifier(
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] boton_presionado,
    input  logic [7:0] led_encendido,
    input  logic       derrota,
    output logic       golpe_correcto,
    output logic       golpe_incorrecto
);

    // 0 = esperando una nueva pulsación
    // 1 = ya se evaluó una pulsación, esperando que se suelte
    logic boton_bloqueado;

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            boton_bloqueado <= 1'b0;
            golpe_correcto  <= 1'b0;
            golpe_incorrecto <= 1'b0;
        end

        else begin

            // Los golpes son pulsos de un solo ciclo
            golpe_correcto  <= 1'b0;
            golpe_incorrecto <= 1'b0;

            // =====================================================
            // ESPERAR A QUE SE SUELTEN TODOS LOS BOTONES
            // =====================================================
            if (boton_bloqueado) begin

                if (boton_presionado == 8'b0000_0000) begin
                    boton_bloqueado <= 1'b0;
                end

            end

            // =====================================================
            // NUEVA PULSACIÓN
            // =====================================================
            else if (boton_presionado != 8'b0000_0000) begin

                // Bloquear hasta que el botón sea soltado
                boton_bloqueado <= 1'b1;

                // No evaluar golpes durante derrota
                if (!derrota) begin

                    // =================================================
                    // BOTÓN CORRECTO
                    // =================================================
                    if (boton_presionado == led_encendido) begin
                        golpe_correcto  <= 1'b1;
                        golpe_incorrecto <= 1'b0;
                    end

                    // =================================================
                    // BOTÓN INCORRECTO
                    // =================================================
                    else begin
                        golpe_correcto  <= 1'b0;
                        golpe_incorrecto <= 1'b1;
                    end

                end
            end

        end
    end

endmodule