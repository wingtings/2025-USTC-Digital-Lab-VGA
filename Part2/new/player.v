module player(
    input clk, rstn, start,
    input up, down, left, right,
    input refresh_done,//底部块消除完成标志
    input eu, ed, el, er, edrop, overflow,
    input [2:0]rand, speedup,
    output reg [4:0]x, y,//当前块坐标
    output reg [2:0]type,
    output reg [1:0]dir,
    output reg fail, refresh,//fail为失败信号，refresh控制RAM开始刷新，1有效，脉冲信号。
    output reg [2:0]next_type
);
    reg mode;//速降模式和普通模式
    // next_dir <= dir + 1;//后面得改，先用这个试试 
    reg [25:0]drop, fast_drop;
    reg [2:0]rspeedup;
    always @(posedge clk)begin
        fail <= fail;
        refresh <= 0;
        x <= x;
        y <= y;
        type <= type;
        dir <= dir;
        mode <= mode;
        drop<=drop;
        fast_drop<=fast_drop;
        rspeedup<=speedup;
        if(start)begin
            if(rspeedup!=speedup)begin
                drop<=1;
                fast_drop<=1;
            end
            else begin
                case(speedup)
                    0:begin
                    drop <= (drop == 50000000) ?0:(drop + 1);
                    fast_drop <= (fast_drop == 10000000) ?0:(fast_drop + 1);
                    end
                    1:begin
                    drop <= (drop == 30000000) ?0:(drop + 1);
                    fast_drop <= (fast_drop == 6000000) ?0:(fast_drop + 1);
                    end
                    2:begin
                    drop <= (drop == 5000000) ?0:(drop + 1);
                    fast_drop <= (fast_drop == 1000000) ?0:(fast_drop + 1);
                    end
                endcase
            end
        end
        if((mode) ? (~|fast_drop) : (~|drop))begin//mode为1：快速下落使能，mode为0，普通下落使能
            if(!edrop)begin//如果不能下落
                if(overflow)begin//如果溢出，则失败
                    fail <= 1;
                end
                else begin//如果未溢出，控制RAM刷新底部块
                    refresh <= 1;
                end
            end
            else begin//如果可以下落，则正常下落
                y <= y + 1;//正常下落
            end
        end
        else if(start)begin//只有未失败状态才可以操作
            if(refresh_done)begin//底部刷新完成
                x <= 3;
                y <= 0;
                type <= next_type;
                dir <= 0;
                mode <= 0;
                next_type <= rand % 7 + 1;
            end
            if(up & eu)begin
                dir <= dir + 1;
            end
            if(down & ed)begin
                mode <= ~mode;
            end
            if(left & el)begin
                x <= x - 1 ;
            end
            if(right & er)begin
                x <= x + 1;
            end
        end
    if(!rstn)begin
        refresh <= 0;
        fail <= 0;
        type <= 3;
        dir  <= 3;
        x <= 3;
        y <= 0;
        mode<=0;
        drop<=1;
        fast_drop<=1;
        next_type <= 5;
    end
    end
endmodule