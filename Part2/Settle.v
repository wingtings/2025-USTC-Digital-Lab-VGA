module Settle(
    input clk,
    input rstn,
    input [1:0] state,
    input is_pressed,
    output reg [1:0] next_state
);

    localparam MENU = 2'b00;
    localparam SETTLE = 2'b10;

    always @(*) begin
        next_state = SETTLE;
        if (state == SETTLE) begin
            if (is_pressed)
                next_state = MENU;
            else
                next_state = SETTLE;
        end
    end

endmodule