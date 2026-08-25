module uart_receptor (
    input  logic       clk,
    input  logic       rst,
    input  logic       Topo_Generado,
    input  logic       Siguiente_Topo,
    output logic [7:0] Led_Encendido
);

    // =========================================================
    // 100 MHz / 90 Hz
    // =========================================================
    localparam integer BAUD_DIV = 100_000_000 / 90;

    // =========================================================
    // SEÑALES
    // =========================================================
    logic [20:0] contador_clk;
    logic [3:0]  contador_bits;

    logic [2:0]  registro;

    logic recibir;
    logic esperando_topo;

    logic topo_d;

    // =========================================================
    // FLANCO DE SUBIDA
    // SOLO SE UTILIZA PARA DETECTAR EL START
    // =========================================================
    wire start_detectado;

    assign start_detectado = Topo_Generado && !topo_d;

    // =========================================================
    // DETECTOR DE FLANCO
    // =========================================================
    always_ff @(posedge clk) begin

        if (rst)
            topo_d <= 1'b0;
        else
            topo_d <= Topo_Generado;

    end

    // =========================================================
    // RECEPTOR
    // =========================================================
    always_ff @(posedge clk) begin

        if (rst) begin

            contador_clk   <= 0;
            contador_bits  <= 0;
            registro       <= 0;

            recibir        <= 0;
            esperando_topo <= 0;

            Led_Encendido  <= 8'b0000_0001;

        end

        else begin

            // =================================================
            // SOLICITUD DE NUEVO TOPO
            // =================================================
            if (Siguiente_Topo && !recibir) begin

                esperando_topo <= 1'b1;
                contador_bits  <= 0;
                contador_clk   <= 0;
                registro       <= 0;

            end

            // =================================================
            // ESPERAR START
            // =================================================
            else if (esperando_topo && !recibir) begin

                if (start_detectado) begin

                    esperando_topo <= 1'b0;
                    recibir        <= 1'b1;

                    contador_bits <= 0;

                    // Esperar medio bit antes de verificar START
                    contador_clk <= BAUD_DIV / 2;

                end

            end

            // =================================================
            // RECEPCIÓN
            // =================================================
            else if (recibir) begin

                if (contador_clk == 0) begin

                    // Próximo muestreo
                    contador_clk <= BAUD_DIV - 1;

                    case (contador_bits)

                        // -------------------------------------
                        // START
                        // -------------------------------------
                        0: begin

                            contador_bits <= 1;

                        end

                        // -------------------------------------
                        // D1
                        // -------------------------------------
                        1: begin

                            registro[0] <= Topo_Generado;
                            contador_bits <= 2;

                        end

                        // -------------------------------------
                        // D2
                        // -------------------------------------
                        2: begin

                            registro[1] <= Topo_Generado;
                            contador_bits <= 3;

                        end

                        // -------------------------------------
                        // D3
                        // -------------------------------------
                        3: begin

                            registro[2] <= Topo_Generado;
                            contador_bits <= 4;

                        end

                        // -------------------------------------
                        // RELLENO
                        // -------------------------------------
                        4: contador_bits <= 5;
                        5: contador_bits <= 6;
                        6: contador_bits <= 7;

                        // -------------------------------------
                        // FIN
                        // -------------------------------------
                        7: begin

                            recibir        <= 0;
                            esperando_topo <= 0;
                            contador_bits  <= 0;
                            contador_clk   <= 0;

                            case (registro)

                                3'b000:
                                    Led_Encendido <= 8'b0000_0001;

                                3'b001:
                                    Led_Encendido <= 8'b0000_0010;

                                3'b010:
                                    Led_Encendido <= 8'b0000_0100;

                                3'b011:
                                    Led_Encendido <= 8'b0000_1000;

                                3'b100:
                                    Led_Encendido <= 8'b0001_0000;

                                3'b101:
                                    Led_Encendido <= 8'b0010_0000;

                                3'b110:
                                    Led_Encendido <= 8'b0100_0000;

                                3'b111:
                                    Led_Encendido <= 8'b1000_0000;

                                default:
                                    Led_Encendido <= 8'b0000_0001;

                            endcase

                        end

                        default: begin

                            recibir        <= 0;
                            esperando_topo <= 0;
                            contador_bits  <= 0;
                            contador_clk   <= 0;

                        end

                    endcase

                end

                else begin

                    contador_clk <= contador_clk - 1;

                end

            end

        end

    end

endmodule