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
    // CONTADOR DERROTA
    // =========================================================
    logic [27:0] contador_derrota;

    // =========================================================
    // DETECTORES DE FLANCO
    // =========================================================
    logic golpe_correcto_d;
    logic golpe_incorrecto_d;

    logic nuevo_golpe_correcto;
    logic nuevo_golpe_incorrecto;

    assign nuevo_golpe_correcto =
           golpe_correcto && !golpe_correcto_d;

    assign nuevo_golpe_incorrecto =
           golpe_incorrecto && !golpe_incorrecto_d;

    always_ff @(posedge clk) begin

        if (rst) begin

            sumar_fallo            <= 0;
            sumar_acierto          <= 0;
            rst_fallos             <= 0;
            derrota                <= 0;
            disminuir_temporizador <= 0;
            siguiente_topo         <= 0;

            contador_derrota       <= 0;

            golpe_correcto_d       <= 0;
            golpe_incorrecto_d     <= 0;

        end
        else begin

            //--------------------------------------------------
            // REGISTROS DE FLANCO
            //--------------------------------------------------
            golpe_correcto_d   <= golpe_correcto;
            golpe_incorrecto_d <= golpe_incorrecto;

            //--------------------------------------------------
            // PULSOS POR DEFECTO
            //--------------------------------------------------
            sumar_fallo            <= 0;
            sumar_acierto          <= 0;
            rst_fallos             <= 0;
            disminuir_temporizador <= 0;
            siguiente_topo         <= 0;

            //--------------------------------------------------
            // ESTADO DERROTA
            //--------------------------------------------------
            if (derrota) begin

                if (contador_derrota < 200_000_000 - 1) begin

                    contador_derrota <= contador_derrota + 1;

                end
                else begin

                    contador_derrota <= 0;
                    derrota          <= 0;

                    rst_fallos       <= 1;

                end

            end

            //--------------------------------------------------
            // JUEGO NORMAL
            //--------------------------------------------------
            else begin

                //----------------------------------------------
                // TRES FALLOS
                //----------------------------------------------
                if (tres_fallos) begin

                    derrota          <= 1;
                    contador_derrota <= 0;

                end

                //----------------------------------------------
                // TIMEOUT
                //----------------------------------------------
                else if (timeout) begin

                    sumar_fallo    <= 1;
                    siguiente_topo <= 1;

                end

                //----------------------------------------------
                // GOLPE CORRECTO (FLANCO)
                //----------------------------------------------
                else if (nuevo_golpe_correcto) begin

                    sumar_acierto          <= 1;
                    rst_fallos             <= 1;
                    disminuir_temporizador <= 1;
                    siguiente_topo         <= 1;

                end

                //----------------------------------------------
                // GOLPE INCORRECTO (FLANCO)
                //----------------------------------------------
                else if (nuevo_golpe_incorrecto) begin

                    sumar_fallo    <= 1;
                    siguiente_topo <= 1;

                end

            end

        end

    end

endmodule