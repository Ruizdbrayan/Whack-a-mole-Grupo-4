module uart_receptor #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 9600
)(
    input  logic clk,
    input  logic rst,
    input  logic Topo_Generado,
    output logic [7:0] LED_Encendido
);

    // ===============================
    // Señales internas
    // ===============================
    logic [28:0] count_main;
    logic [3:0]  bit_count;
    logic [7:0]  registro;
    logic        start, enabler, tick;
    logic [7:0]  bit_select;

    // ===============================
    // 🔹 Contador principal
    // ===============================
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            count_main <= 0;
        else
            count_main <= count_main + 1;
    end

    // ===============================
    // 🔹 Comparador de inicio
    // ===============================
    assign start = (count_main == 0);

    // ===============================
    // 🔹 Comparador de ticks (baud rate)
    // ===============================
    localparam integer TICKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    assign tick = (count_main == TICKS_PER_BIT);

    // ===============================
    // 🔹 Contador de bits
    // ===============================
    always_ff @(posedge clk or posedge rst) begin
        if (tick)
            bit_count <= 0;
        else if (start)
            bit_count <= 0;
        else if (tick)
            bit_count <= bit_count + 1;
    end

    // ===============================
    // 🔹 Decoder one-hot de 8 entradas (selección de bit)
    // ===============================
    always_comb begin
        case (bit_count)
            3'd0: bit_select = 8'b00000001;
            3'd1: bit_select = 8'b00000010;
            3'd2: bit_select = 8'b00000100;
            3'd3: bit_select = 8'b00001000;
            3'd4: bit_select = 8'b00010000;
            3'd5: bit_select = 8'b00100000;
            3'd6: bit_select = 8'b01000000;
            3'd7: bit_select = 8'b10000000;
            default: bit_select = 8'b00000000;
        endcase
    end

    // ===============================
    // 🔹Registro de salida
    // ===============================
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            registro <= 8'b0;
        else if (tick) begin
            if (Topo_Generado)
                registro <= registro | bit_select;
            else
                registro <= registro & ~bit_select;
        end
    end

    assign LED_Encendido = registro;

endmodule
