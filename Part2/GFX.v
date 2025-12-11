module GFX(
    input clk,
    input pclk,
    input rstn,
    input [1:0] state,
    input [3:0] cursor_x,
    input [3:0] cursor_y,
    input [12*64-1:0] board_data,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue,
    output hs,
    output vs
);

    wire hen, ven;
    
    DST dst_inst (
        .rstn(rstn),
        .pclk(pclk),
        .hen(hen),
        .ven(ven),
        .hs(hs),
        .vs(vs)
    );
    
    always @(posedge pclk or negedge rstn) begin
        if (!rstn) begin
            {red, green, blue} <= 12'b0;
        end else if (hen && ven) begin
            case (state)
                2'b00: begin // MENU
                    {red, green, blue} <= 12'h00F; // Blue
                end
                2'b01: begin // PLAY
                    {red, green, blue} <= 12'h0F0; // Green
                end
                2'b10: begin // SETTLE
                    {red, green, blue} <= 12'hF00; // Red
                end
                default: {red, green, blue} <= 12'hFFF;
            endcase
        end else begin
            {red, green, blue} <= 12'b0;
        end
    end

endmodule
