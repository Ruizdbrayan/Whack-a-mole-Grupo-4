`timescale 1ns / 1ps

module button_debouncer_receptor_tb;

    // Señales
    logic       clk;
    logic       rst;
    logic [7:0] botones;
    logic [7:0] boton_presionado;

    // Instancia del modulo
    button_debouncer_receptor #() debouncer_dut (
        .clk(clk),
        .rst(rst),
        .botones(botones),
        .boton_presionado(boton_presionado)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    // Monitor de señales
    initial begin
        $monitor("[%0t ns] Entradas 'botones': %b | Salida 'boton_presionado': %b", 
                 $time, botones, boton_presionado);
    end

    initial begin
        clk     = 0;
        rst     = 1;
        botones = 8'b0000_0000;

        #10;
        rst = 0;
        #10;

        // Simulacion de pulsaciones de los botones
        // Boton 1
        botones = 8'b0000_0001;
        #200;
        botones = 8'b0000_0000;
        #200;

        // Boton 2
        botones = 8'b0000_0010;
        #200;
        botones = 8'b0000_0000;
        #200;

        // Boton 3
        botones = 8'b0000_0100;
        #200;
        botones = 8'b0000_0000;
        #200;

        // Boton 4
        botones = 8'b0000_1000;
        #200;
        botones = 8'b0000_0000;
        #200;

        // Boton 5
        botones = 8'b0001_0000;
        #200;
        botones = 8'b0000_0000;
        #200;

        // Boton 6
        botones = 8'b0010_0000;
        #200;
        botones = 8'b0000_0000;
        #200;

        // Boton 7
        botones = 8'b0100_0000;
        #200;
        botones = 8'b0000_0000;
        #200;

        // Boton 8
        botones = 8'b1000_0000;
        #200;
        botones = 8'b0000_0000;
        #200;

        $finish;
    end

endmodule