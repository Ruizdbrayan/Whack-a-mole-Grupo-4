`timescale 1ns / 1ps

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

    logic [27:0] contador_derrota;

    localparam integer TIEMPO_DERROTA = 200_000_000;

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            sumar_fallo            <= 1'b0;
            sumar_acierto          <= 1'b0;
            rst_fallos             <= 1'b0;
            derrota                <= 1'b0;
            disminuir_temporizador <= 1'b0;
            siguiente_topo         <= 1'b0;

            contador_derrota       <= 28'd0;

        end

        else begin

            // =====================================================
            // PULSOS POR DEFECTO
            // =====================================================

            sumar_fallo            <= 1'b0;
            sumar_acierto          <= 1'b0;
            rst_fallos             <= 1'b0;
            disminuir_temporizador <= 1'b0;
            siguiente_topo         <= 1'b0;

            // =====================================================
            // DERROTA
            // =====================================================

            if (derrota) begin

                if (contador_derrota < TIEMPO_DERROTA - 1) begin
                    contador_derrota <= contador_derrota + 1'b1;
                end
                else begin
                    contador_derrota <= 0;
                    derrota          <= 1'b0;
                    rst_fallos       <= 1'b1;
                end

            end

            // =====================================================
            // JUEGO NORMAL
            // =====================================================

            else begin

                // -------------------------------------------------
                // TRES FALLOS
                // -------------------------------------------------

                if (tres_fallos) begin

                    derrota          <= 1'b1;
                    contador_derrota <= 0;

                end

                // -------------------------------------------------
                // TIMEOUT
                // -------------------------------------------------

                else if (timeout) begin

                    sumar_fallo    <= 1'b1;
                    siguiente_topo <= 1'b1;

                end

                // -------------------------------------------------
                // GOLPE CORRECTO
                // -------------------------------------------------

                else if (golpe_correcto) begin

                    sumar_acierto          <= 1'b1;
                    rst_fallos             <= 1'b1;
                    disminuir_temporizador <= 1'b1;
                    siguiente_topo         <= 1'b1;

                end

                // -------------------------------------------------
                // GOLPE INCORRECTO
                // -------------------------------------------------

                else if (golpe_incorrecto) begin

                    sumar_fallo    <= 1'b1;
                    siguiente_topo <= 1'b1;

                end

            end

        end

    end

endmodule