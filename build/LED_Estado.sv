module status_led_driver (
    input  logic clk,
    input  logic estado_partida,
    output logic led_estado
);

    logic [27:0] contador;
    logic estado_anterior;

    always_ff @(posedge clk) begin

        estado_anterior <= estado_partida;

        // Detectar inicio de derrota
        if (estado_partida && !estado_anterior) begin
            contador  <= 0;
            led_estado <= 1;
        end

        // Mantener LED encendido durante 2 segundos
        else if (led_estado) begin

            if (contador < 200_000_000 - 1) begin
                contador <= contador + 1;
            end

            else begin
                contador   <= 0;
                led_estado <= 0;
            end

        end

    end

endmodule