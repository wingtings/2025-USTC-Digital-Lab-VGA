`timescale 1ns / 1ps
module DDP(
    input rstn,
//  input ifstart,
    input pclk,
    input hen,
    input ven,
    input [12*64-1:0] board_data, //棋局
    input [11:0] rdata,
    output reg [11:0]      raddr, 
    output reg [11:0]      rgbb
);
    reg [11:0]rgb;
    reg [11:0]rgbbb;
    reg [9:0]m,n;
    
    always @(posedge pclk)begin
        rgbbb <= rgb;
    end

    always @(*) begin
        rgbb = rgbbb;
    end

    reg [11:0] addra;
    wire [11:0] douta [13:0];

blk_mem_gen_w_wang0001 w_wang0001 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[0])  // output wire [11 : 0] douta
);

blk_mem_gen_w_hou0010 w_hou0010 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[1])  // output wire [11 : 0] douta
);

blk_mem_gen_w_shi0011 w_shi0011 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[2])  // output wire [11 : 0] douta
);
blk_mem_gen_w_ma0100 w_ma0100 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[3])  // output wire [11 : 0] douta
);

blk_mem_gen_w_che0101 w_che0101 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[4])  // output wire [11 : 0] douta
);

blk_mem_gen_w_zu0110 w_zu0110 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[5])  // output wire [11 : 0] douta
);

blk_mem_gen_b_wang1001 b_wang1001 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[6])  // output wire [11 : 0] douta
);

blk_mem_gen_b_hou1010 b_hou1010 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[7])  // output wire [11 : 0] douta
);

blk_mem_gen_b_shi_1011 b_shi1011 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[8])  // output wire [11 : 0] douta
);

blk_mem_gen_b_ma1100 b_ma1100 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[9])  // output wire [11 : 0] douta
);

blk_mem_gen_b_che1101 b_ma1101 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[10])  // output wire [11 : 0] douta
);

blk_mem_gen_b_zu1110 b_zu1110 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[11])  // output wire [11 : 0] douta
);

blk_mem_gen_r_box r_box (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[12])  // output wire [11 : 0] douta
);

blk_mem_gen_b_box b_box (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[13])  // output wire [11 : 0] douta
);

always @(posedge pclk) begin
if(!rstn) 
    begin 
        m<=1;n<=0;
    end     
else if(hen&&ven)    
    begin
        if (m=='d799&&n=='d599) begin m=0;n=0; end
        else if (m=='d799) begin m<=0;n<=n+1; end
        else begin m<=m+1; end
    end//m是行像素[0:799]从左到右,n是列像素[0:599]从上到下
end

integer i;
reg [3:0] type;

always @ (*) begin
    if(!rstn) begin
        rgb=12'h000;   
        addra = 12'b0; 
    end
    else begin
        addra = ((n - 60) % 60) * 60 + ((m - 60) % 60); //统一地址
        if(ven&&hen) begin  
            if(m>=60 && m<540 && n>=60 && n<540) begin
                //首先看光标
                if (board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 3] == 1'b1) begin
                    rgb = (douta[13] == 12'hFFF) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[13]; //优先渲染光标(此处为黑光标)
                end                        
                //然后看棋子
                else if (board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 7] == 1'b1) begin  //判断有无棋子再渲染棋子   
                    type = {board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 8],//阵营
                            board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 9],//类型
                            board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 10],
                            board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 11]};
                    case (type) 
                        4'b0001: rgb = (douta[0] == 12'h431) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[0]; //白王 特殊处理
                        4'b0010: rgb = (douta[1] == 12'hDDA) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[1]; //白后 特殊处理
                        4'b0011: rgb = (douta[2] == 12'hDDA) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[2]; //白象 特殊处理
                        4'b0100: rgb = (douta[3] == 12'h431) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[3]; //白马 特殊处理
                        4'b0101: rgb = (douta[4] == 12'hDDA) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[4]; //白车 特殊处理
                        4'b0110: rgb = (douta[5] == 12'hDDA) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[5]; //白兵 特殊处理
                        4'b1001: rgb = (douta[6] == 12'h431) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[6]; //黑王 特殊处理
                        4'b1010: rgb = (douta[7] == 12'hDDA) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[7]; //黑后 特殊处理
                        4'b1011: rgb = (douta[8] == 12'h431) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[8]; //黑象 特殊处理
                        4'b1100: rgb = (douta[9] == 12'hDDA) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[9]; //黑马 特殊处理
                        4'b1101: rgb = (douta[10] == 12'h431) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[10]; //黑车 特殊处理
                        4'b1110: rgb = (douta[11] == 12'hDDA) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[11]; //黑兵 特殊处理
                        default: rgb = 12'hF00;  //错误显示红色             
                    endcase             
                end    
                //最后渲染棋盘
                else begin    
                    if(((m-60)/60 + (n-60)/60) % 2 == 0)
                        rgb = 12'hCCC; //浅白
                    else if(((m-60)/60 + (n-60)/60) % 2 == 1)
                        rgb = 12'h555; //浅黑
                end
            end
            else begin
                rgb=12'h000;
            end
        end
        else begin
            rgb=12'h000;
        end
    end
end    
endmodule
