module timer_module #(
    parameter CLK_FREQ = 100_000_000
)(
    input  logic clk,
    input  logic rst,
    input  logic disminuir,
    input logic siguiente_topo,
    output logic timeout
    
);

    // =========================================================
    // Señales internas
    // =========================================================
    logic [31:0] count;
    logic [31:0] valor_ref;
    logic [3:0] nivel_dificultad;

    // Señal que indica que el contador llegó al límite
    logic fin_tiempo;

    // =========================================================
    // NIVEL DE DIFICULTAD
    // =========================================================
    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            nivel_dificultad <= 4'd0;
        end

        else if (disminuir) begin

            if (nivel_dificultad < 4'd9)
                nivel_dificultad <= nivel_dificultad + 1'b1;

        end

    end

    // =========================================================
    // SELECTOR DE TIEMPOS
    // =========================================================
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

            default:
                valor_ref = CLK_FREQ * 15 / 10;

        endcase

    end

    // =========================================================
    // COMPARADOR
    // =========================================================
    always_comb begin

        if (count >= valor_ref - 1)
            fin_tiempo = 1'b1;
        else
            fin_tiempo = 1'b0;

    end

    // =========================================================
    // CONTADOR
    // =========================================================
    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            count <= 0;
        end

        else if (fin_tiempo) begin
            count <= 0;
        end

        else begin
            count <= count + 1;
        end

    end

    // =========================================================
    // GENERACIÓN DE PULSOS
    // =========================================================
    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            timeout        <= 0;
            siguiente_topo <= 0;
        end

        else begin

            timeout        <= fin_tiempo;
            siguiente_topo <= fin_tiempo;

        end

    end

endmodule