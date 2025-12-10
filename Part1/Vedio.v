module Vedio(
        input          clkk,
        input          rstn,
        output  [3:0]  red,
        output  [3:0]  green,
        output  [3:0]  blue,
        output         hs,
        output         vs
);

wire hen,ven;
wire [14:0] addra;
reg [11:0] douta;

wire pclk;
clk_wiz_0 clk_wiz_0(
        .clk_out1(pclk),
        .clk_out2(clk),
        .reset(~rstn),
        .locked(),
        .clk_in1(clkk)
);

// ================= 视频播放控制逻辑 =================
reg [25:0] timer_cnt;   // 播放速度计时器
reg [2:0]  frame_idx;   // 当前帧索引 (0, 1, 2...)
localparam FRAME_NUM    = 6;         // 图片总数
localparam SWITCH_TIME  = 20000000;  // 切换间隔 (约0.5秒)

always @(posedge clk) begin
    if(!rstn) begin
        timer_cnt <= 0;
        frame_idx <= 0;
    end else begin
        if(timer_cnt >= SWITCH_TIME) begin
            timer_cnt <= 0;
            if(frame_idx == FRAME_NUM - 1)
                frame_idx <= 0;
            else
                frame_idx <= frame_idx + 1;
        end else begin
            timer_cnt <= timer_cnt + 1;
        end
    end
end

// ================= 多 IP 核实例化与数据选择 =================
wire [11:0] dout0, dout1, dout2,dout3,dout4,dout5;

// 第1帧图片存储器
blllk_mem_gen_0 VRAM0 (
    .clka(pclk), .ena(1'b1), .wea(1'b0), .dina(12'b0),
    .addra(addra),  // 所有 IP 核共用同一个地址信号
    .douta(dout0)
);

// 第2帧图片存储器 
blk_mem_gen_1 VRAM1 (
    .clka(pclk), .ena(1'b1), .wea(1'b0), .dina(12'b0),
    .addra(addra),
    .douta(dout1)
);

// 第3帧图片存储器 
blk_mem_gen_2 VRAM2 (
    .clka(pclk), .ena(1'b1), .wea(1'b0), .dina(12'b0),
    .addra(addra),
    .douta(dout2)
);

blk_mem_gen_3 VRAM3 (
    .clka(pclk), .ena(1'b1), .wea(1'b0), .dina(12'b0),
    .addra(addra),
    .douta(dout3)
);

blk_mem_gen_4 VRAM4 (
    .clka(pclk), .ena(1'b1), .wea(1'b0), .dina(12'b0),
    .addra(addra),
    .douta(dout4)
);

blk_mem_gen_5 VRAM5 (
    .clka(pclk), .ena(1'b1), .wea(1'b0), .dina(12'b0),
    .addra(addra),
    .douta(dout5)
);

// 数据多路选择器：根据 frame_idx 选择对应的 IP 核输出
always @(*) begin
    case(frame_idx)
        0: douta = dout0;
        1: douta = dout1;
        2: douta = dout2;
        3: douta = dout3;
        4: douta = dout4;
        5: douta = dout5;
    endcase
end
    
DDP DDP(
        .hen(hen),
        .ven(ven),
        .rstn(rstn),
        .pclk(pclk),
        .rdata(douta),       // 连接图像数据输入
        .raddr(addra),       // 连接图像地址输出
        .rgb({red,green,blue})
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