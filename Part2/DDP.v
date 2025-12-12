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

    reg [11:0] addra [13:0];
    reg [11:0] douta [13:0];

blk_mem_gen_w_wang0001 w_wang0001 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[0]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[0])  // output wire [11 : 0] douta
);

blk_mem_gen_w_hou0010 w_hou0010 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[1]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[1])  // output wire [11 : 0] douta
);

blk_mem_gen_w_shi0011 w_shi0011 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[2]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[2])  // output wire [11 : 0] douta
);
blk_mem_gen_w_ma0100 w_ma0100 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[3]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[3])  // output wire [11 : 0] douta
);

blk_mem_gen_w_che0101 w_che0101 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[4]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[4])  // output wire [11 : 0] douta
);

blk_mem_gen_w_zu0110 w_zu0110 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[5]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[5])  // output wire [11 : 0] douta
);

blk_mem_gen_b_wang1001 b_wang1001 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[6]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[6])  // output wire [11 : 0] douta
);

blk_mem_gen_b_hou1010 b_hou1010 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[7]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[7])  // output wire [11 : 0] douta
);

blk_mem_gen_b_shi_1011 b_shi1011 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[8]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[8])  // output wire [11 : 0] douta
);

blk_mem_gen_b_ma1100 b_ma1100 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[9]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[9])  // output wire [11 : 0] douta
);

blk_mem_gen_b_che1101 b_ma1101 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[10]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[10])  // output wire [11 : 0] douta
);

blk_mem_gen_b_zu1110 b_zu1110 (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[11]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[11])  // output wire [11 : 0] douta
);

blk_mem_gen_r_box r_box (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[12]),  // input wire [11 : 0] addra
  .dina(12'b0),    // input wire [11 : 0] dina
  .douta(douta[12])  // output wire [11 : 0] douta
);

blk_mem_gen_b_box b_box (
  .clka(pclk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(addra[13]),  // input wire [11 : 0] addra
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
        end
    end


    always @ (*) begin
//      raddr=0;
        rgb=12'h000;
        if(ven&&hen)
            begin                       
                      
                if(m>=60 && m<540 && n>=60 && n<540)
                    if(((m-60)/60 + (n-60)/60) % 2 == 0)
                        rgb = 12'hCCC; //浅白
                    else if(((m-60)/60 + (n-60)/60) % 2 == 1)
                        rgb = 12'h555; //浅黑
                else rgb=12'h000;//background
                
            end
        else rgb=12'h000;
    end
endmodule
