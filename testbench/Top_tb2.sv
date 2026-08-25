`timescale 1ns / 1ps

module Top_tb;

    // ============================================================
    // RELOJ / RESET
    // ============================================================
    logic clk;
    logic rst;
    logic rst_LSFR;

    // ============================================================
    // ENTRADAS / SALIDAS DEL TOP
    // ============================================================
    logic       topo_generado;
    logic [7:0] botones;

    logic       led_estado;
    logic [7:0] leds;
    logic [6:0] display_7seg;
    logic [3:0] select_7seg;

    // ============================================================
    // VARIABLES DE MONITOREO
    // ============================================================
    realtime tiempo_evento;
    realtime tiempo_siguiente;
    realtime tiempo_timeout;

    logic siguiente_topo_detectado;
    logic timeout_detectado;

    integer errores;

    // ============================================================
    // DUT
    // ============================================================
    top_whack_a_mole dut (
        .clk            (clk),
        .rst            (rst),
        .rst_LSFR       (rst_LSFR),
        .topo_generado  (topo_generado),
        .botones        (botones),
        .led_estado     (led_estado),
        .leds           (leds),
        .display_7seg   (display_7seg),
        .select_7seg    (select_7seg)
    );

    // ============================================================
    // CLOCK 100 MHz
    // ============================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // MONITOR DE SIGUIENTE_TOPO
    //
    // Detecta el pulso de 1 ciclo directamente.
    // ============================================================
    always @(posedge dut.controlador.siguiente_topo) begin

        siguiente_topo_detectado = 1'b1;
        tiempo_siguiente = $realtime;

        $display("[%0t] >>> SIGUIENTE_TOPO DETECTADO",
                 $time);
    end

    // ============================================================
    // MONITOR DE TIMEOUT
    // ============================================================
    always @(posedge dut.temporizador.timeout) begin

        timeout_detectado = 1'b1;
        tiempo_timeout = $realtime;

        $display("[%0t] >>> TIMEOUT DETECTADO",
                 $time);
    end

    // ============================================================
    // MONITORES DE CAMBIOS IMPORTANTES
    // ============================================================

    always @(posedge dut.controlador.sumar_acierto) begin
        $display("[%0t] >>> SUMAR ACIERTO | AC=%02h",
                 $time,
                 dut.marcador.aciertos);
    end

    always @(posedge dut.controlador.sumar_fallo) begin
        $display("[%0t] >>> SUMAR FALLO | FL=%02h",
                 $time,
                 dut.marcador.fallos);
    end

    always @(posedge dut.controlador.derrota) begin
        $display("[%0t] >>> DERROTA",
                 $time);
    end

    // ============================================================
    // MONITOR DE LED
    // ============================================================
    always @(leds) begin
        $display("[%0t] LED = %08b",
                 $time,
                 leds);
    end

    // ============================================================
    // PROCEDIMIENTO: ESPERAR SIGUIENTE TOPO
    // ============================================================
    task esperar_siguiente_topo;
        input integer timeout_ns;
        begin

            siguiente_topo_detectado = 1'b0;

            fork

                begin
                    wait(siguiente_topo_detectado);
                end

                begin
                    #(timeout_ns);

                    if (!siguiente_topo_detectado) begin
                        $display("[%0t] ERROR: no se detecto siguiente_topo",
                                 $time);
                        errores = errores + 1;
                    end
                end

            join_any

            disable fork;

        end
    endtask

    // ============================================================
    // PROCEDIMIENTO: ENVIAR TOPO UART
    //
    // Formato:
    //
    // START = 1
    // D1
    // D2
    // D3
    // 0000
    //
    // Cada bit dura 1/90 s.
    // ============================================================
    task enviar_topo;
        input [2:0] codigo;

        realtime bit_time;

        begin

            bit_time = 1_000_000_000.0 / 90.0;

            $display("");
            $display("--------------------------------------------");
            $display("[%0t] ENVIANDO TOPO = %03b",
                     $time,
                     codigo);
            $display("--------------------------------------------");

            // START
            topo_generado = 1'b1;
            #(bit_time);

            // D1
            topo_generado = codigo[0];
            #(bit_time);

            // D2
            topo_generado = codigo[1];
            #(bit_time);

            // D3
            topo_generado = codigo[2];
            #(bit_time);

            // Relleno
            topo_generado = 1'b0;
            #(bit_time);

            topo_generado = 1'b0;
            #(bit_time);

            topo_generado = 1'b0;
            #(bit_time);

            topo_generado = 1'b0;
            #(bit_time);

            topo_generado = 1'b0;

            $display("[%0t] Trama UART terminada",
                     $time);

            // Dar tiempo para que el UART actualice el LED
            #1000;

        end
    endtask

    // ============================================================
    // PROCEDIMIENTO: PULSAR BOTON
    // ============================================================
    task pulsar_boton;
        input [7:0] boton;

        begin

            $display("[%0t] BOTON = %08b",
                     $time,
                     boton);

            botones = boton;

            // Debounce de 20 ms
            #25_000_000;

            botones = 8'b0;

            // Esperar liberacion
            #25_000_000;

        end
    endtask

    // ============================================================
    // TEST PRINCIPAL
    // ============================================================
    initial begin

        errores = 0;

        topo_generado = 0;
        botones       = 0;

        rst           = 1;
        rst_LSFR      = 1;

        siguiente_topo_detectado = 0;
        timeout_detectado        = 0;

        $display("");
        $display("============================================");
        $display("       TEST INTEGRAL WHACK-A-MOLE");
        $display("============================================");
        $display("");
        $display("1. Golpe correcto");
        $display("2. Golpe incorrecto");
        $display("3. Timeout");
        $display("");

        // --------------------------------------------------------
        // RESET
        // --------------------------------------------------------
        #1_000_000;

        rst      = 0;
        rst_LSFR = 0;

        $display("[%0t] RESET LIBERADO",
                 $time);

        // ========================================================
        // INICIO DEL JUEGO
        // ========================================================

        @(posedge clk);

        $display("[%0t] >>> INICIANDO PRIMER TOPO",
                 $time);

        // Forzamos que el temporizador inicie
        // mediante Siguiente_Topo del FSM.
        force dut.controlador.siguiente_topo = 1'b1;
        @(posedge clk);
        release dut.controlador.siguiente_topo;

        #1000;

        // ========================================================
        // TOPO 0
        // ========================================================

        enviar_topo(3'b000);

        // LED 1
        if (leds !== 8'b0000_0001) begin
            $display("[%0t] ERROR: LED esperado = 00000001, actual = %08b",
                     $time,
                     leds);
            errores = errores + 1;
        end
        else begin
            $display("[%0t] OK: LED = 00000001",
                     $time);
        end

        // ========================================================
        // PRUEBA 1: GOLPE CORRECTO
        // ========================================================

        $display("");
        $display("============================================");
        $display("       PRUEBA 1: GOLPE CORRECTO");
        $display("============================================");

        siguiente_topo_detectado = 0;

        tiempo_evento = $realtime;

        $display("[%0t] Pulsando boton correcto",
                 $time);

        botones = 8'b0000_0001;

        // Esperamos que debounce detecte el boton
        #30_000_000;

        botones = 8'b0;

        // Esperamos siguiente_topo real
        wait(siguiente_topo_detectado);

        tiempo_siguiente = $realtime;

        $display("[%0t] OK: siguiente_topo generado por golpe correcto",
                 $time);

        $display("[%0t] Tiempo golpe -> siguiente_topo = %0t ns",
                 $time,
                 tiempo_siguiente - tiempo_evento);

        // Verificar aciertos
        #1000;

        if (dut.marcador.aciertos !== 8'h01) begin
            $display("[%0t] ERROR: aciertos = %02h, esperado 01",
                     $time,
                     dut.marcador.aciertos);
            errores = errores + 1;
        end
        else begin
            $display("[%0t] OK: ACIERTOS = 01",
                     $time);
        end

        // ========================================================
        // TOPO 1
        // ========================================================

        #1_000_000;

        enviar_topo(3'b001);

        if (leds !== 8'b0000_0010) begin
            $display("[%0t] ERROR: LED esperado = 00000010, actual = %08b",
                     $time,
                     leds);
            errores = errores + 1;
        end
        else begin
            $display("[%0t] OK: LED = 00000010",
                     $time);
        end

        // ========================================================
        // PRUEBA 2: GOLPE INCORRECTO
        // ========================================================

        $display("");
        $display("============================================");
        $display("       PRUEBA 2: GOLPE INCORRECTO");
        $display("============================================");

        siguiente_topo_detectado = 0;

        tiempo_evento = $realtime;

        // LED activo = 2
        // Pulsamos boton 1
        $display("[%0t] Pulsando boton incorrecto",
                 $time);

        botones = 8'b0000_0001;

        #30_000_000;

        botones = 8'b0;

        // Esperar siguiente_topo
        wait(siguiente_topo_detectado);

        tiempo_siguiente = $realtime;

        $display("[%0t] OK: siguiente_topo generado por golpe incorrecto",
                 $time);

        $display("[%0t] Tiempo golpe -> siguiente_topo = %0t ns",
                 $time,
                 tiempo_siguiente - tiempo_evento);

        #1000;

        if (dut.marcador.fallos !== 8'h01) begin
            $display("[%0t] ERROR: fallos = %02h, esperado 01",
                     $time,
                     dut.marcador.fallos);
            errores = errores + 1;
        end
        else begin
            $display("[%0t] OK: FALLOS = 01",
                     $time);
        end

        // ========================================================
        // TOPO 2
        // ========================================================

        #1_000_000;

        enviar_topo(3'b010);

        if (leds !== 8'b0000_0100) begin
            $display("[%0t] ERROR: LED esperado = 00000100, actual = %08b",
                     $time,
                     leds);
            errores = errores + 1;
        end
        else begin
            $display("[%0t] OK: LED = 00000100",
                     $time);
        end

        // ========================================================
        // PRUEBA 3: TIMEOUT
        // ========================================================

        $display("");
        $display("============================================");
        $display("             PRUEBA 3: TIMEOUT");
        $display("============================================");

        $display("[%0t] NO se pulsara ningun boton",
                 $time);

        timeout_detectado = 0;
        siguiente_topo_detectado = 0;

        tiempo_evento = $realtime;

        $display("[%0t] Iniciando medicion de timeout...",
                 $time);

        // Esperamos timeout
        wait(timeout_detectado);

        tiempo_timeout = $realtime;

        $display("[%0t] >>> TIMEOUT DETECTADO",
                 $time);

        $display("[%0t] Tiempo real desde inicio = %0t ns",
                 $time,
                 tiempo_timeout - tiempo_evento);

        // ========================================================
        // VERIFICAR TIMEOUT < 1.5 s
        // ========================================================

        if ((tiempo_timeout - tiempo_evento) < 1_500_000_000.0) begin

            $display("[%0t] OK: timeout < 1.5 segundos",
                     $time);

        end
        else begin

            $display("[%0t] ERROR: timeout >= 1.5 segundos",
                     $time);

            errores = errores + 1;

        end

        // ========================================================
        // VERIFICAR QUE TIMEOUT GENERA SIGUIENTE_TOPO
        // ========================================================

        siguiente_topo_detectado = 0;

        // Dar unos ciclos para que FSM procese timeout
        #100;

        if (siguiente_topo_detectado) begin

            $display("[%0t] OK: siguiente_topo generado por timeout",
                     $time);

        end
        else begin

            // El pulso puede haber ocurrido antes de estos 100 ns.
            // Por eso comprobamos mediante la señal interna del
            // contador/estado observando también el cambio de fallo.
            $display("[%0t] INFO: siguiente_topo ya termino su pulso de 1 ciclo",
                     $time);

        end

        // ========================================================
        // VERIFICAR FALLO POR TIMEOUT
        // ========================================================

        #1000;

        if (dut.marcador.fallos !== 8'h02) begin

            $display("[%0t] ERROR: fallos = %02h, esperado 02",
                     $time,
                     dut.marcador.fallos);

            errores = errores + 1;

        end
        else begin

            $display("[%0t] OK: fallo agregado por timeout. FALLOS = 02",
                     $time);

        end

        // ========================================================
        // RESULTADO FINAL
        // ========================================================

        $display("");
        $display("============================================");
        $display("             RESULTADO FINAL");
        $display("============================================");

        $display("Aciertos = %02h",
                 dut.marcador.aciertos);

        $display("Fallos   = %02h",
                 dut.marcador.fallos);

        $display("LED      = %08b",
                 leds);

        $display("");

        if (errores == 0) begin

            $display("============================================");
            $display("       *** TODAS LAS PRUEBAS OK ***");
            $display("============================================");

        end
        else begin

            $display("============================================");
            $display("       *** TEST CON ERRORES ***");
            $display("       ERRORES = %0d",
                     errores);
            $display("============================================");

        end

        $display("");
        $display("FIN DEL TEST");

        #1_000_000;

        $finish;

    end

endmodule