`timescale 1ns / 1ps

module top_whack_a_mole (
    input  logic        clk,
    input  logic        rst,
    input  logic        rst_LSFR,
    input  logic [7:0]  botones,

    output logic        led_estado,
    output logic [7:0]  leds,
    output logic [6:0]  display_7seg,
    output logic [3:0]  select_7seg
);

    // =========================================================
    // SEÑALES INTERNAS
    // =========================================================

    logic [7:0] led_encendido;
    logic [7:0] boton_presionado;

    logic [7:0] aciertos;
    logic [7:0] fallos;

    logic topo_generado;

    logic disminuir_temporizador;
    logic tres_fallos;

    logic timeout;
    logic siguiente_topo;

    logic golpe_correcto;
    logic golpe_incorrecto;

    logic sumar_fallo;
    logic sumar_acierto;
    logic rst_fallos;

    logic derrota;

    // =========================================================
    // TEMPORIZADOR
    // =========================================================

    timer_module temporizador (
        .clk(clk),
        .rst(rst),
        .disminuir(disminuir_temporizador),
        .timeout(timeout),
        .derrota(derrota),
        .siguiente_topo(siguiente_topo)
    );

    // =========================================================
    // FSM
    // =========================================================

    fsm_controller controlador (
        .clk(clk),
        .rst(rst),
        .timeout(timeout),
        .golpe_correcto(golpe_correcto),
        .golpe_incorrecto(golpe_incorrecto),
        .siguiente_topo(siguiente_topo),
        .sumar_fallo(sumar_fallo),
        .sumar_acierto(sumar_acierto),
        .rst_fallos(rst_fallos),
        .tres_fallos(tres_fallos),
        .derrota(derrota),
        .disminuir_temporizador(disminuir_temporizador)
    );

    // =========================================================
    // UART RECEPTOR
    // =========================================================

    uart_receptor receptor_uart (
        .clk(clk),
        .rst(rst),
        .Siguiente_Topo(siguiente_topo),
        .Led_Encendido(led_encendido),
        .Topo_Generado(topo_generado)
    );

    // =========================================================
    // DEBOUNCER DE BOTONES
    // =========================================================

    button_debouncer_receptor receptor_botones (
        .clk(clk),
        .rst(rst),
        .botones(botones),
        .boton_presionado(boton_presionado)
    );

    // =========================================================
    // VERIFICADOR DE GOLPE
    // =========================================================

    hit_verifier verificador (
        .clk(clk),
        .rst(rst),
        .boton_presionado(boton_presionado),
        .led_encendido(led_encendido),
        .golpe_correcto(golpe_correcto),
        .golpe_incorrecto(golpe_incorrecto),
        .derrota(derrota)
    );

    // =========================================================
    // SCORE TRACKER
    // =========================================================

    score_tracker marcador (
        .clk(clk),
        .rst(rst),
        .sumar_fallo(sumar_fallo),
        .sumar_acierto(sumar_acierto),
        .rst_fallos(rst_fallos),
        .tres_fallos(tres_fallos),
        .aciertos(aciertos),
        .fallos(fallos),
        .derrota(derrota)
    );

    // =========================================================
    // DISPLAY
    // =========================================================

    display_7seg_mux display (
        .clk(clk),
        .aciertos(aciertos),
        .fallos(fallos),
        .rst(rst),
        .display_7seg(display_7seg),
        .select_7seg(select_7seg)
    );

    // =========================================================
    // LED DE DERROTA
    // =========================================================

    status_led_driver leds_estado (
        .clk(clk),
        .rst(rst),
        .derrota(derrota),
        .led_estado(led_estado)
    );

    // =========================================================
    // LEDs DE DEPURACIÓN
    // =========================================================

    // Botones detectados
    assign leds=led_encendido;

    // =========================================================
    // GENERADOR DE TOPO DE PRUEBA
    // =========================================================

    logic [2:0] codigo_test;
    logic [7:0] codigo_reg;

    logic [20:0] contador_90hz;
    logic [2:0] bit_index;

    logic topo_test;

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            codigo_test    <= 3'b001;

            // 1 + 000 + 0000 = LED 1
            codigo_reg    <= 8'b10000000;

            contador_90hz <= 21'd0;
            bit_index     <= 3'd0;

            topo_test     <= 1'b0;

        end

        else begin

            if (contador_90hz == 21'd1_111_110) begin

                contador_90hz <= 21'd0;

                // Transmitir un bit cada 1/90 s
                topo_test <= codigo_reg[7-bit_index];

                if (bit_index == 3'd7) begin

                    bit_index <= 3'd0;

                    // -------------------------------------------------
                    // Siguiente código
                    // -------------------------------------------------

                    case (codigo_test)

                        3'b001: codigo_test <= 3'b010;
                        3'b010: codigo_test <= 3'b011;
                        3'b011: codigo_test <= 3'b100;
                        3'b100: codigo_test <= 3'b101;
                        3'b101: codigo_test <= 3'b110;
                        3'b110: codigo_test <= 3'b111;

                        default:
                            codigo_test <= 3'b001;

                    endcase

                    // -------------------------------------------------
                    // Preparar siguiente código
                    // -------------------------------------------------

                    case (codigo_test)

                        3'b001:
                            codigo_reg <= 8'b10100000;

                        3'b010:
                            codigo_reg <= 8'b10110000;

                        3'b011:
                            codigo_reg <= 8'b11000000;

                        3'b100:
                            codigo_reg <= 8'b11010000;

                        3'b101:
                            codigo_reg <= 8'b11100000;

                        3'b110:
                            codigo_reg <= 8'b11110000;

                        default:
                            codigo_reg <= 8'b10000000;

                    endcase

                end

                else begin

                    bit_index <= bit_index + 1'b1;

                end

            end

            else begin

                contador_90hz <= contador_90hz + 1'b1;

            end

        end

    end

    // =========================================================
    // TOPO GENERADO
    // =========================================================

    assign topo_generado = topo_test;

endmodule