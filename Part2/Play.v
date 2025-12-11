module Play(
    input clk,
    input rstn,
    input [1:0] state,
    input [3:0] cursor_x,
    input [3:0] cursor_y,
    input is_pressed,
    output reg [1:0] next_state,
    output reg [12*64-1:0] board_data,
    output reg [2:0] sound_code,
    output reg play_sound
);

    localparam PLAY = 2'b01;
    localparam SETTLE = 2'b10;

    reg [11:0] board [0:7][0:7];
    
    integer i, j;
    
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                board_data[(i*8+j)*12 +: 12] = board[i][j];
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < 8; i = i + 1) begin
                for (j = 0; j < 8; j = j + 1) begin
                    board[i][j] <= 12'b0;
                end
            end
            next_state <= PLAY;
            play_sound <= 0;
            sound_code <= 0;
        end else if (state == PLAY) begin
            if (is_pressed && cursor_x == 7 && cursor_y == 7) 
                next_state <= SETTLE;
            else
                next_state <= PLAY;
                
            play_sound <= 0;
        end else begin
            next_state <= PLAY;
        end
    end

endmodule