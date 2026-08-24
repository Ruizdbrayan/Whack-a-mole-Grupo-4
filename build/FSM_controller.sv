module fsm_controller (
    input  logic clk,
    input  logic rst,

    input  logic timeout,
    input  logic golpe_correcto,
    input  logic golpe_incorrecto,
    input  logic tres_fallos,

    output logic sumar_fallo,
    output logic sumar_acierto,
    output logic rst_fallos,
    output logic derrota,
    output logic disminuir_temporizador,
    output logic siguiente_topo
);

    // =========================================================    
    // CONTADOR PARA MANTENER LA DERROTA DURANTE 2 SEGUNDOS
    // 100 MHz × 2 s = 200,000,000 ciclos
    // =========================================================
    logic [27:0] contador_derrota;

    always_ff @(posedge clk) begin

        if (rst) begin

            sumar_fallo            <= 0;
            sumar_acierto          <= 0;
            rst_fallos             <= 0;
            derrota                <= 0;
            disminuir_temporizador <= 0;
            siguiente_topo         <= 0;
            contador_derrota      <= 0;

        end

        else begin

            // =================================================
            // VALORES POR DEFECTO
            // =================================================

            sumar_fallo            <= 0;
            sumar_acierto          <= 0;
            rst_fallos             <= 0;
            disminuir_temporizador <= 0;
            siguiente_topo         <= 0;


            // =================================================
            // ESTADO DE DERROTA
            // =================================================

            if (derrota) begin

                // Mantener la derrota durante 2 segundos
                if (contador_derrota < 200_000_000 - 1) begin

                    contador_derrota <= contador_derrota + 1;

                end

                else begin

                    // Terminar derrota
                    contador_derrota <= 0;
                    derrota           <= 0;

                    // Reiniciar fallos consecutivos
                    rst_fallos        <= 1;

                end

            end

            // =================================================
            // JUEGO NORMAL
            // =================================================

            else begin

                // ---------------------------------------------
                // TRES FALLOS → DERROTA
                // ---------------------------------------------

                if (tres_fallos) begin

                    derrota           <= 1;
                    contador_derrota <= 0;

                end

                // ---------------------------------------------
                // TIMEOUT → FALLO Y SIGUIENTE TOPO
                // ---------------------------------------------

                else if (timeout) begin

                    sumar_fallo    <= 1;
                    siguiente_topo <= 1;

                end

                // ---------------------------------------------
                // GOLPE CORRECTO
                // ---------------------------------------------

                else if (golpe_correcto) begin

                    sumar_acierto          <= 1;
                    rst_fallos             <= 1;
                    disminuir_temporizador <= 1;
                    siguiente_topo         <= 1;

                end

                // ---------------------------------------------
                // GOLPE INCORRECTO
                // ---------------------------------------------

                else if (golpe_incorrecto) begin

                    sumar_fallo    <= 1;
                    siguiente_topo <= 1;

                end

            end

        end

    end

endmodule