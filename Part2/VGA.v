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
Play Play(
    .clk(clk),
    .rstn(rstn),
    .board_data(board_data)
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