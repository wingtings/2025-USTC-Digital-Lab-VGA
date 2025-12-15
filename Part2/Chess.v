module Chess(
    input clk,
    input rstn,
    output audio_out
    input ps2_c,
    input ps2_d
);

wire [1:0] state;
reg [3:0] cursor_x;
reg [3:0] cursor_y;
reg is_pressed;
wire [2:0] sound_code;
wire play_sound;
wire game_over;
wire [12*64-1:0] board_data;
reg [10:0] key_event;   // 键盘事件寄存器
reg prev_key_valid; // 上一个时钟周期的按键有效标志位

// 光标位置和按键信号更新逻辑
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cursor_x <= 4'd0;
        cursor_y <= 4'd0;
        is_pressed <= 1'b0;
        prev_key_valid <= 1'b0;
    end else begin
        prev_key_valid <= key_event[10];    // 更新上一个周期的按键有效标志位
        // key_event 数据: 共 11 位:
        // 有效标志位(1) 扩展标志位(1) 断码标志位(1) ASCII码(8) QWEADZXC 控制光标方向, 空格表示按下
        if (key_event[10] && !prev_key_valid) begin // 只有 key_event[10] 从 0 变成 1 才会 
            if (key_event[8]) begin
                case (key_event[7:0])
                    8'h51, 8'h71:  begin cursor_x <= cursor_x - 1; cursor_y <= cursor_y - 1; end// Q/q: 左上
                    8'h45, 8'h65:  begin cursor_x <= cursor_x + 1; cursor_y <= cursor_y - 1; end// E/e: 右上
                    8'h5A, 8'h7A:  begin cursor_x <= cursor_x - 1; cursor_y <= cursor_y + 1; end// Z/z: 左下
                    8'h43, 8'h63:  begin cursor_x <= cursor_x + 1; cursor_y <= cursor_y + 1; end// C/c: 右下
                    8'h57, 8'h77:  begin cursor_y <= cursor_y - 1; end// W/w: 上
                    8'h58, 8'h78:  begin cursor_y <= cursor_y + 1; end// X/x: 下
                    8'h41, 8'h61:  begin cursor_x <= cursor_x - 1; end// A/a: 左
                    8'h44, 8'h64:  begin cursor_x <= cursor_x + 1; end// D/d: 右
                    default: ;
                endcase
            end
        end else if (!key_event[10]) begin
            is_pressed <= 1'b0; // 松开按键
        end
    end
end
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
    .clk(clk),
    .rstn(rstn),   //复位使能
    .d(),      //置数
    .ce(),     //计数使能信号
    .q()
);

Keyboard keyboard(
    .clk_100mhz(clk),
    .rst_n(rstn),
    .ps2_c(ps2_c),
    .ps2_d(ps2_d),
    .key_event(key_event)
);
endmodule