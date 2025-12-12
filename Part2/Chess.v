module Chess(
    input clk,
    input rstn,
    output audio_out;
);

wire [1:0] state;
reg [3:0] cursor_x;
reg [3:0] cursor_y;
reg is_pressed;
wire [2:0] sound_code;
wire play_sound;
wire game_over;
wire [12*64-1:0] board_data;

Play play(
    .clk(clk),
    .rstn(rstn),
    .state(state), // Connect as needed
    .cursor_x(cursor_x), // Connect as needed
    .cursor_y(cursor_y), // Connect as needed
    .is_pressed(is_pressed), // Connect as needed
    .board_data(board_data), // Connect as needed
    .sound_code(sound_code),
    .play_sound(play_sound),
    .game_over(game_over) // Connect as needed
);

Sound sound(
    .clk(clk),
    .rstn(rstn),
    .sound_code(sound_code),
    .play_sound(play_sound),
    .audio_out(audio_out)
);

DDP ddp(
    .rstn(),
    .pclk(),
    .hen(),
    .ven(),
    .board_data(), //棋局
    .rdata(),
    .raddr(),
    .rgbb()
);

DST dst(
    clk(clk),
    rstn(rstn),   //复位使能
    d(),      //置数
    ce(),     //计数使能信号
    q()
);

endmodule