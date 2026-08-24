module status_led_driver (
    input  logic clk,
    input  logic rst,
    input  logic derrota,
    output logic led_estado
);

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            led_estado <= 0;
        end

        else begin
            led_estado <= derrota;
        end

    end

endmodule