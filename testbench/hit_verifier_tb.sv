module hit_verifier;
    logic [7:0] boton_presionado;
    logic [7:0] led_encendido;
    logic       golpe_correcto;
    logic       golpe_incorrecto;

    // Instancia del Módulo
    hit_verifier hit_verifier_dut (
        .boton_presionado (boton_presionado),
        .led_encendido    (led_encendido),
        .golpe_correcto   (golpe_correcto),
        .golpe_incorrecto (golpe_incorrecto)
    );

    initial begin
        // Monitor de los cambios en las señales
        $monitor("Tiempo=%0t ns | Boton=%b | LED=%b | Golpe Correcto=%b | Golpe Incorrecto=%b", 
                 $time, boton_presionado, led_encendido, golpe_correcto, golpe_incorrecto);

        // Caso1: Golpe Correcto
        boton_presionado = 8'b0000_0100;
        led_encendido    = 8'b0000_0100;
        #200;

        // Caso 2: Golpe Fallido
        boton_presionado = 8'b0000_0100;
        led_encendido    = 8'b0000_1000;
        #200;

        // Caso 3: Múltiples botones presionados
        boton_presionado = 8'b0000_0011;
        led_encendido    = 8'b0000_0001;
        #200;

        $finish;
    end

endmodule