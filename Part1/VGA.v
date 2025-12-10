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
wire [14:0] addra;
wire [11:0] douta;

wire pclk;
clk_wiz_0 clk_wiz_0(
        .clk_out1(pclk),
        .clk_out2(clk),
        .reset(~rstn),
        .locked(),
        .clk_in1(clkk)
);

blk_mem_gen_0 VRAM (
         .clka(pclk),    // input wire clka
         .ena(1'b1),     // 
         .wea(1'b0),     // 
         .addra(addra),  // input wire [14 : 0] addra
         .dina(12'b0),   // input wire [11 : 0] dina
         .douta(douta)  // output wire [11 : 0] douta
);
    
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