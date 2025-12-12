module TIMER(
    input clk,rstn,start,ifstart,
    input [3:0]sw,
    output reg [16:1]timer
);
    reg [27:1]t;
    reg [10:1]timerr;
    always @ (posedge clk,negedge rstn) begin
        if(~rstn) begin timerr<=sw*60;t<=50000000; end
        else if(~ifstart)begin timerr<=sw*60;t<=50000000; end
        else if(start&&timerr!=0) begin
            if(t!=0) begin t<=t-1; end
            else begin timerr<=timerr-1;t<=50000000; end
        end
    end

    always @(*) begin
        timer[16:13]=timerr/600;
        timer[12:9]=(timerr/60)%10;
        timer[8:5]=(timerr%60)/10;
        timer[4:1]=(timerr%60)%10;
    end
endmodule