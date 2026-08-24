module Uart_Receptor (
    input  logic       clk,
    input  logic       reset,
    input  logic       Topo_Generado,
    input  logic       Siguiente_Topo,
    output logic [7:0] Led_Encendido
);

    localparam BAUD_DIV = 100_000_000/90;

    logic [20:0] contador_clk;

    logic recibir;
    logic [3:0] contador_bits;

    logic [2:0] registro;

    logic tick;

    logic topo_d;

    wire start_detectado;

    assign start_detectado = Topo_Generado && !topo_d;

    //--------------------------------------------------
    // Detector de flanco
    //--------------------------------------------------

    always_ff @(posedge clk) begin
        if (reset)
            topo_d <= 0;
        else
            topo_d <= Topo_Generado;
    end

    //--------------------------------------------------
    // Receptor
    //--------------------------------------------------

    always_ff @(posedge clk) begin

        if (reset) begin

            contador_clk  <= 0;
            recibir       <= 0;
            contador_bits <= 0;
            registro      <= 0;
            tick          <= 0;

        end
        else begin

            tick <= 0;

            if (!recibir) begin

                if (start_detectado) begin

                    recibir       <= 1;
                    contador_bits <= 0;
                    contador_clk  <= BAUD_DIV/2;

                end

            end
            else begin

                if (contador_clk == 0) begin

                    tick <= 1;

                    contador_clk <= BAUD_DIV - 1;

                    case (contador_bits)

                        // Start
                        0:
                            contador_bits <= 1;

                        // D1
                        1: begin
                            registro[0] <= Topo_Generado;
                            contador_bits <= 2;
                        end

                        // D2
                        2: begin
                            registro[1] <= Topo_Generado;
                            contador_bits <= 3;
                        end

                        // D3
                        3: begin
                            registro[2] <= Topo_Generado;
                            contador_bits <= 4;
                        end

                        // Relleno
                        4: contador_bits <= 5;
                        5: contador_bits <= 6;
                        6: contador_bits <= 7;

                        // Fin
                        7: begin
                            contador_bits <= 0;
                            recibir <= 0;
                        end

                        default: begin
                            contador_bits <= 0;
                            recibir <= 0;
                        end

                    endcase

                end
                else begin

                    contador_clk <= contador_clk - 1;

                end

            end

        end

    end

    //--------------------------------------------------
    // Decoder
    //--------------------------------------------------

    always_ff @(posedge clk) begin

        if (reset) begin

            Led_Encendido <= 8'b0000_0001;

        end
        else if (Siguiente_Topo) begin

            case (registro)

                3'b000: Led_Encendido <= 8'b0000_0001;
                3'b001: Led_Encendido <= 8'b0000_0010;
                3'b010: Led_Encendido <= 8'b0000_0100;
                3'b011: Led_Encendido <= 8'b0000_1000;
                3'b100: Led_Encendido <= 8'b0001_0000;
                3'b101: Led_Encendido <= 8'b0010_0000;
                3'b110: Led_Encendido <= 8'b0100_0000;
                3'b111: Led_Encendido <= 8'b1000_0000;

                default:
                    Led_Encendido <= 8'b0000_0001;

            endcase

        end

    end

endmodule