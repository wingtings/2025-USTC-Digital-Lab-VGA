module Sound(
    input clk,
    input rstn,             
    input [2:0] sound_code,
    input play_sound,
    output reg B,
    output reg start
);

reg [2:0] current_sound_code;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        start <= 0;
        current_sound_code <= 0;
    end
    else if(play_sound) begin
        start <= 1;            // 收到脉冲，开始播放
        current_sound_code <= sound_code; // 锁存当前的音效代码
    end
    else if(state >= 24) begin      // 播放结束条件（对应你case的最大状态）
        start <= 0;
    end
end

reg [24:1]t;
reg [24:1]total;
reg clk_out;

always@(posedge clk,negedge rstn)
    if(~rstn) total<=3125000;
    // else if(speedup==1) total<=3125000;
    else total<=3125000;

always@(posedge clk,negedge rstn)
    if(~rstn) begin clk_out<=0;t<=total; end
    else if(t==0) begin clk_out<=~clk_out;t<=total; end
    else begin t<=t-1; end


reg [8:1]state;
always@(posedge clk_out,negedge rstn)         
    if(~rstn) state<=0;
    else if(start) 
        // if(state!=247)
        state<=state+1;
        // else state<=0;
    else state<=0;
 
reg [5:1]m; //音符
always@(*) //根据 sound_code 选择音符
    if(start && (current_sound_code == 3'd1) ) begin //选择音效
        case(state) 
        0	:m=13;
        1	:m=13;
        2	:m=13;
        3	:m=13;
        4	:m=13;
        5	:m=13;
        6	:m=13;
        7	:m=13;
                 
        8	:m=16;
        9	:m=16;
        10	:m=16;
        11	:m=16;
        12	:m=16;
        13	:m=16;
        14	:m=16;
        15	:m=16;
                 
        16	:m=16;
        17	:m=16;
        18	:m=16;
        19	:m=16;
        20	:m=16;
        21	:m=16;
        22	:m=16;
        23	:m=16;           
                 
        24	:m=0;
        default: m=0;
        endcase
    end
    else if(start && (current_sound_code == 3'd2) ) begin //取消选择
        case(state) 
        0	:m=13;
        1	:m=13;
        2	:m=13;
        3	:m=13;
        4	:m=13;
        5	:m=13;
        6	:m=13;
        7	:m=13;
                 
        8	:m=16;
        9	:m=16;
        10	:m=16;
        11	:m=16;
        12	:m=16;
        13	:m=16;
        14	:m=16;
        15	:m=16;
                 
        16	:m=16;
        17	:m=16;
        18	:m=16;
        19	:m=16;
        20	:m=16;
        21	:m=16;
        22	:m=16;
        23	:m=16;           
                 
        24	:m=0;
        default: m=0;
        endcase
    end
    else if (start && (current_sound_code == 3'd3) ) begin //移动音效
        case(state) 
        0	:m=13;
        1	:m=13;
        2	:m=13;
        3	:m=13;
        4	:m=13;
        5	:m=13;
        6	:m=13;
        7	:m=13;
                 
        8	:m=16;
        9	:m=16;
        10	:m=16;
        11	:m=16;
        12	:m=16;
        13	:m=16;
        14	:m=16;
        15	:m=16;
                 
        16	:m=16;
        17	:m=16;
        18	:m=16;
        19	:m=16;
        20	:m=16;
        21	:m=16;
        22	:m=16;
        23	:m=16;           
                 
        24	:m=0;
        default: m=0;
        endcase
    end
    else if (start && (current_sound_code == 3'd4) ) begin //吃子音效
        case(state) 
        0	:m=13;
        1	:m=13;
        2	:m=13;
        3	:m=13;
        4	:m=13;
        5	:m=13;
        6	:m=13;
        7	:m=13;
                 
        8	:m=16;
        9	:m=16;
        10	:m=16;
        11	:m=16;
        12	:m=16;
        13	:m=16;
        14	:m=16;
        15	:m=16;
                 
        16	:m=16;
        17	:m=16;
        18	:m=16;
        19	:m=16;
        20	:m=16;
        21	:m=16;
        22	:m=16;
        23	:m=16;           
                 
        24	:m=0;
        default: m=0;
        endcase
    end
    else if (start && (current_sound_code == 3'd5) ) begin //非法操作
        case(state) 
        0	:m=13;
        1	:m=13;
        2	:m=13;
        3	:m=13;
        4	:m=13;
        5	:m=13;
        6	:m=13;
        7	:m=13;
                 
        8	:m=16;
        9	:m=16;
        10	:m=16;
        11	:m=16;
        12	:m=16;
        13	:m=16;
        14	:m=16;
        15	:m=16;
                 
        16	:m=16;
        17	:m=16;
        18	:m=16;
        19	:m=16;
        20	:m=16;
        21	:m=16;
        22	:m=16;
        23	:m=16;           
                 
        24	:m=0;
        default: m=0;
        endcase
    end
    else if (start && (current_sound_code == 3'd6) ) begin //升变音效
        case(state) 
        0	:m=13;
        1	:m=13;
        2	:m=13;
        3	:m=13;
        4	:m=13;
        5	:m=13;
        6	:m=13;
        7	:m=13;
                 
        8	:m=16;
        9	:m=16;
        10	:m=16;
        11	:m=16;
        12	:m=16;
        13	:m=16;
        14	:m=16;
        15	:m=16;
                 
        16	:m=16;
        17	:m=16;
        18	:m=16;
        19	:m=16;
        20	:m=16;
        21	:m=16;
        22	:m=16;
        23	:m=16;           
                 
        24	:m=0;
        default: m=0;
        endcase
    end
    else if (start && (current_sound_code == 3'd7) ) begin //游戏结束音效
        case(state) 
        0	:m=13;
        1	:m=13;
        2	:m=13;
        3	:m=13;
        4	:m=13;
        5	:m=13;
        6	:m=13;
        7	:m=13;
                 
        8	:m=16;
        9	:m=16;
        10	:m=16;
        11	:m=16;
        12	:m=16;
        13	:m=16;
        14	:m=16;
        15	:m=16;
                 
        16	:m=16;
        17	:m=16;
        18	:m=16;
        19	:m=16;
        20	:m=16;
        21	:m=16;
        22	:m=16;
        23	:m=16;           
                 
        24	:m=0;
        default: m=0;
        endcase
    end
    else m=0;

reg [27:1]q;
always@(*)
    begin
        case(m)
        0 :q=0;
        1 :q=100000000/261 ; //261.6HZ 低do//10000000
        2 :q=100000000/293 ; //293.7HZ 低ri           
        3 :q=100000000/329 ; //329.6HZ 低mi 
        4 :q=100000000/349 ; //349.2HZ 低fa               
        5 :q=100000000/392 ; //392HZ 低so                  
        6 :q=100000000/440 ; //440HZ 低la              
        7 :q=100000000/499 ; //493.9HZ 低xi  
        8 :q=100000000/523 ; //523.3HZ中do
        9 :q=100000000/587 ; //587.3HZ 中ri          
        10:q=100000000/659 ; //659.3HZ 中mi        
        11:q=100000000/698 ; //698.5HZ 中fa
        12:q=100000000/784 ; //784HZ 中so      
        13:q=100000000/880 ; //880HZ 中la            
        14:q=100000000/998 ; //987.8HZ 中xi
        15:q=100000000/1046; //1045.4HZ 高do      
        16:q=100000000/1174; //1174.7HZ 高ri         
        17:q=100000000/1318; //1318.5HZ 高mi
        18:q=100000000/1396; //1396.3HZ 高fa         
        19:q=100000000/1568; //1568HZ 高so           
        20:q=100000000/1760; //1760HZ 高la              
        21:q=100000000/1976; //1975.5HZ 高xi  
        30:q=100000000/415;  //5.5
        31:q=100000000/831;  //12.5                  
        default:q=0;
        endcase    
    end
 
    reg [27:1]p;
    reg [27:1]tt;
    always@(posedge clk,negedge rstn)      
    begin
        if(~rstn) begin B<=0;p<=0; end
        else begin
            tt<=q;
            if(q==0||tt!=q)
            begin
                if(q==0) begin B<=0; end
                if(tt!=q) begin p<=0; end
            end
            else
            begin 
                if(p==q-1) p<=0;
                else p<=p+1;
                if(p==0) B<=1;
                if(p==q/256) B<=0;//占空比控制音量
            end
        end
    end 

endmodule