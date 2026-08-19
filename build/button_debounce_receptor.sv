module button_debouncer_receptor #(
    parameter SYSTEM_CLK_FREQ = 100_000_000, // Frecuencia del reloj del sistema en Hz
    parameter DEBOUNCE_TIME   = 20           // Tiempo para Antirebote en milisegundos
)(
    input  logic       clk,                  // Reloj del sistema
    input  logic       rst,                  // Señal de reset
    input  logic [7:0] botones,              // Señales de entrada de los botones
    output logic [7:0] boton_presionado      // Señal de salida del boton presionado sincronizada
);

    // Valor del contador de antirebote en ciclos de reloj
    localparam DEBOUNCE_COUNT = (SYSTEM_CLK_FREQ / 1_000) * DEBOUNCE_TIME;

    // Tamaño de bits para el contador
    localparam DEBOUNCE_WIDTH = $clog2(DEBOUNCE_COUNT);

    // Contador de antirebote
    logic [DEBOUNCE_WIDTH-1:0] debounce_counter;

    // Registros para sincronizar la señal de entrada
    logic [7:0] button_sync_0, button_sync_1;


    // Sincronizador de 2 etapas
    always_ff @(posedge clk or posedge rst) begin
        if (!rst) begin
            button_sync_0 <= 8'b0;
            button_sync_1 <= 8'b0;
        end else begin
            button_sync_0 <= botones;
            button_sync_1 <= button_sync_0;
        end
    end


    // Logica Antirebotes
    always_ff @(posedge clk or posedge rst) begin
        if (!rst) begin
            debounce_counter <= 0;
            boton_presionado <= 8'b0;
        end else begin
            if (button_sync_1 != boton_presionado) begin
                // Si la señal de entrada cambia, incrementamos el contador
                debounce_counter <= debounce_counter + 1;
                if (debounce_counter >= DEBOUNCE_COUNT) begin
                    // Cuando el contador alcanza el tiempo de antirebote, actualiza la salida
                    boton_presionado <= button_sync_1;
                    debounce_counter <= 0;
                end
            end else begin
                // Si la señal de entrada es estable, el contador se reinicia
                debounce_counter <= 0;
            end
        end
    end

endmodule