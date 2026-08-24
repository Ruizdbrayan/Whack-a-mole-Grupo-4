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

    always_ff @(posedge clk) begin

        if (rst) begin

            sumar_fallo            <= 0;
            sumar_acierto          <= 0;
            rst_fallos             <= 0;
            derrota                <= 0;
            disminuir_temporizador <= 0;
            siguiente_topo        <= 0;

        end

        else begin

            // =================================================
            // VALORES POR DEFECTO
            // =================================================

            sumar_fallo            <= 0;
            sumar_acierto          <= 0;
            rst_fallos             <= 0;
            derrota                <= 0;
            disminuir_temporizador <= 0;
            siguiente_topo        <= 0;


            // =================================================
            // TRES FALLOS -> DERROTA
            // =================================================

            if (tres_fallos) begin

                derrota    <= 1;
                rst_fallos <= 1;

            end


            // =================================================
            // TIMEOUT -> FALLO Y SIGUIENTE TOPO
            // =================================================

            if (timeout) begin

                sumar_fallo     <= 1;
                siguiente_topo <= 1;

            end


            // =================================================
            // GOLPE CORRECTO
            // =================================================

            if (golpe_correcto) begin

                sumar_acierto          <= 1;
                rst_fallos             <= 1;
                disminuir_temporizador <= 1;
                siguiente_topo         <= 1;

            end


            // =================================================
            // GOLPE INCORRECTO
            // =================================================

            if (golpe_incorrecto) begin

                sumar_fallo     <= 1;
                siguiente_topo <= 1;

            end

        end

    end

endmodule