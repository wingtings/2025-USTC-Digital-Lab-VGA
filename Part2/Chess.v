module Chess(
    input clkk,
    input rstn,
    input PS2_CLK,
    input PS2_DATA,
    output  [3:0]  red,
    output  [3:0]  green,
    output  [3:0]  blue,
    output         hs,
    output         vs,
    output pwm
);

wire hen,ven;
wire [11:0] addra;
wire [11:0] douta;

wire [1:0] state;
reg [3:0] cursor_x;
reg [3:0] cursor_y;
reg is_pressed;
wire [2:0] sound_code;
wire play_sound;
wire game_over;
wire [12*64-1:0] board_data;
wire [10:0] key_event;   // 键盘事件寄存�?
reg prev_key_valid; // 上一个时钟周期的按键有效标志�?

wire pclk;
clk_wiz_0 clk_wiz_0(
        .clk_out1(pclk),
        .clk_out2(clk),
        .reset(~rstn),
        .locked(),
        .clk_in1(clkk)
);


// 光标位置和按键信号更新�?�辑
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cursor_x <= 4'd0;
        cursor_y <= 4'd0;
        is_pressed <= 1'b0;
        prev_key_valid <= 1'b0;
    end else begin
        prev_key_valid <= key_event[10];    // 更新上一个周期的按键有效标志�?
        // key_event 数据: �? 11 �?:
        // 有效标志�?(1) 扩展标志�?(1) 断码标志�?(1) ASCII�?(8) QWEADZXC 控制光标方向, 空格表示按下
        if (key_event[10] && !prev_key_valid) begin // 只有 key_event[10] �? 0 变成 1 才会 
            if (!key_event[8]) begin
                case (key_event[7:0])
                    8'h51, 8'h71:  begin cursor_x <= cursor_x - 1; cursor_y <= cursor_y - 1; end// Q/q: 左上
                    8'h45, 8'h65:  begin cursor_x <= cursor_x + 1; cursor_y <= cursor_y - 1; end// E/e: 右上
                    8'h5A, 8'h7A:  begin cursor_x <= cursor_x - 1; cursor_y <= cursor_y + 1; end// Z/z: 左下
                    8'h43, 8'h63:  begin cursor_x <= cursor_x + 1; cursor_y <= cursor_y + 1; end// C/c: 右下
                    8'h57, 8'h77:  begin cursor_y <= cursor_y - 1; end// W/w: �?
                    8'h58, 8'h78:  begin cursor_y <= cursor_y + 1; end// X/x: �?
                    8'h41, 8'h61:  begin cursor_x <= cursor_x - 1; end// A/a: �?
                    8'h44, 8'h64:  begin cursor_x <= cursor_x + 1; end// D/d: �?
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
    .sound_code(),
    .play_sound(),
    .game_over() // Connect as needed
);

// Sound sound(
//     .clk(clk),
//     .rstn(rstn),
//     .sound_code(sound_code),
//     .play_sound(play_sound),
//     .audio_out(audio_out)
// );

DDP DDP(
    .hen(hen),
    .ven(ven),
    .board_data(board_data),
    .rstn(rstn),
    .pclk(pclk),
    .rdata(douta),       // 连接图像数据输入
    .raddr(addra),       // 连接图像地址输出
    .rgbb({red,green,blue})
);

DST DST(
    .rstn(rstn),
    .pclk(pclk),
    .hen(hen),
    .ven(ven),
    .hs(hs),
    .vs(vs)
);

Keyboard keyboard(
    .clk_100mhz(clk),
    .rst_n(rstn),
    .ps2_c(PS2_CLK),
    .ps2_d(PS2_DATA),
    .key_event(key_event)
);

endmodule