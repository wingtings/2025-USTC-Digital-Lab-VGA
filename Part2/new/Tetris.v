module Tetris(
    input clkk, rstn,
    input PS2_CLK,PS2_DATA,
    input refresh,
    output hs, vs, pwm, [11:0]rgb,
    output reg start,
    output el1, er1, eu1, ed1, edrop1, overflow1, refresh1, refresh_done1, fail1
);

    wire [16:1]timer;
    wire fail2;
    reg space, P, reset, ifstart, help;
    reg [4:1]sw;
    // /*
    reg [3:0]t;
    reg [16:1]tt;
    // always @ (posedge clk) begin
    //     if(!(rstn&reset)) begin tt<=50000000; end
    //     else if(start&&t!=0) begin
    //         if(tt!=0) begin tt<=tt-1; end
    //         else begin t<=t-1;tt<=50000000; end
    //     end
    // end
    always@(posedge clk)begin
        tt<=timer;
        if(!(rstn&reset)) begin t<=0; tt<=0; end
        else if(timer[8:1]==8'b00000000&&start) t<=5;
        else if(tt!=timer&&t>0) t<=t-1;
    end

    reg [2:0]speedup;
    always@(posedge clk)begin
        speedup <= speedup;
        if(!(rstn&reset)) speedup<=0;
        else if(timer==16'b0000000100000000&&start) speedup<=1;
        else if(timer==16'b0000000000110000&&start) speedup<=2;
    end
    // */

    //主流程状态机
    reg [2:0]NS, CS;
    parameter  IDLE = 0,
               START = 1,
               PAUSE = 2,
               ENDING = 3,
               MAIN   = 4;
    always @(posedge clk)begin
        if(!(rstn&reset))begin
            CS <= MAIN;
        end
        else begin
            CS <= NS;
        end
    end
    always @(*)begin
        NS = CS;
        case(CS)
        MAIN: if(space) NS = IDLE;
        IDLE: if( space 
        && timer!=0 
        ) NS = START;
        START: begin
            if(P) NS = PAUSE;
            if(fail1|fail2|timer==0) NS = ENDING;
        end
        PAUSE:begin
            if(space) NS = START;
        end
        ENDING:begin
            // if(!reset) NS=IDLE;
        end
        endcase
    end
    always @(*)begin
        ifstart = 0;start = 0; help = 0;
        case(CS)
        MAIN: begin help = 1; end
        IDLE: ;
        START: begin ifstart= 1;start = 1; end
        PAUSE:begin ifstart= 1; help = 1; end
        ENDING:begin ifstart= 1; end
        endcase
    end

    reg w1,a1,s1,d1,w2,a2,s2,d2;
    reg [7:0]temp;
    TIMER TIMER(
        .sw(sw),
        .start(start),//计数使能
        .ifstart(ifstart),//更改计时使能
        .timer(timer),
        .clk(clk),
        .rstn(reset&rstn)
    );

    wire [10:0] key_event;

    keyboard keyboard(
        .clk_100mhz(clk),
        .rst_n(rstn),
        .ps2_c(PS2_CLK),
        .ps2_d(PS2_DATA),
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
                    8'h75: if (key_event[9]) begin w2<=1; end//↑
                    8'h6B: if (key_event[9]) begin a2<=1; end//←
                    8'h72: if (key_event[9]) begin s2<=1; end//↓
                    8'h74: if (key_event[9]) begin d2<=1; end//→
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

    always @(posedge clk,negedge rstn) begin
        if(~rstn) sw<=3;
        else if(~ifstart&(w2|w1)) sw<=sw+1;
        else if(~ifstart&(s2|s1)) sw<=sw-1;
    end

    wire pclk;
    clk_wiz_0 clk_wiz_0(
        .clk_out1(pclk),
        .clk_out2(clk),
        .clk_in1(clkk)
    );

    wire [8:1]score1,score2;
    wire [8:1]raddr1,raddr2;
    wire [3:1]rdata1,rdata2;

    wire [5:1]x1,y1,type1;
    wire [3:1]next1;
    // wire refresh1, refresh_done1;
    // wire fail1, eu1, ed1, el1, er1, edrop1, overflow1;

    wire [5:1]x2,y2,type2;
    wire [3:1]next2;
    wire refresh2, refresh_done2;
    wire eu2, ed2, el2, er2, edrop2, overflow2;
    wire [4:0]x11, x12, x13, x14, y11, y12, y13, y14;
    wire [4:0]x21, x22, x23, x24, y21, y22, y23, y24;
    wire [3:0]cnt_boom1, cnt_boom2;
    RAM ram1(
        .clk(clk),
        .score(score1),
        .rd(rdata1),
        .ra(raddr1),
        .rstn(reset&rstn),
        .x          (x1),
        .y          (y1),
        .refresh    (refresh1),
        .refresh_done    (refresh_done1),//底层清楚结束标志，脉冲信号
        .type       (type1[5:3]),
        .dir        (type1[2:1]),
        .eu         (eu1),
        .ed         (ed1),
        .el         (el1),
        .er         (er1),
        .edrop      (edrop1),
        .overflow   (overflow1),
        .x1         (x11),
        .x2         (x12),
        .x3         (x13),
        .x4         (x14),
        .y1         (y11),
        .y2         (y12),
        .y3         (y13),
        .y4         (y14),
        .boom       (boom1),
        .cnt_boom       (cnt_boom1)
    );

    RAM ram2(
        .clk(clk),
        .score(score2),
        .rd(rdata2),
        .ra(raddr2),
        .rstn(reset&rstn),
        .x          (x2),
        .y          (y2),
        .refresh    (refresh2),
        .refresh_done (refresh_done2),
        .type       (type2[5:3]),
        .dir        (type2[2:1]),
        .eu         (eu2),
        .ed         (ed2),
        .el         (el2),
        .er         (er2),
        .edrop      (edrop2),
        .overflow   (overflow2),
        .x1         (x21),
        .x2         (x22),
        .x3         (x23),
        .x4         (x24),
        .y1         (y21),
        .y2         (y22),
        .y3         (y23),
        .y4         (y24),
        .boom       (boom2),
        .cnt_boom   (cnt_boom2)
    );
    
    player player1(
        .rand       (timer[3:1]),
        .clk        (clk),
        .rstn       (reset&rstn),
        .start      (start),
        .up         (t>0 ? w2 : w1),//t ? w2 : w1  
        .down       (t>0 ? s2 : s1),//t ? w2 : s1  
        .left       (t>0 ? a2 : a1),//t ? w2 : a1  
        .right      (t>0 ? d2 : d1),//t ? w2 : d1  
        .x          (x1),
        .y          (y1),
        .refresh    (refresh1),
        .refresh_done    (refresh_done1),//底层清除结束标志，脉冲信号
        .type       (type1[5:3]),
        .dir        (type1[2:1]),
        .next_type  (next1),
        .fail       (fail1),
        .eu         (eu1),
        .ed         (ed1),
        .el         (el1),
        .er         (er1),
        .edrop      (edrop1),
        .overflow   (overflow1),
        .speedup    (speedup)
        );

    player player2(
        .rand       (timer[3:1]),
        .clk        (clk),
        .rstn       (reset&rstn),
        .start      (start),//游戏运行标志
        .up         (t>0 ? w1 : w2),//change ? w2 : w1
        .down       (t>0 ? s1 : s2),//change ? w2 : s1
        .left       (t>0 ? a1 : a2),//change ? w2 : a1
        .right      (t>0 ? d1 : d2),//change ? w2 : d1
        .x          (x2),
        .y          (y2),
        .refresh    (refresh2),
        .refresh_done (refresh_done2),
        .type       (type2[5:3]),
        .dir        (type2[2:1]),
        .next_type  (next2),
        .fail       (fail2),
        .eu         (eu2),
        .ed         (ed2),
        .el         (el2),
        .er         (er2),
        .edrop      (edrop2),
        .overflow   (overflow2),
        .speedup    (speedup)
    );


    wire hen,ven;
    DST DST(
        .pclk(pclk),
        .rstn(rstn),
        .hen(hen),
        .ven(ven),
        .hs(hs),
        .vs(vs)
    );

    DDP DDP(
        .ifstart(ifstart),
        .rstn(rstn),
        .pclk(pclk),
        .hen(hen),
        .ven(ven),
        .fail1(fail1),
        .fail2(fail2),
        .x11(x11),
        .x12(x12),
        .x13(x13),
        .x14(x14),
        .y11(y11),
        .y12(y12),
        .y13(y13),
        .y14(y14),
        .x21(x21),
        .x22(x22),
        .x23(x23),
        .x24(x24),
        .y21(y21),
        .y22(y22),
        .y23(y23),
        .y24(y24),
        .type1(type1),
        .next1(next1),
        .score1(score1),
        .score2(score2),
        .timer(timer),
        .type2(type2),
        .next2(next2),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .rgbb(rgb),
        .boom1 (cnt_boom1),
        .boom2 (cnt_boom2),
        .help  (help),
        .t     (t)
    );

    MUSIC MUSIC(
        .clk(clk),
        .start(start),
        .speedup(speedup),
        .rstn(reset&rstn),            
        .B(pwm)
    );
    
    // always @(*) begin
    //     next1<=3;
    //     next2<=7;
    //     type1<=5'b01000;
    //     type2<=5'b11000;
    //     score1<=8'h59;
    //     score2<=8'h13;
    //     rdata1<=0;
    //     if (raddr2>=100)rdata2<=3'b101; else rdata2<=0;
    // end

    // always @(posedge clk,negedge rstn) begin
    //     if(~rstn) begin x1<=0;y1<=0;x2<=0;y2<=0; end
    //     else begin 
    //         if(w1) y1<=y1-1;
    //         if(a1) x1<=x1-1;
    //         if(s1) y1<=y1+1;
    //         if(d1) x1<=x1+1;
    //         if(w2) y2<=y2-1;
    //         if(a2) x2<=x2-1;
    //         if(s2) y2<=y2+1;
    //         if(d2) x2<=x2+1;
    //     end
    // end
endmodule
