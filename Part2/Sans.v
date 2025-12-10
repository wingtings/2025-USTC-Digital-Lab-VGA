module Sans(
        input          clkk,
        input          rstn,
        input          PS2_CLK,
        input          PS2_DATA,
        output  [3:0]  red,
        output  [3:0]  green,
        output  [3:0]  blue,
        output         hs,
        output         vs,
        output         pwm,
        output reg     start
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

MUSIC MUSIC(
        .clk(clk),
        .start(start),
        .rstn(reset&rstn),            
        .B(pwm)
);//音乐播放模块


wire [10:0] key_event;
keyboard keyboard(
        .clk_100mhz(clk),
        .rst_n(rstn),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .key_event(key_event)
);  

reg boom1, boom2;
always @(posedge clk,negedge rstn) begin
if(~rstn) begin w1<=0;a1<=0;s1<=0;d1<=0;w2<=0;a2<=0;s2<=0;d2<=0;reset<=1;space<=0;P<=0;boom1<=0;boom2<=0; end
else begin
temp<=key_event[7:0];
        if (key_event[10]&!key_event[8]&temp!=key_event[7:0]) 
        begin//按键有效+不是松开
        case ({key_event[7:0]}) 
                8'h1D: begin w1<=1; end//W
                8'h1C: begin a1<=1; end//A
                8'h1B: begin s1<=1; end//S
                8'h23: begin d1<=1; end//D
                8'h75: if (key_event[9]) begin w2<=1; end//�??
                8'h6B: if (key_event[9]) begin a2<=1; end//�??
                8'h72: if (key_event[9]) begin s2<=1; end//�??
                8'h74: if (key_event[9]) begin d2<=1; end//�??
                // 8'h3A: begin music<=~music; end//M
                8'h4D: begin P<=1; end//P pause
                8'h29: begin space<=1; end//space
                8'h2D: begin reset<=0; end//R
                8'h5A: begin  end//enter
                8'h16: begin boom1<=1;end
                8'h69: begin boom2<=1;end
        endcase
        temp<=key_event[7:0];
        end
        else begin 
        temp<=key_event[7:0];w1<=0;a1<=0;s1<=0;d1<=0;w2<=0;a2<=0;s2<=0;d2<=0;reset<=1;space<=0;P<=0;boom1<=0;boom2<=0;
        end
end
end


endmodule