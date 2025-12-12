`timescale 1ns / 1ps
module DDP(
    input rstn,
//  input ifstart,
    input pclk,
    input hen,
    input ven,
    input [11:0]           rdata, //棋局
    output reg [18:0]      raddr, 
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
                        rgb = 12'hFEA; //浅白
                    else if(((m-60)/60 + (n-60)/60) % 2 == 1)
                        rgb = 12'h777; //浅黑
                else rgb=12'h000;//background
                
            end
        else rgb=12'h000;
    end
endmodule
