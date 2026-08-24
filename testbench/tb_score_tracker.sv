`timescale 1ns / 1ps

module tb_score_tracker;

    reg        clk;
    reg        rst;
    reg        sumar_acierto;
    reg        sumar_fallo;
    wire [7:0] aciertos;
    wire [7:0] fallos;
    wire [1:0] fallos_consecutivos;
    wire       tres_fallos;

    // Instancia de la Unidad Bajo Prueba (UUT)
    score_tracker uut (
        .clk(clk),
        .rst(rst),
        .sumar_acierto(sumar_acierto),
        .sumar_fallo(sumar_fallo),
        .aciertos(aciertos),
        .fallos(fallos),
        .fallos_consecutivos(fallos_consecutivos),
        .tres_fallos(tres_fallos)
    );

    // Reloj de 100 MHz (Periodo = 10 ns)
    always #5 clk = ~clk;

    integer i;

    initial begin
        // Inicialización
        clk = 0;
        rst = 1;
        sumar_acierto = 0;
        sumar_fallo = 0;

        #20;
        rst = 0; // Liberación de reset
        #10;

        // --------------------------------------------------------------------
        // TEST 1: Conteo de Aciertos y Acarreo BCD (09 -> 10 BCD)
        // --------------------------------------------------------------------
        $display("=== INICIANDO TEST 1: Aciertos BCD ===");
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            sumar_acierto <= 1;
            @(posedge clk);
            sumar_acierto <= 0;
        end
        #1;
        if (aciertos === 8'h10)
            $display("[PASS] Aciertos BCD correcto tras 10 incrementos: %h", aciertos);
        else
            $display("[FAIL] Error en Aciertos BCD. Esperado: 10, Obtenido: %h", aciertos);

        // --------------------------------------------------------------------
        // TEST 2: Fallos Consecutivos y Activación de tres_fallos
        // --------------------------------------------------------------------
        $display("=== INICIANDO TEST 2: Fallos Consecutivos ===");
        repeat(3) begin
            @(posedge clk);
            sumar_fallo <= 1;
            @(posedge clk);
            sumar_fallo <= 0;
        end
        #1;
        if (fallos_consecutivos === 2'b11 && tres_fallos === 1'b1)
            $display("[PASS] Racha de 3 fallos y flag tres_fallos activada con éxito.");
        else
            $display("[FAIL] Racha o flag tres_fallos incorrecto.");

        // Verificar saturación en 3 fallos consecutivos
        @(posedge clk);
        sumar_fallo <= 1;
        @(posedge clk);
        sumar_fallo <= 0;
        #1;
        if (fallos_consecutivos === 2'b11)
            $display("[PASS] Fallos consecutivos saturados correctamente en 3.");

        // --------------------------------------------------------------------
        // TEST 3: Limpieza de racha con un Acierto
        // --------------------------------------------------------------------
        $display("=== INICIANDO TEST 3: Reinicio de Racha por Acierto ===");
        @(posedge clk);
        sumar_acierto <= 1;
        @(posedge clk);
        sumar_acierto <= 0;
        #1;
        if (fallos_consecutivos === 2'b00 && tres_fallos === 1'b0)
            $display("[PASS] Acierto limpio racha de fallos a 0.");
        else
            $display("[FAIL] Error limpiando racha tras acierto.");

        // --------------------------------------------------------------------
        // TEST 4: Reset Síncrono General
        // --------------------------------------------------------------------
        $display("=== INICIANDO TEST 4: Reset Síncrono General ===");
        @(posedge clk);
        rst <= 1;
        @(posedge clk);
        rst <= 0;
        #1;
        if (aciertos === 8'h00 && fallos === 8'h00 && fallos_consecutivos === 2'b00)
            $display("[PASS] Reset exitoso, todos los contadores en 0.");
        else
            $display("[FAIL] Error en la ejecución del reset.");

        #50;
        $display("=== PRUEBAS FINALIZADAS CON ÉXITO ===");
        $finish;
    end

endmodule