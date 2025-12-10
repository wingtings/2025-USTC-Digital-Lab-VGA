`timescale 1ns / 1ps

module DDP(
    input rstn,ifstart,
    input pclk,
    input hen,
    input help,
    input ven,
    input [4:1]t,
    input fail1,fail2,
    input [5:1]x11,y11,x12,y12,x13,y13,x14,y14,
    input [5:1]type1,
    input [3:1]next1,
    input [8:1]score1,
    input [8:1]score2,
    input [16:1]timer,
    input [5:1]x21,y21,x22,y22,x23,y23,x24,y24,
    input [5:1]type2,
    input [3:1]next2,
    input [4:1]boom1,boom2,
    input [3:1]rdata1, //P1棋局
    input [3:1]rdata2, //P2棋局
    // input [16:1]picdata,
    output reg [8:1]raddr1, //P1棋局
    output reg [8:1]raddr2, //P2棋局
    output reg [12:1]rgbb
    // output reg [15:1]picaddr
);
    wire [16:1]picdata1;
    reg [18:1]picaddr1;
    wire picdata2;
    reg [19:1]picaddr2;
    reg [16:1]picdata;
    // reg [19:1]picaddr;
    reg [12:1]rgb;
    reg [12:1]rgbbb;
    reg [10:1]m,n,mm,nn;
    reg [7:0]ziku[10495:0];
    reg [7:0]preview[55:0];
    reg [15:0]type[27:0];

    blk_mem_gen_0 blk_mem_gen_0 (
        .clka(pclk), // input wire clka
        .addra(picaddr1), // input wire [14 : 0] addra
        .douta(picdata1) // output wire [15 : 0] douta
    );
    blk_mem_gen_1 blk_mem_gen_1 (
        .clka(pclk), // input wire clka
        .addra(picaddr2), // input wire [14 : 0] addra
        .douta(picdata2) // output wire [15 : 0] douta
    );

    always @ (posedge pclk,negedge rstn)
    begin
        if(!rstn) 
        begin 
            mm<=0;nn<=0; 
            $readmemh("./ziku copy.COE",ziku);
            $readmemb("./preview copy.COE",preview);
            $readmemb("./28 copy.COE",type);
        end
        else if(hen&&ven) 
        begin
            if (mm=='d799&&nn=='d599) begin mm<=0;nn<=0; end
            else if (mm=='d799) begin mm<=0;nn<=nn+1; end
            else begin mm<=mm+1; end
        end
    end
    
    always @(posedge pclk)begin
        rgbbb<=rgb;
    end

    always @(*) begin
        rgbb=help?(n>=200?(picdata2?12'hFFF:12'h000):{picdata1[16:13],picdata1[11:8],picdata1[5:2]}):rgbbb;
    end

    always @(posedge pclk,negedge rstn) begin
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
    // */

    always @ (*) begin
        raddr1=0;raddr2=0;rgb=12'h000;picaddr1=0;picaddr2=0;
        if(ven&&hen)
            begin
                if(help) begin 
                    // picaddr=n*800+m;
                    if(n>=200) begin picaddr2=(n-200)*800+m; end
                    else begin picaddr1=n*800+m; end
                end

                else begin
                
                if(
                    m>=x11*20+160&&m<x11*20+180&&n>=y11*20+160&&n<y11*20+180||m>=x12*20+160&&m<x12*20+180&&n>=y12*20+160&&n<y12*20+180||m>=x13*20+160&&m<x13*20+180&&n>=y13*20+160&&n<y13*20+180||m>=x14*20+160&&m<x14*20+180&&n>=y14*20+160&&n<y14*20+180
                    ) begin //每行16位
                    if(m%20==0||n%20==0||m%20==19||n%20==19)
                        rgb=12'h777;
                    else
                    case (type1[5:3])
                            3'b001: rgb=12'h0FF;
                            3'b010: rgb=12'h00F;
                            3'b011: rgb=12'hFA0;
                            3'b100: rgb=12'hFF0;
                            3'b101: rgb=12'h0F0;
                            3'b110: rgb=12'hA0F;
                            3'b111: rgb=12'hF00;
                            default: rgb=12'h000;
                    endcase 
                    end
                else if(
                    m>=x21*20+440&&m<x21*20+460&&n>=y21*20+160&&n<y21*20+180||m>=x22*20+440&&m<x22*20+460&&n>=y22*20+160&&n<y22*20+180||m>=x23*20+440&&m<x23*20+460&&n>=y23*20+160&&n<y23*20+180||m>=x24*20+440&&m<x24*20+460&&n>=y24*20+160&&n<y24*20+180
                    ) begin
                    if(m%20==0||n%20==0||m%20==19||n%20==19)
                        rgb=12'h777;
                    else
                    case (type2[5:3])
                            3'b001: rgb=12'h0FF;
                            3'b010: rgb=12'h00F;
                            3'b011: rgb=12'hFA0;
                            3'b100: rgb=12'hFF0;
                            3'b101: rgb=12'h0F0;
                            3'b110: rgb=12'hA0F;
                            3'b111: rgb=12'hF00;
                            default: rgb=12'h000;
                    endcase 
                    end

                else if(m>=158&&m<362&&n>=158&&n<562)
                    if(m>160&&m<360&&n>=219&&n<221)
                        rgb=12'h777;
                    else if(m>=160&&m<360&&n>=160&&n<560) //player1
                        begin raddr1=(n-160)/20*10+(m-160)/20;
                        if((m%20==0||n%20==0||m%20==19||n%20==19)&&rdata1)
                            rgb=12'h777;
                        else
                        case (rdata1)
                            3'b001: rgb=12'h0FF;
                            3'b010: rgb=12'h00F;
                            3'b011: rgb=12'hFA0;
                            3'b100: rgb=12'hFF0;
                            3'b101: rgb=12'h0F0;
                            3'b110: rgb=12'hA0F;
                            3'b111: rgb=12'hF00;
                            default: rgb=12'h000;
                        endcase
                        end
                    else rgb=12'hFFF;

                else if(m>=438&&m<642&&n>=158&&n<562) //player2
                    if(m>440&&m<640&&n>=219&&n<221)
                        rgb=12'h777;
                    else if(m>=440&&m<640&&n>=160&&n<560)
                        begin raddr2=(n-160)/20*10+(m-440)/20; 
                        if((m%20==0||n%20==0||m%20==19||n%20==19)&&rdata2)
                            rgb=12'h777;
                        else
                        case (rdata2)
                            3'b001: rgb=12'h0FF;
                            3'b010: rgb=12'h00F;
                            3'b011: rgb=12'hFA0;
                            3'b100: rgb=12'hFF0;
                            3'b101: rgb=12'h0F0;
                            3'b110: rgb=12'hA0F;
                            3'b111: rgb=12'hF00;
                            default: rgb=12'h000;
                        endcase
                        end
                    else rgb=12'hFFF;

                else if(m>=80&&m<160&&n>=200&&n<280) //preview1
                    begin if(preview[(n-200)/10+(next1-1)*8][7-(m-80)/10])
                        case (next1)
                            3'b001: begin if(m%20==0||n%20==10||m%20==19||n%20==9)
                        rgb=12'h777; else rgb=12'h0FF; end
                            3'b010: begin if(m%20==10||n%20==0||m%20==9||n%20==19)
                        rgb=12'h777; else rgb=12'h00F; end
                            3'b011: begin if(m%20==10||n%20==0||m%20==9||n%20==19)
                        rgb=12'h777; else rgb=12'hFA0; end
                            3'b100: begin if(m%20==0||n%20==0||m%20==19||n%20==19)
                        rgb=12'h777; else rgb=12'hFF0; end
                            3'b101: begin if(m%20==10||n%20==0||m%20==9||n%20==19)
                        rgb=12'h777; else rgb=12'h0F0; end
                            3'b110: begin if(m%20==10||n%20==0||m%20==9||n%20==19)
                        rgb=12'h777; else rgb=12'hA0F; end
                            3'b111: begin if(m%20==10||n%20==0||m%20==9||n%20==19)
                        rgb=12'h777; else rgb=12'hF00; end
                            default: rgb=12'h000;
                        endcase
                        else rgb=12'h000;
                    end //每行8位
                else if(m>=640&&m<720&&n>=200&&n<280) //preview2
                    begin if(preview[(n-200)/10+(next2-1)*8][7-(m-640)/10])
                        case (next2)
                            3'b001: begin if(m%20==0||n%20==10||m%20==19||n%20==9)
                        rgb=12'h777; else rgb=12'h0FF; end
                            3'b010: begin if(m%20==10||n%20==0||m%20==9||n%20==19)
                        rgb=12'h777; else rgb=12'h00F; end
                            3'b011: begin if(m%20==10||n%20==0||m%20==9||n%20==19)
                        rgb=12'h777; else rgb=12'hFA0; end
                            3'b100: begin if(m%20==0||n%20==0||m%20==19||n%20==19)
                        rgb=12'h777; else rgb=12'hFF0; end
                            3'b101: begin if(m%20==10||n%20==0||m%20==9||n%20==19)
                        rgb=12'h777; else rgb=12'h0F0; end
                            3'b110: begin if(m%20==10||n%20==0||m%20==9||n%20==19)
                        rgb=12'h777; else rgb=12'hA0F; end
                            3'b111: begin if(m%20==10||n%20==0||m%20==9||n%20==19)
                        rgb=12'h777; else rgb=12'hF00; end
                            default: rgb=12'h000;
                        endcase
                        else rgb=12'h000;
                    end

                else if(m>=88&&m<152&&n>=164&&n<196) //preview11
                    begin rgb=ziku[5120+(n-164)*8+(m-88)/8][7-(m-88)%8]?12'hFFF:12'h000; end //32*32 每行4字节
                else if(m>=648&&m<712&&n>=164&&n<196) //preview22
                    begin rgb=ziku[5120+(n-164)*8+(m-648)/8][7-(m-648)%8]?12'hFFF:12'h000; end

                else if(m>=88&&m<120&&n>=488&&n<552) //score11 32*64
                    begin rgb=ziku[256+score1[8:5]*256+(n-488)*4+(m-88)/8][7-(m-88)%8]?12'hFFF:12'h000; end
                else if(m>=120&&m<152&&n>=488&&n<552) //score12 32*64
                    begin rgb=ziku[256+score1[4:1]*256+(n-488)*4+(m-120)/8][7-(m-120)%8]?12'hFFF:12'h000; end
                else if(m>=648&&m<680&&n>=488&&n<552) //score21 32*64
                    begin rgb=ziku[256+score2[8:5]*256+(n-488)*4+(m-648)/8][7-(m-648)%8]?12'hFFF:12'h000; end
                else if(m>=680&&m<712&&n>=488&&n<552) //score22 32*64
                    begin rgb=ziku[256+score2[4:1]*256+(n-488)*4+(m-680)/8][7-(m-680)%8]?12'hFFF:12'h000; end

                else if(m>=88&&m<152&&n>=456&&n<488) //score10 64*32
                    begin rgb=ziku[(n-456)*8+(m-88)/8][7-(m-88)%8]?12'hFFF:12'h000; end
                else if(m>=648&&m<712&&n>=456&&n<488) //score20 64*32
                    begin rgb=ziku[(n-456)*8+(m-648)/8][7-(m-648)%8]?12'hFFF:12'h000; end

                else if(m>=158&&m<642&&n>=46&&n<114)begin

                    if(fail2||timer==0&&score1>score2)begin 
                    
                        // if(m>=160&&m<640&&n>=48&&n<112)
                        if(m>=288&&m<320&&n>=48&&n<112) //32*64
                            begin rgb=ziku[5376+(n-48)*4+(m-288)/8][7-(m-288)%8]?12'h000:12'hFFF; end
                        else if(m>=320&&m<352&&n>=48&&n<112) //32*64
                            begin rgb=ziku[512+(n-48)*4+(m-320)/8][7-(m-320)%8]?12'h000:12'hFFF; end
                        else if(m>=352&&m<512&&n>=48&&n<112) //160*64
                            begin rgb=ziku[5376+256+(n-48)*20+(m-352)/8][7-(m-352)%8]?12'h000:12'hFFF; end
                        // else rgb=12'h000;
                        else rgb=12'hFFF;
                    end
                
                    else if(fail1||timer==0&&score2>score1)begin
                
                        // if(m>=160&&m<640&&n>=48&&n<112)
                        if(m>=288&&m<320&&n>=48&&n<112) //32*64
                            begin rgb=ziku[5376+(n-48)*4+(m-288)/8][7-(m-288)%8]?12'h000:12'hFFF; end
                        else if(m>=320&&m<352&&n>=48&&n<112) //32*64
                            begin rgb=ziku[768+(n-48)*4+(m-320)/8][7-(m-320)%8]?12'h000:12'hFFF; end
                        else if(m>=352&&m<512&&n>=48&&n<112) //160*64
                            begin rgb=ziku[5376+256+(n-48)*20+(m-352)/8][7-(m-352)%8]?12'h000:12'hFFF; end
                        else rgb=12'hFFF;
                        // else rgb=12'h000;
                    end

                    else if(timer==0&&score1==score2&&ifstart)begin
                    
                        // if(m>=160&&m<640&&n>=48&&n<112)
                        if(m>=336&&m<464&&n>=48&&n<112) //32*64
                            begin rgb=ziku[7424+(n-48)*16+(m-336)/8][7-(m-336)%8]?12'h000:12'hFFF; end
                        else rgb=12'hFFF;
                    end

                    // else rgb=12'hFFF;
                    //((timer<=0000000100000000)?12'hF00:12'hFFF)
                    else 
                        begin
                        if(m>=160&&m<416&&n>=48&&n<112) //title1 256*64
                            begin rgb=ziku[(t>0?8448:3072)+(n-48)*32+(m-160)/8][7-(m-160)%8]?12'hFFF:12'h000; end
                        else if(m>=416&&m<480&&n>=48&&n<112) rgb=12'h000;
                        else if(m>=480&&m<512&&n>=48&&n<112) //title20 32*64
                            begin rgb=ziku[256+(t>0?0:timer[16:13])*256+(n-48)*4+(m-480)/8][7-(m-480)%8]?((timer<=16'b0000000100000000)?12'hF00:12'hFFF):12'h000; end
                        else if(m>=512&&m<544&&n>=48&&n<112) //title21 32*64
                            begin rgb=ziku[256+(t>0?0:timer[12:9])*256+(n-48)*4+(m-512)/8][7-(m-512)%8]?((timer<=16'b0000000100000000)?12'hF00:12'hFFF):12'h000; end
                        else if(m>=544&&m<576&&n>=48&&n<112) //title22 32*64
                            begin rgb=ziku[256+10*256+(n-48)*4+(m-544)/8][7-(m-544)%8]?((timer<=16'b0000000100000000)?12'hF00:12'hFFF):12'h000; end
                        else if(m>=576&&m<608&&n>=48&&n<112) //title23 32*64
                            begin rgb=ziku[256+(t>0?(t/10):timer[8:5])*256+(n-48)*4+(m-576)/8][7-(m-576)%8]?((timer<=16'b0000000100000000)?12'hF00:12'hFFF):12'h000; end
                        else if(m>=608&&m<640&&n>=48&&n<112) //title24 32*64
                            begin rgb=ziku[256+(t>0?(t%10):timer[4:1])*256+(n-48)*4+(m-608)/8][7-(m-608)%8]?((timer<=16'b0000000100000000)?12'hF00:12'hFFF):12'h000; end
                        else rgb=12'hFFF;
                        end
                end
                else if(m>=88&&m<152&&n>=288&&n<352)
                begin rgb=ziku[6912+(n-288)*8+(m-88)/8][7-(m-88)%8]?12'hFFF:12'h000; end

                else if(m>=648&&m<712&&n>=288&&n<352)
                begin rgb=ziku[6912+(n-288)*8+(m-648)/8][7-(m-648)%8]?12'hFFF:12'h000; end 

                else if(m>=104&&m<136&&n>=368&&n<432)
                begin rgb=ziku[boom1*256+256+(n-368)*4+(m-104)/8][7-(m-104)%8]?12'hFFF:12'h000; end

                else if(m>=664&&m<696&&n>=368&&n<432)
                begin rgb=ziku[boom2*256+256+(n-368)*4+(m-664)/8][7-(m-664)%8]?12'hFFF:12'h000; end

                else rgb=12'h000;//background
                end
            end
        else rgb=12'h000;
    end
endmodule
