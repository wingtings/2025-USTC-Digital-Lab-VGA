module Menu(
    input clk,
    input rstn,
    input [1:0] state,
    input is_pressed,
    output reg [1:0] next_state
);

    localparam MENU = 2'b00;
    localparam PLAY = 2'b01;

    always @(*) begin
        next_state = MENU;
        if (state == MENU) begin
            if (is_pressed)
                next_state = PLAY;
            else
                next_state = MENU;
        end
    end

endmodule