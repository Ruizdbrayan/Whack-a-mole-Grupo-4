module display_7seg_mux_tb;
    logic       clk;
    logic [7:0] aciertos;
    logic [7:0] fallos;
    logic [6:0] display_7seg;
    logic [3:0] select_7seg;

    display_7seg_mux dut (
        .clk(clk),
        .aciertos(aciertos),
        .fallos(fallos),
        .display_7seg(display_7seg),
        .select_7seg(select_7seg)
    );

    always #5 clk = ~clk;

    initial begin
        $monitor("Time: %0t | Aciertos: %0d | Fallos: %0d | Numero en Display: %b | Display Seleccionado: %d",
                $time, aciertos, fallos, display_7seg, select_7seg);
    end

    initial begin
        aciertos = 8'd0;
        fallos = 8'd0;
        display_7seg = 7'b0;
        select_7seg = 4'b0;

        #200;
        aciertos = 8'b0000_0000; // 0 aciertos
        fallos   = 8'b0000_0000; // 0 fallos

        #200;
        aciertos = 8'b0001_0000; // 10 aciertos
        fallos   = 8'b0010_0000; // 20 fallos

        #200;
        aciertos = 8'b0001_0000; // 10 aciertos
        fallos   = 8'b0010_0000; // 20 fallos

        #200;
        aciertos = 8'b0000_0001; // 1 acierto
        fallos   = 8'b0000_1000; // 8 fallos

        #200;
        aciertos = 8'b1001_1001; // 99 aciertos
        fallos   = 8'b1001_1001; // 99 fallos

    end
    
endmodule