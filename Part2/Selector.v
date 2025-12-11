module Selector(
    input clk,
    input rstn,
    input [10:0] key_event,
    output reg [3:0] cursor_x,
    output reg [3:0] cursor_y,
    output reg is_pressed,
    output [11:0] selected_piece
);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cursor_x <= 0;
            cursor_y <= 0;
            is_pressed <= 0;
        end else begin
            is_pressed <= 0; 
            
            if (key_event[10] && !key_event[8]) begin // Key Press
                case (key_event[7:0])
                    8'h1D: begin // W (Up)
                        if (cursor_y > 0) cursor_y <= cursor_y - 1;
                    end
                    8'h1B: begin // S (Down)
                        if (cursor_y < 7) cursor_y <= cursor_y + 1;
                    end
                    8'h1C: begin // A (Left)
                        if (cursor_x > 0) cursor_x <= cursor_x - 1;
                    end
                    8'h23: begin // D (Right)
                        if (cursor_x < 7) cursor_x <= cursor_x + 1;
                    end
                    8'h34: begin // G (Select)
                        is_pressed <= 1;
                    end
                endcase
            end
        end
    end
    
    assign selected_piece = 12'b0;

endmodule