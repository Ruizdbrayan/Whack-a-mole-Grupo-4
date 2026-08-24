module timer_module #(
    parameter CLK_FREQ = 100_000_000
)(
    input  logic clk,
    input  logic rst,
    input  logic [3:0] nivel_dificultad, // selector 0-9
    output logic timeout,                // indica fin de tiempo
    output logic siguiente_topo          // pulso para generar nuevo topo
);

    // ===============================
    // Señales internas
    // ===============================
    logic [31:0] count;
    logic [31:0] valor_ref;

    // ===============================
    // 🔹 Contador principal
    // ===============================
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            count <= 0;
        else
            count <= count + 1;
    end

    // ===============================
    // 🔹 Selector de tiempos (1.5s → 0.5s)
    // ===============================
    always_comb begin
        case (nivel_dificultad)
            4'd0: valor_ref = CLK_FREQ * 15 / 10; // 1.5 s
            4'd1: valor_ref = CLK_FREQ * 14 / 10; // 1.4 s
            4'd2: valor_ref = CLK_FREQ * 13 / 10; // 1.3 s
            4'd3: valor_ref = CLK_FREQ * 12 / 10; // 1.2 s
            4'd4: valor_ref = CLK_FREQ * 11 / 10; // 1.1 s
            4'd5: valor_ref = CLK_FREQ * 10 / 10; // 1.0 s
            4'd6: valor_ref = CLK_FREQ * 9  / 10; // 0.9 s
            4'd7: valor_ref = CLK_FREQ * 8  / 10; // 0.8 s
            4'd8: valor_ref = CLK_FREQ * 7  / 10; // 0.7 s
            4'd9: valor_ref = CLK_FREQ * 5  / 10; // 0.5 s
            default: valor_ref = CLK_FREQ * 15 / 10; // por defecto 1.5 s
        endcase
    end

    // ===============================
    // 🔹 Comparador integrado
    // ===============================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            timeout        <= 0;
            siguiente_topo <= 0;
            count          <= 0;
        end else if (count >= valor_ref) begin
            timeout        <= 1;
            siguiente_topo <= 1;
            count          <= 0; // reinicia contador
        end else begin
            timeout        <= 0;
            siguiente_topo <= 0;
        end
    end

endmodule
