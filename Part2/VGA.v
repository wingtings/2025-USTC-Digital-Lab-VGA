module VGA(
        input          clkk,
        input          rstn,
        output  [3:0]  red,
        output  [3:0]  green,
        output  [3:0]  blue,
        output         hs,
        output         vs
);

wire hen,ven;
wire [11:0] addra;
wire [11:0] douta;

wire pclk;
clk_wiz_0 clk_wiz_0(
        .clk_out1(pclk),
        .clk_out2(clk),
        .reset(~rstn),
        .locked(),
        .clk_in1(clkk)
);

wire  [12*64-1 :0] board_data;
reg [3:0] cursor_x;
reg [3:0] cursor_y;
reg is_pressed;

Play play(
    .clk(clk),
    .rstn(rstn),
    .cursor_x(cursor_x), // Connect as needed
    .cursor_y(cursor_y), // Connect as needed
    .is_pressed(is_pressed), // Connect as needed
    .board_data(board_data), // Connect as needed
    .sound_code(),
    .play_sound(),
    .game_over() // Connect as needed
);

wire [10:0] key_event;   // 键盘事件寄存器
Keyboard Keyboard(
    .clk_100mhz(clk),
    .rst_n(rstn),
    .ps2_c(ps2_c),
    .ps2_d(ps2_d),
    .key_event(key_event)
);

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

endmodule