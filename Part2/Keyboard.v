module Keyboard(input clk_100mhz,   // 100 Mz时钟输入
                input rst_n,    // 低电平有效复位信号
                input ps2_c,    // PS2_CLK 时钟信号
                input ps2_d,    // PS2_DATA 数据信号
                output reg [10:0] key_event);

    reg [3:0] ps2_c_filter, ps2_d_filter;   // 去抖动寄存器
    reg ps2_c_f, ps2_d_f;   // 去抖后的信号

    reg [10:1] buffer;  // 数据缓冲寄存器
    reg [3:0] counter;  // 数据位寄存器

    always @(posedge clk_100mhz or negedge rst_n) begin//去抖动
        if (~rst_n) begin   // 复位, 将所有寄存器全部设为 1
            ps2_c_filter <= 4'b1111;
            ps2_d_filter <= 4'b1111;
            ps2_c_f <= 1;
            ps2_d_f <= 1;
        end else begin  // 正常工作, 即滤波过程
            ps2_c_filter <= {ps2_c, ps2_c_filter[3:1]};
            ps2_d_filter <= {ps2_d, ps2_d_filter[3:1]};
            if (ps2_c_filter == 4'b1111)
                ps2_c_f <= 1;
            else if (ps2_c_filter == 4'b0000)
                ps2_c_f <= 0;
            if (ps2_d_filter == 4'b1111)
                ps2_d_f <= 1;
            else if (ps2_d_filter == 4'b0000)
                ps2_d_f <= 0;
        end
    end

    always @(negedge ps2_c_f or negedge rst_n) begin//时钟下降沿，表示正在传输数据
        if (~rst_n) begin
            buffer <= 10'b0;
            counter <= 4'b0;
            key_event <= 11'b0;
        end else begin
            key_event[7:0] <= buffer[9:2];//key_event[7:0]表示当前按键
            buffer <= {ps2_d_f, buffer[10:2]};//后读入的为高位
            if (counter == 10) begin//buffer为10位数据
                // if (buffer[20:13] != 8'b11110000) begin//
                if(^buffer[9:2]==~buffer[10])//检验奇偶
                    if (buffer[9:2] == 8'b11110000) begin//F0代表按键松开
                        key_event[8] <= 1;//key_event[8]==1代表松开该按键
                    end 
                    else if (buffer[9:2] == 8'b11100000) begin//E0代表功能按键
                        key_event[9] <= 1;//key_event[9]==1代表功能按键
                    end
                    else begin
                        key_event[10] <= 1;//key_event[10]==1代表当前数据有效
                    end
                counter <= 0;
            end
            else begin
                counter <= counter + 1;
                if(key_event[10]) begin
                key_event[8] <= 0;
                key_event[9] <= 0;
                key_event[10] <= 0;
                end
            end
        end
    end

endmodule