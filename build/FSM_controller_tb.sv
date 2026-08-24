`timescale 1ns/1ps

module fsm_controller_tb;

    // =========================================================
    // SEÑALES
    // =========================================================

    logic clk;
    logic rst;

    logic timeout;
    logic golpe_correcto;
    logic golpe_incorrecto;
    logic tres_fallos;

    logic sumar_fallo;
    logic sumar_acierto;
    logic rst_fallos;
    logic derrota;
    logic disminuir_temporizador;
    logic siguiente_topo;


    // =========================================================
    // INSTANCIA DEL DUT
    // =========================================================

    fsm_controller DUT (
        .clk                    (clk),
        .rst                    (rst),
        .timeout                (timeout),
        .golpe_correcto         (golpe_correcto),
        .golpe_incorrecto       (golpe_incorrecto),
        .tres_fallos            (tres_fallos),
        .sumar_fallo            (sumar_fallo),
        .sumar_acierto          (sumar_acierto),
        .rst_fallos             (rst_fallos),
        .derrota                (derrota),
        .disminuir_temporizador (disminuir_temporizador),
        .siguiente_topo         (siguiente_topo)
    );


    // =========================================================
    // RELOJ 100 MHz
    // =========================================================

    initial begin
        clk = 0;

        forever begin
            #5 clk = ~clk;
        end
    end


    // =========================================================
    // MONITOR
    // =========================================================

    initial begin

        $monitor(
            "T=%0t | rst=%b | timeout=%b | correcto=%b | incorrecto=%b | 3_fallos=%b | fallo=%b | acierto=%b | rst_fallos=%b | derrota=%b | reducir=%b | siguiente=%b",
            $time,
            rst,
            timeout,
            golpe_correcto,
            golpe_incorrecto,
            tres_fallos,
            sumar_fallo,
            sumar_acierto,
            rst_fallos,
            derrota,
            disminuir_temporizador,
            siguiente_topo
        );

    end


    // =========================================================
    // TAREA: ESPERAR UN CICLO
    // =========================================================

    task esperar_ciclo;

        begin
            @(posedge clk);
            #1;
        end

    endtask


    // =========================================================
    // ESTÍMULOS
    // =========================================================

    initial begin

        // =====================================================
        // INICIALIZACIÓN
        // =====================================================

        rst              = 0;
        timeout          = 0;
        golpe_correcto   = 0;
        golpe_incorrecto = 0;
        tres_fallos      = 0;


        // =====================================================
        // PRUEBA 1 - RESET
        // =====================================================

        $display("");
        $display("==============================================");
        $display("PRUEBA 1: RESET");
        $display("==============================================");

        rst = 1;

        esperar_ciclo;

        rst = 0;

        esperar_ciclo;


        // =====================================================
        // PRUEBA 2 - GOLPE CORRECTO
        // =====================================================

        $display("");
        $display("==============================================");
        $display("PRUEBA 2: GOLPE CORRECTO");
        $display("==============================================");

        golpe_correcto = 1;

        esperar_ciclo;

        golpe_correcto = 0;

        esperar_ciclo;


        // =====================================================
        // PRUEBA 3 - GOLPE INCORRECTO
        // =====================================================

        $display("");
        $display("==============================================");
        $display("PRUEBA 3: GOLPE INCORRECTO");
        $display("==============================================");

        golpe_incorrecto = 1;

        esperar_ciclo;

        golpe_incorrecto = 0;

        esperar_ciclo;


        // =====================================================
        // PRUEBA 4 - TIMEOUT
        // =====================================================

        $display("");
        $display("==============================================");
        $display("PRUEBA 4: TIMEOUT");
        $display("==============================================");

        timeout = 1;

        esperar_ciclo;

        timeout = 0;

        esperar_ciclo;


        // =====================================================
        // PRUEBA 5 - TRES FALLOS
        // =====================================================

        $display("");
        $display("==============================================");
        $display("PRUEBA 5: TRES FALLOS");
        $display("==============================================");

        tres_fallos = 1;

        esperar_ciclo;

        tres_fallos = 0;

        esperar_ciclo;


        // =====================================================
        // FIN
        // =====================================================

        $display("");
        $display("==============================================");
        $display("SIMULACION TERMINADA");
        $display("==============================================");

        $finish;

    end

endmodule