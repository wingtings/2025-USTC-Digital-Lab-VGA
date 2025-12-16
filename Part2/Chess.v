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
    output         pwm
);

// 游戏状态定义
localparam PLAY_STATE = 2'b01;
localparam BLACK_WIN_STATE = 2'b10; // 黑胜
localparam WHITE_WIN_STATE = 2'b11; // 白胜
localparam DRAW_STATE = 2'b00; // 和棋

wire hen,ven;
wire [11:0] addra;
wire [11:0] douta;
wire turn; // 0: White, 1: Black
wire [1:0] state;
reg [2:0] cursor_x;
reg [2:0] cursor_y;
reg is_pressed;
reg is_g_pressed;
wire [2:0] sound_code;
wire play_sound;
wire [1:0] game_over; //00: Draw, 01: Play, 10: Black Win, 11: White Win
wire [12*64-1:0] board_data;
wire [10:0] key_event;   // 键盘事件寄存器
reg [7:0] temp; // 上一个时钟周期的按键码
wire [7:0] wanted_promotion; // 期望升变的棋子类型
wire pclk;
clk_wiz_0 clk_wiz_0(
        .clk_out1(pclk),
        .clk_out2(clk),
        .reset(~rstn),
        .locked(),
        .clk_in1(clkk)
);


// 光标位置和按键信号更新逻辑
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cursor_x <= 3'd0;
        cursor_y <= 3'd0;
        is_pressed <= 1'b0;
        is_g_pressed <= 1'b0;
        temp <= 8'd0;
    end else begin
        temp <= key_event[7:0];
        if (key_event[10] && !key_event[8] && temp != key_event[7:0]) begin
            case (key_event[7:0])
                8'h15:  begin cursor_x <= cursor_x - 1; cursor_y <= cursor_y - 1; end// Q: 左上
                8'h24:  begin cursor_x <= cursor_x + 1; cursor_y <= cursor_y - 1; end// E: 右上
                8'h1A:  begin cursor_x <= cursor_x - 1; cursor_y <= cursor_y + 1; end// Z: 左下
                8'h21:  begin cursor_x <= cursor_x + 1; cursor_y <= cursor_y + 1; end// C: 右下
                8'h1D:  begin cursor_y <= cursor_y - 1; end// W: 上
                8'h22:  begin cursor_y <= cursor_y + 1; end// X: 下
                8'h1B:  begin cursor_y <= cursor_y + 1; end// S: 下 // 这样使用 WASD 控制光标移动, 也能兼容 QWEADZXC 对角移动
                8'h1C:  begin cursor_x <= cursor_x - 1; end// A: 左
                8'h23:  begin cursor_x <= cursor_x + 1; end// D: 右
                8'h29:  begin is_pressed <= 1'b1; end // Space: 选中
                8'h34:  begin is_g_pressed <= 1'b1; end // G: 切换升变
                default: ;
            endcase
            temp <= key_event[7:0];
        end else begin
            if (key_event[10] && key_event[8]) temp <= 8'h00;
            else temp <= temp;
            is_pressed <= 1'b0;
            is_g_pressed <= 1'b0;
        end
    end
end

Play play(
    .clk(clk),
    .rstn(rstn),
    .state(state),
    .cursor_x(cursor_x),
    .cursor_y(cursor_y),
    .is_pressed(is_pressed),
    .is_g_pressed(is_g_pressed),
    .board_data(board_data),
    .sound_code(sound_code),
    .play_sound(play_sound),
    .wanted_promotion(wanted_promotion), // 期望升变的棋子类型
    .turnstate(turn)
);

Sound sound(
    .clk(clk),
    .rstn(rstn),
    .sound_code(sound_code),
    .play_sound(play_sound),
    .B(pwm)
);

DDP DDP(
    .hen(hen),
    .ven(ven),
    .board_data(board_data),
    .rstn(rstn),
    .pclk(pclk),
    .rdata(douta),       // 连接图像数据输入
    .raddr(addra),       // 连接图像地址输出
    .rgbb({red,green,blue}),
    .state(state),  // 根据当前状态实现不同渲染策略
    .wanted_promotion(wanted_promotion), //升变棋子信息
    .game_over(game_over) //游戏结束信息
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

Over over(
    .clkk(clk),
    .rstn(rstn),
    .board_data(board_data),
    .turn(turn), // 0: White, 1: Black
    .game_over(game_over) // 00: Draw, 01: Play, 10: Black Win, 11: White Win
);

endmodule
