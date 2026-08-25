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
    // MONITOREO
    // ============================================================
    realtime tiempo_evento;
    realtime tiempo_siguiente;
    realtime tiempo_timeout;

    logic siguiente_topo_detectado;
    logic timeout_detectado;
    logic derrota_detectada;

    integer errores;

    // ============================================================
    // DUT
    // ============================================================
    top_whack_a_mole dut (
        .clk           (clk),
        .rst           (rst),
        .rst_LSFR      (rst_LSFR),
        .topo_generado (topo_generado),
        .botones       (botones),
        .led_estado    (led_estado),
        .leds          (leds),
        .display_7seg  (display_7seg),
        .select_7seg   (select_7seg)
    );

    // ============================================================
    // CLOCK 100 MHz
    // ============================================================
    initial begin
        clk = 1'b0;

        forever
            #5 clk = ~clk;
    end

    // ============================================================
    // MONITOR SIGUIENTE_TOPO
    // ============================================================
    always @(posedge dut.controlador.siguiente_topo) begin

        siguiente_topo_detectado = 1'b1;
        tiempo_siguiente = $realtime;

        $display("[%0t] >>> SIGUIENTE_TOPO DETECTADO",
                 $time);

    end

    // ============================================================
    // MONITOR TIMEOUT
    // ============================================================
    always @(posedge dut.temporizador.timeout) begin

        timeout_detectado = 1'b1;
        tiempo_timeout = $realtime;

        $display("[%0t] >>> TIMEOUT DETECTADO",
                 $time);

    end

    // ============================================================
    // MONITOR DERROTA
    // ============================================================
    always @(posedge dut.controlador.derrota) begin

        derrota_detectada = 1'b1;

        $display("[%0t] >>> DERROTA DETECTADA",
                 $time);

    end

    // ============================================================
    // MONITOR ACIERTO
    // ============================================================
    always @(posedge dut.controlador.sumar_acierto) begin

        $display("[%0t] >>> SUMAR ACIERTO | AC=%02h",
                 $time,
                 dut.marcador.aciertos);

    end

    // ============================================================
    // MONITOR FALLO
    // ============================================================
    always @(posedge dut.controlador.sumar_fallo) begin

        $display("[%0t] >>> SUMAR FALLO | FL=%02h",
                 $time,
                 dut.marcador.fallos);

    end

    // ============================================================
    // MONITOR LED
    // ============================================================
    always @(leds) begin

        $display("[%0t] LED = %08b",
                 $time,
                 leds);

    end

    // ============================================================
    // TASK: ENVIAR TOPO UART
    //
    // START = 1
    // D1
    // D2
    // D3
    // 0000
    //
    // 90 Hz -> 11.111111 ms por bit
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

            // 4 bits de relleno
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

            // Dar tiempo al receptor
            #1000;

        end
    endtask

    // ============================================================
    // TASK: PULSAR BOTON
    // ============================================================
    task pulsar_boton;
        input [7:0] boton;

        begin

            $display("[%0t] BOTON = %08b",
                     $time,
                     boton);

            botones = boton;

            // Tiempo suficiente para debounce
            #30_000_000;

            botones = 8'b0;

            // Liberación
            #30_000_000;

        end
    endtask

    // ============================================================
    // TASK: ESPERAR SIGUIENTE_TOPO
    // ============================================================
    task esperar_siguiente_topo;
        input realtime tiempo_maximo;

        begin

            siguiente_topo_detectado = 1'b0;

            fork

                begin
                    wait(siguiente_topo_detectado);
                end

                begin
                    #tiempo_maximo;

                    if (!siguiente_topo_detectado) begin

                        $display("[%0t] ERROR: NO se detecto siguiente_topo",
                                 $time);

                        errores = errores + 1;

                    end

                end

            join_any

            disable fork;

        end
    endtask

    // ============================================================
    // TASK: VERIFICAR LED
    // ============================================================
    task verificar_led;
        input [7:0] esperado;

        begin

            if (leds !== esperado) begin

                $display("[%0t] ERROR: LED esperado = %08b, actual = %08b",
                         $time,
                         esperado,
                         leds);

                errores = errores + 1;

            end
            else begin

                $display("[%0t] OK: LED = %08b",
                         $time,
                         leds);

            end

        end
    endtask

    // ============================================================
    // TEST PRINCIPAL
    // ============================================================
    initial begin

        errores = 0;

        topo_generado = 1'b0;
        botones       = 8'b0;

        rst      = 1'b1;
        rst_LSFR = 1'b1;

        siguiente_topo_detectado = 1'b0;
        timeout_detectado        = 1'b0;
        derrota_detectada        = 1'b0;

        // ========================================================
        // ENCABEZADO
        // ========================================================

        $display("");
        $display("============================================");
        $display("       TEST INTEGRAL WHACK-A-MOLE");
        $display("============================================");
        $display("");
        $display("1. Recepcion UART");
        $display("2. Cambio de LED");
        $display("3. Golpe correcto");
        $display("4. Golpe incorrecto");
        $display("5. Timeout");
        $display("6. Contadores");
        $display("7. Derrota");
        $display("");

        // ========================================================
        // RESET
        // ========================================================

        #1_000_000;

        rst      = 1'b0;
        rst_LSFR = 1'b0;

        $display("[%0t] RESET LIBERADO",
                 $time);

        // ========================================================
        // INICIO DEL JUEGO
        // ========================================================

        @(posedge clk);

        $display("[%0t] >>> INICIANDO PRIMER TOPO",
                 $time);

        force dut.controlador.siguiente_topo = 1'b1;

        @(posedge clk);

        release dut.controlador.siguiente_topo;

        #1000;

        // ========================================================
        // TOPO 0
        // ========================================================

        enviar_topo(3'b000);

        verificar_led(8'b0000_0001);

        // ========================================================
        // PRUEBA 1
        // GOLPE CORRECTO
        // ========================================================

        $display("");
        $display("============================================");
        $display("       PRUEBA 1: GOLPE CORRECTO");
        $display("============================================");

        tiempo_evento = $realtime;

        siguiente_topo_detectado = 1'b0;

        $display("[%0t] LED activo = %08b",
                 $time,
                 leds);

        $display("[%0t] Pulsando boton correcto",
                 $time);

        botones = 8'b0000_0001;

        #30_000_000;

        botones = 8'b0;

        // Esperar siguiente topo
        wait(siguiente_topo_detectado);

        tiempo_siguiente = $realtime;

        $display("[%0t] OK: siguiente_topo generado por golpe correcto",
                 $time);

        $display("[%0t] Tiempo golpe -> siguiente_topo = %0t ns",
                 $time,
                 tiempo_siguiente - tiempo_evento);

        #1000;

        // Verificar aciertos
        if (dut.marcador.aciertos !== 8'h01) begin

            $display("[%0t] ERROR: ACIERTOS = %02h, esperado 01",
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

        verificar_led(8'b0000_0010);

        // ========================================================
        // PRUEBA 2
        // GOLPE INCORRECTO
        // ========================================================

        $display("");
        $display("============================================");
        $display("       PRUEBA 2: GOLPE INCORRECTO");
        $display("============================================");

        tiempo_evento = $realtime;

        siguiente_topo_detectado = 1'b0;

        $display("[%0t] LED activo = %08b",
                 $time,
                 leds);

        // LED 2 activo -> boton 1 es incorrecto
        $display("[%0t] Pulsando boton incorrecto",
                 $time);

        botones = 8'b0000_0001;

        #30_000_000;

        botones = 8'b0;

        wait(siguiente_topo_detectado);

        tiempo_siguiente = $realtime;

        $display("[%0t] OK: siguiente_topo generado por golpe incorrecto",
                 $time);

        $display("[%0t] Tiempo golpe -> siguiente_topo = %0t ns",
                 $time,
                 tiempo_siguiente - tiempo_evento);

        #1000;

        if (dut.marcador.fallos !== 8'h01) begin

            $display("[%0t] ERROR: FALLOS = %02h, esperado 01",
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

        verificar_led(8'b0000_0100);

        // ========================================================
        // PRUEBA 3
        // TIMEOUT
        // ========================================================

        $display("");
        $display("============================================");
        $display("             PRUEBA 3: TIMEOUT");
        $display("============================================");

        $display("[%0t] NO se pulsara ningun boton",
                 $time);

        timeout_detectado = 1'b0;

        siguiente_topo_detectado = 1'b0;

        tiempo_evento = $realtime;

        $display("[%0t] Iniciando medicion de timeout...",
                 $time);

        // Esperar timeout
        wait(timeout_detectado);

        tiempo_timeout = $realtime;

        $display("[%0t] >>> TIMEOUT DETECTADO",
                 $time);

        $display("[%0t] Tiempo real desde inicio = %0t ns",
                 $time,
                 tiempo_timeout - tiempo_evento);

        // --------------------------------------------------------
        // Verificar timeout < 1.5 segundos
        // --------------------------------------------------------

        if ((tiempo_timeout - tiempo_evento) < 1_500_000_000.0) begin

            $display("[%0t] OK: timeout < 1.5 segundos",
                     $time);

        end
        else begin

            $display("[%0t] ERROR: timeout >= 1.5 segundos",
                     $time);

            errores = errores + 1;

        end

        // --------------------------------------------------------
        // Esperar procesamiento del FSM
        // --------------------------------------------------------

        #100;

        // Verificar fallo
        #1000;

        if (dut.marcador.fallos !== 8'h02) begin

            $display("[%0t] ERROR: FALLOS = %02h, esperado 02",
                     $time,
                     dut.marcador.fallos);

            errores = errores + 1;

        end
        else begin

            $display("[%0t] OK: fallo agregado por timeout. FALLOS = 02",
                     $time);

        end

        // ========================================================
        // TOPO 3
        // ========================================================

        #1_000_000;

        enviar_topo(3'b011);

        verificar_led(8'b0000_1000);

        // ========================================================
        // PRUEBA 4
        // SEGUNDO GOLPE INCORRECTO
        // ========================================================

        $display("");
        $display("============================================");
        $display("     PRUEBA 4: SEGUNDO GOLPE INCORRECTO");
        $display("============================================");

        siguiente_topo_detectado = 1'b0;

        botones = 8'b0000_0001;

        #30_000_000;

        botones = 8'b0;

        wait(siguiente_topo_detectado);

        #1000;

        if (dut.marcador.fallos !== 8'h03) begin

            $display("[%0t] ERROR: FALLOS = %02h, esperado 03",
                     $time,
                     dut.marcador.fallos);

            errores = errores + 1;

        end
        else begin

            $display("[%0t] OK: FALLOS = 03",
                     $time);

        end

        // ========================================================
        // PRUEBA 5
        // VERIFICAR DERROTA
        // ========================================================

        $display("");
        $display("============================================");
        $display("          PRUEBA 5: DERROTA");
        $display("============================================");

        // Dar algunos ciclos para que FSM procese
        #100;

        if (dut.controlador.derrota === 1'b1 ||
            derrota_detectada === 1'b1) begin

            $display("[%0t] OK: DERROTA DETECTADA",
                     $time);

        end
        else begin

            $display("[%0t] ERROR: DERROTA NO DETECTADA",
                     $time);

            errores = errores + 1;

        end

        // ========================================================
        // RESULTADO FINAL
        // ========================================================

        #1000;

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