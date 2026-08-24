`timescale 1ns/1ps

module Uart_Receptor_tb;

    //--------------------------------------------------
    // SEÑALES
    //--------------------------------------------------

    logic clk;
    logic reset;
    logic Topo_Generado;
    logic Siguiente_Topo;

    logic [7:0] Led_Encendido;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    Uart_Receptor DUT (
        .clk            (clk),
        .reset          (reset),
        .Topo_Generado  (Topo_Generado),
        .Siguiente_Topo (Siguiente_Topo),
        .Led_Encendido  (Led_Encendido)
    );

    //--------------------------------------------------
    // CLOCK 100 MHz
    //--------------------------------------------------

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //--------------------------------------------------
    // TRANSMITIR UN BIT
    //--------------------------------------------------

    task transmitir_bit(input logic dato);
    begin

        @(negedge clk);
        Topo_Generado = dato;

        repeat (100_000_000/90)
            @(negedge clk);

    end
    endtask

    //--------------------------------------------------
    // TRANSMITIR TRAMA
    //--------------------------------------------------

    task transmitir_trama(input logic [7:0] trama);

        integer i;

        begin

            $display("");
            $display("================================");
            $display("TRANSMITIENDO : %b", trama);
            $display("================================");

            for (i = 7; i >= 0; i = i - 1)
                transmitir_bit(trama[i]);

            wait(DUT.recibir == 0);

            repeat(5)
                @(posedge clk);

            $display("REGISTRO RECIBIDO = %b", DUT.registro);

        end

    endtask

    //--------------------------------------------------
    // SIGUIENTE TOPO
    //--------------------------------------------------

    task siguiente_topo;

    begin

        @(posedge clk);

        $display("");
        $display("--------------------------------");
        $display("ANTES DE Siguiente_Topo");
        $display("Registro = %b", DUT.registro);
        $display("LED      = %b", Led_Encendido);

        Siguiente_Topo = 1;

        @(posedge clk);

        Siguiente_Topo = 0;

        @(posedge clk);

        $display("DESPUES DE Siguiente_Topo");
        $display("Registro = %b", DUT.registro);
        $display("LED      = %b", Led_Encendido);
        $display("--------------------------------");

    end

    endtask

    //--------------------------------------------------
    // ESTIMULOS
    //--------------------------------------------------

    initial begin

        reset          = 1;
        Topo_Generado  = 0;
        Siguiente_Topo = 0;

        repeat (10)
            @(posedge clk);

        reset = 0;

        repeat (20)
            @(posedge clk);

        //--------------------------------------------------
        // TOPO 6
        //--------------------------------------------------

        transmitir_trama(8'b1101_0000);
        $display("REGISTRO = %b", DUT.registro);
        siguiente_topo;

        //--------------------------------------------------
        // TOPO 8
        //--------------------------------------------------

        transmitir_trama(8'b1111_0000);
        $display("REGISTRO = %b", DUT.registro);
        siguiente_topo;

        //--------------------------------------------------
        // TOPO 5
        //--------------------------------------------------

        transmitir_trama(8'b1001_0000);
        $display("REGISTRO = %b", DUT.registro);
        siguiente_topo;

        //--------------------------------------------------
        // TOPO 7
        //--------------------------------------------------

        transmitir_trama(8'b1011_0000);
        $display("REGISTRO = %b", DUT.registro);
        siguiente_topo;

        repeat(1000000)
            @(posedge clk);

        $display("");
        $display("================================");
        $display("SIMULACION TERMINADA");
        $display("================================");

        $finish;

    end

    //--------------------------------------------------
    // MONITOR
    //--------------------------------------------------

    initial begin

        $monitor(
            "T=%0t | Reset=%b | Topo=%b | Sig=%b | Recibir=%b | Bits=%0d | Registro=%b | LED=%b",
            $time,
            reset,
            Topo_Generado,
            Siguiente_Topo,
            DUT.recibir,
            DUT.contador_bits,
            DUT.registro,
            Led_Encendido
        );

    end

endmodule