module PS#(
        parameter  WIDTH = 1
)
(
        input             s,
        input             clk,
        output            p
);

// TODO:
reg  s_reg;
// 寄存输入信号，获取上一周期的值
always @(posedge clk) begin
        s_reg <= s;
end

// 下降沿检测逻辑：当前为低(0) 且 上一周期为高(1)
assign p = (~s) & s_reg;

endmodule