module top_whack_a_mole (
    input  logic        clk,
    input  logic        rst,
    input  logic        rst_LSFR,
    input  logic        topo_generado,
    input  logic [7:0]  botones,
    output logic        led_estado,
    output logic [7:0]  leds,
    output logic [6:0]  display_7seg,
    output logic [3:0]  select_7seg

);

    // Señales internas
    
    logic [7:0] led_encendido;
    logic [7:0] boton_presionado;
    logic [7:0] aciertos;
    logic [7:0] fallos;
    logic disminuir_temporizador;
    logic tres_fallos;
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
        .siguiente_topo(siguiente_topo),
        .sumar_fallo(sumar_fallo),
        .sumar_acierto(sumar_acierto),
        .rst_fallos(rst_fallos),
        .tres_fallos(tres_fallos),
        .derrota(derrota),
        .disminuir_temporizador(disminuir_temporizador)
    );

    // ===============================
    // 🔹 Receptor UART
    // ===============================
    uart_receptor receptor_uart (
        .clk(clk),
        .rst(rst),
        .Siguiente_Topo(siguiente_topo),
        .Led_Encendido(led_encendido),
        .Topo_Generado(topo_generado)
    );

    // ===============================
    // 🔹 Receptor de botones (debounce)
    // ===============================
    button_debouncer_receptor receptor_botones (
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
        .golpe_incorrecto(golpe_incorrecto),
        .derrota(derrota)
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
        .tres_fallos(tres_fallos),
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
        .rst(rst),
        .display_7seg(display_7seg),
        .select_7seg(select_7seg)
    );

    // ===============================
    // 🔹 LEDs de estado
    // ===============================
    status_led_driver leds_estado (
        .clk(clk),
        .rst(rst),
        .derrota   (derrota),
        .led_estado(led_estado)
    );

    // ===============================
    // 🔹 Salidas principales
    // ===============================
    assign leds = led_encendido;

endmodule