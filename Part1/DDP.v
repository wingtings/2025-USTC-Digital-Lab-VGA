// 实现DDP功能，将画布与显示屏适配，从而产生色彩信息。
// DDP和DST共同称为DU即显示单元
module DDP#(
        parameter DW = 15,
        parameter H_LEN = 200,
        parameter V_LEN = 150
    )(
    input               hen,        // 行有效信号
    input               ven,        // 场有效信号
    input               rstn,
    input               pclk,
    input  [11:0]       rdata,      // 输入的图像数据

    output reg [11:0]   rgb,        // 图像对应像素点的rgb值
    output reg [DW-1:0] raddr       // 计算得到图像某个像素点的地址
    );


    // 放大四倍
    reg [1:0] sx;       // 提示：sx与sy的作用是作为计数器，逢4进1。将800×600
    reg [1:0] sy;       // 的有效显示区域用200×150表示，也就是实际上的每4×4的
    reg [1:0] nsx;      // 像素点简化成1×1，这样能大大减小IP核声明调用的开销。
    reg [1:0] nsy;      

    // 过于模糊？有需要的同学可以考虑只放大两倍。思考：不放大为什么不行？
    // 开销太大？同学也可以自行探索放大八倍、十六倍的写法。

    always @(*) begin
        sx=nsx;
        sy=nsy;
    end

    wire p;

    // 取ven下降沿
    PS #(1) ps(             // 提示：取下降沿是因为扫描信号从有效区进入了消隐区
        .s      (hen&ven),
        .clk    (pclk),
        .p      (p)
    );

    always @(posedge pclk) begin           // 可能慢一个周期，改hen,ven即可
        if(!rstn) begin
            nsx<=0; nsy<=3;
            rgb<=0;
            raddr<=0;
        end
        else if(hen&&ven) begin
            rgb<=rdata;
            if(sx==2'b11) begin
                raddr<=raddr+1;
            end
            nsx<=sx+1;
        end                               // 无效区域
        else if(p) begin                  // ven下降沿
            rgb<=0;
            if(sy!=2'b11) begin           // 提示：此处地址计算逢4换行，否则继
                raddr<=raddr-H_LEN;       // 续从前面读取的行开头像素再次读取。
            end
            else if(raddr==H_LEN*V_LEN) begin
                raddr<=0;
            end
            nsy<=sy+1;
        end
        else rgb<=0;
    end
endmodule