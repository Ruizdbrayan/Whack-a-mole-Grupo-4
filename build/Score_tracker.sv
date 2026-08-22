`timescale 1ns / 1ps

module score_tracker (
    input  wire       clk,
    input  wire       rst,
    input  wire       sumar_acierto,
    input  wire       sumar_fallo,
    output reg  [7:0] aciertos,
    output reg  [7:0] fallos,
    output reg  [1:0] fallos_consecutivos,
    output wire       tres_fallos
);

    // ------------------------------------------------------------------------
    // FUNCIÓN INTERNA: Incrementar BCD con saturación en 99 (8'h99)
    // ------------------------------------------------------------------------
    function [7:0] bcd_inc_sat99;
        input [7:0] bcd_in;
        reg   [3:0] unidades;
        reg   [3:0] decenas;
        begin
            unidades = bcd_in[3:0];
            decenas  = bcd_in[7:4];

            if (bcd_in == 8'h99) begin
                bcd_inc_sat99 = 8'h99; // Tope maximo alcanzado
            end else if (unidades == 4'd9) begin
                bcd_inc_sat99 = {decenas + 1'b1, 4'd0}; // Acarreo a decenas
            end else begin
                bcd_inc_sat99 = {decenas, unidades + 1'b1}; // Incremento de unidades
            end
        end
    endfunction

    // ------------------------------------------------------------------------
    // REGISTRO SÍNCRONO: Contador de Aciertos Totales (BCD)
    // ------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            aciertos <= 8'h00;
        end else if (sumar_acierto) begin
            aciertos <= bcd_inc_sat99(aciertos);
        end
    end

    // ------------------------------------------------------------------------
    // REGISTRO SÍNCRONO: Contador de Fallos Totales (BCD)
    // ------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            fallos <= 8'h00;
        end else if (sumar_fallo) begin
            fallos <= bcd_inc_sat99(fallos);
        end
    end

    // ------------------------------------------------------------------------
    // REGISTRO SÍNCRONO: Fallos Consecutivos (Binario 0 a 3 saturado)
    // ------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            fallos_consecutivos <= 2'b00;
        end else if (sumar_acierto) begin
            fallos_consecutivos <= 2'b00; // Un acierto reinicia la racha
        end else if (sumar_fallo) begin
            if (fallos_consecutivos < 2'b11) begin
                fallos_consecutivos <= fallos_consecutivos + 1'b1;
            end
            // Si ya es 2'b11 (3), se congela en 3
        end
    end

    // ------------------------------------------------------------------------
    // SALIDA COMBINACIONAL: Flag de tres fallos
    // ------------------------------------------------------------------------
    assign tres_fallos = (fallos_consecutivos == 2'b11);

endmodule   