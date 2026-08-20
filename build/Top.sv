module top_whack_a_mole (
    input  logic        clk,
    input  logic        rst,
    input  logic        rst_LSFR,
    input  logic        Topo_Generado,
    input  logic [7:0]  botones,
    output logic        led_estado,
    output logic [7:0]  leds,
    output logic [6:0]  display_7seg,

);

    // Señales internas
    
    logic [7:0] led_encendido;
    logic [7:0] boton_presionado;
    logic [7:0] aciertos;
    logic [7:0] fallos;
    logic [3:0] disminuir_temporizador;
    logic timeout, siguiente_topo;
    logic golpe_correcto, golpe_incorrecto;
    logic sumar_fallo, sumar_acierto, rst_fallos;
    logic derrota;
 
    // ===============================
    // 🔹 Temporizador principal
    // ===============================
    timer_module temporizador (
        .clk(clk),
        .rst(rst),
        .disminuir(disminuir_temporizador),
        .timeout(timeout),
        .siguiente_topo(siguiente_topo)
    );

    // ===============================
    // 🔹 Controlador FSM
    // ===============================
    fsm_controller controlador (
        .clk(clk),
        .rst(rst),
        .timeout(timeout),
        .golpe_correcto(golpe_correcto),
        .golpe_incorrecto(golpe_incorrecto),
        .sumar_fallo(sumar_fallo),
        .sumar_acierto(sumar_acierto),
        .rst_fallos(rst_fallos),
        .derrota(derrota),
        .disminuir_temporizador(disminuir_temporizador)
    );

    // ===============================
    // 🔹 Receptor UART
    // ===============================
    uart_receptor receptor_uart (
        .clk(clk),
        .rst(rst),
        .led_encendido(led_encendido),
        .topo_generado(topo_generado)
    );

    // ===============================
    // 🔹 Receptor de botones (debounce)
    // ===============================
    button_debounce_receptor receptor_botones (
        .clk(clk),
        .rst(rst),
        .botones(botones),
        .boton_presionado(boton_presionado)
    );

    // ===============================
    // 🔹 Verificador de golpe
    // ===============================
    hit_verifier verificador (
        .boton_presionado(boton_presionado),
        .led_encendido(led_encendido),
        .golpe_correcto(golpe_correcto),
        .golpe_incorrecto(golpe_incorrecto)
    );

    // ===============================
    // 🔹 Sistema de puntuación
    // ===============================
    score_tracker marcador (
        .clk(clk),
        .rst(rst),
        .sumar_fallo(sumar_fallo),
        .sumar_acierto(sumar_acierto),
        .rst_fallos(rst_fallos),
        .aciertos(aciertos),
        .fallos(fallos),
        .derrota(derrota)
    );

    // ===============================
    // 🔹 Display 7 segmentos
    // ===============================
    display_7seg_mux display (
        .clk(clk),
        .aciertos(aciertos),
        .fallos(fallos),
        .display_out(display_7seg)
    );

    // ===============================
    // 🔹 LEDs de estado
    // ===============================
    status_led_driver leds_estado (
        .clk(clk),
        .estado_partida(derrota),
        .led_estado(led_estado)
    );

    // ===============================
    // 🔹 Salidas principales
    // ===============================
    assign leds = led_encendido;

endmodule