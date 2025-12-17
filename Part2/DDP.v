`timescale 1ns / 1ps
module DDP(
    input rstn,
//  input ifstart,
    input pclk,
    input clk,
    input hen,
    input ven,
    input [1:0] state,  // 当前游戏状态, 根据不同状态实现不同渲染策略
//    input [1:0] game_over, //00: Draw, 01: Play, 10: Black Win, 11: White Win
    input [12*64-1:0] board_data, //棋局
    input [11:0] rdata,
    input [7:0] wanted_promotion, // 期望升变的棋子类型
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

// 游戏状态定义
localparam PLAY_STATE = 2'b01;//play
localparam BLACK_WIN_STATE = 2'b10; // 黑胜
localparam WHITE_WIN_STATE = 2'b11; // 白胜
localparam DRAW_STATE = 2'b00; // Draw

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

blk_mem_gen_b_che1101 b_che1101 (
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

reg [14:0] addra_sans; //渲染sans
wire [11:0] douta_sans [8:1]; //各个模块

reg [25:0] timer_cnt;   // 播放速度计时器
reg [2:0]  frame_idx;   // 当前帧索引 (0, 1, 2...)
localparam FRAME_NUM    = 6;         // 图片总数
localparam SWITCH_TIME  = 20000000;  // 切换间隔 (约0.5秒)

always @(posedge clk) begin
    if(!rstn) begin
        timer_cnt <= 0;
        frame_idx <= 1;
    end else begin
        if(timer_cnt >= SWITCH_TIME) begin
            timer_cnt <= 0;
            if(frame_idx == FRAME_NUM)
                frame_idx <= 1;
            else
                frame_idx <= frame_idx + 1;
        end else begin
            timer_cnt <= timer_cnt + 1;
        end
    end
end

blk_mem_gen_sans_1 sans_1 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra_sans),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta_sans[1])  // output wire [11 : 0] douta
);

blk_mem_gen_sans_2 sans_2 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra_sans),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta_sans[2])  // output wire [11 : 0] douta
);

blk_mem_gen_sans_3 sans_3 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra_sans),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta_sans[3])  // output wire [11 : 0] douta
);

blk_mem_gen_sans_4 sans_4 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra_sans),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta_sans[4])  // output wire [11 : 0] douta
);

blk_mem_gen_sans5 sans_5 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra_sans),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta_sans[5])  // output wire [11 : 0] douta
);

blk_mem_gen_sans6 sans_6 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra_sans),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta_sans[6])  // output wire [11 : 0] douta
);

blk_mem_gen_sans_7 sans_7 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra_sans),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta_sans[7])  // output wire [11 : 0] douta
);

blk_mem_gen_sans_8 sans_8 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra_sans),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta_sans[8])  // output wire [11 : 0] douta
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
        addra_sans = 15'b0;
    end
    else begin
        addra = ((n - 60) % 60) * 60 + ((m - 60) % 60); //统一地址
        addra_sans = (n - 150) * 150 + (m - 570); //统一sans地址
        if(ven&&hen) begin  
            if(m>=60 && m<540 && n>=60 && n<540) begin
                //首先看光标
                // Play.v文件: {3'b0, is_selected(bit8), board[7:0]}
                // bit9是光标颜色,bit8是光标是否存在, bit4是有效位, bit3是阵营, bit2:0是棋子类型
                if (board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 8] == 1'b1 && board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 4] == 1'b0) begin //此处有光标且没有棋子   
                    if(board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 9] == 1'b1) begin
                      if(douta[12] == 12'h0F2) begin
                        if(((m-60)/60 + (n-60)/60) % 2 == 0) rgb = 12'hCCC; //浅白
                        else if(((m-60)/60 + (n-60)/60) % 2 == 1) rgb = 12'h555; //浅黑                        
                      end
                      else begin
                        rgb = douta[12];
                      end
                    end
                    //rgb = (douta[12] == 12'hFFF) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[12]; //优先渲染光标(此处为红光标)
                    else begin
                      if(douta[13] == 12'h0F2) begin
                        if(((m-60)/60 + (n-60)/60) % 2 == 0) rgb = 12'hCCC; //浅白
                        else if(((m-60)/60 + (n-60)/60) % 2 == 1) rgb = 12'h555; //浅黑                        
                      end
                      else begin
                        rgb = douta[13];
                      end                      
                    end
                    //rgb = (douta[13] == 12'hFFF) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[13]; //优先渲染光标(此处为黑光标)
                end            
                //然后看棋子
                else if(board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 8] == 1'b1 && board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 4] == 1'b1) begin
                  if(board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 9] == 1'b1) begin
                    if(douta[12] == 12'h0F2) begin
                      type = {board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 3],//阵营(bit3)
                            board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 2],//类型(bit2)
                            board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 1],
                            board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 0]};
                    case (type) 
                        4'b0001: rgb = (douta[0] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[0]; //白王 特殊处理
                        4'b0010: rgb = (douta[1] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[1]; //白后 特殊处理
                        4'b0011: rgb = (douta[2] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[2]; //白象 特殊处理
                        4'b0100: rgb = (douta[3] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[3]; //白马 特殊处理
                        4'b0101: rgb = (douta[4] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[4]; //白车 特殊处理
                        4'b0110: rgb = (douta[5] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[5]; //白兵 特殊处理
                        4'b1001: rgb = (douta[6] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[6]; //黑王 特殊处理
                        4'b1010: rgb = (douta[7] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[7]; //黑后 特殊处理
                        4'b1011: rgb = (douta[8] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[8]; //黑象 特殊处理
                        4'b1100: rgb = (douta[9] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[9]; //黑马 特殊处理
                        4'b1101: rgb = (douta[10] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[10]; //黑车 特殊处理
                        4'b1110: rgb = (douta[11] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[11]; //黑兵 特殊处理
                        default: rgb = 12'hF00;  //错误显示红色             
                    endcase  
                    end
                    else rgb = douta[12];
                  end
                  else begin
                    if(douta[13] == 12'h0F2) begin
                      type = {board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 3],//阵营(bit3)
                              board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 2],//类型(bit2)
                              board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 1],
                              board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 0]};
                      case (type) 
                          4'b0001: rgb = (douta[0] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[0]; //白王 特殊处理
                          4'b0010: rgb = (douta[1] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[1]; //白后 特殊处理
                          4'b0011: rgb = (douta[2] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[2]; //白象 特殊处理
                          4'b0100: rgb = (douta[3] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[3]; //白马 特殊处理
                          4'b0101: rgb = (douta[4] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[4]; //白车 特殊处理
                          4'b0110: rgb = (douta[5] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[5]; //白兵 特殊处理
                          4'b1001: rgb = (douta[6] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[6]; //黑王 特殊处理
                          4'b1010: rgb = (douta[7] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[7]; //黑后 特殊处理
                          4'b1011: rgb = (douta[8] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[8]; //黑象 特殊处理
                          4'b1100: rgb = (douta[9] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[9]; //黑马 特殊处理
                          4'b1101: rgb = (douta[10] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[10]; //黑车 特殊处理
                          4'b1110: rgb = (douta[11] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[11]; //黑兵 特殊处理
                          default: rgb = 12'hF00;  //错误显示红色             
                      endcase                        
                    end
                    else rgb = douta[13];
                  end
                end
                else if (board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 4] == 1'b1) begin  //判断有无棋子(bit4)再渲染棋子   
                    type = {board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 3],//阵营(bit3)
                            board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 2],//类型(bit2)
                            board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 1],
                            board_data[ (((n-60)/60)*8 + ((m-60)/60))*12 + 0]};
                    case (type) 
                        4'b0001: rgb = (douta[0] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[0]; //白王 特殊处理
                        4'b0010: rgb = (douta[1] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[1]; //白后 特殊处理
                        4'b0011: rgb = (douta[2] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[2]; //白象 特殊处理
                        4'b0100: rgb = (douta[3] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[3]; //白马 特殊处理
                        4'b0101: rgb = (douta[4] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[4]; //白车 特殊处理
                        4'b0110: rgb = (douta[5] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[5]; //白兵 特殊处理
                        4'b1001: rgb = (douta[6] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[6]; //黑王 特殊处理
                        4'b1010: rgb = (douta[7] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[7]; //黑后 特殊处理
                        4'b1011: rgb = (douta[8] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[8]; //黑象 特殊处理
                        4'b1100: rgb = (douta[9] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[9]; //黑马 特殊处理
                        4'b1101: rgb = (douta[10] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[10]; //黑车 特殊处理
                        4'b1110: rgb = (douta[11] == 12'h0F2) ? (((m-60)/60 + (n-60)/60) % 2 == 1 ? 12'h555 : 12'hCCC) : douta[11]; //黑兵 特殊处理
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

            else if(m>=600 && m<660 && n>=360 && n<420) begin //渲染升变棋子
                type = {wanted_promotion[3],//阵营(bit3)
                        wanted_promotion[2],//类型(bit2)
                        wanted_promotion[1],
                        wanted_promotion[0]};
                case (type) 
                    4'b0001: rgb = (douta[0] == 12'h0F2) ? 12'h000 : douta[0]; //白王 特殊处理
                    4'b0010: rgb = (douta[1] == 12'h0F2) ? 12'h000 : douta[1]; //白后 特殊处理
                    4'b0011: rgb = (douta[2] == 12'h0F2) ? 12'h000 : douta[2]; //白象 特殊处理
                    4'b0100: rgb = (douta[3] == 12'h0F2) ? 12'h000: douta[3]; //白马 特殊处理
                    4'b0101: rgb = (douta[4] == 12'h0F2) ? 12'h000: douta[4]; //白车 特殊处理
                    4'b0110: rgb = (douta[5] == 12'h0F2) ? 12'h000: douta[5]; //白兵 特殊处理
                    4'b1001: rgb = (douta[6] == 12'h0F2) ? 12'h000: douta[6]; //黑王 特殊处理
                    4'b1010: rgb = (douta[7] == 12'h0F2) ? 12'h000: douta[7]; //黑后 特殊处理
                    4'b1011: rgb = (douta[8] == 12'h0F2) ? 12'h000: douta[8]; //黑象 特殊处理
                    4'b1100: rgb = (douta[9] == 12'h0F2) ? 12'h000: douta[9]; //黑马 特殊处理
                    4'b1101: rgb = (douta[10] == 12'h0F2) ? 12'h000 : douta[10]; //黑车 特殊处理
                    4'b1110: rgb = (douta[11] == 12'h0F2) ? 12'h000 : douta[11]; //黑兵 特殊处理
                    default: rgb = 12'h000;  //没有棋子的时候渲染黑色          
                endcase
              end

            else if (m>=570 && m<720 && n>=150 && n<300) begin //渲染侧边 150*150
              if (state == PLAY_STATE) rgb = douta_sans[frame_idx];
              else if (state == WHITE_WIN_STATE) rgb = douta_sans[7]; //白方胜利
              else if (state == BLACK_WIN_STATE) rgb = douta_sans[8]; //黑方胜利
              else rgb = douta_sans[1]; //平局
            end
            else rgb = 12'h000;
        end
        else rgb=12'h000;
    end
end

endmodule
