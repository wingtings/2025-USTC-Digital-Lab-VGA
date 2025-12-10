`timescale 1ns / 1ps

module DST(
    input pclk,rstn,
    output reg hen,ven,hs,vs
);
    reg [11:1]hsg;
    reg [10:1]vsg;
    always @ (posedge pclk,negedge rstn)
    begin
        if(!rstn) begin hsg<='d1039; vsg<='d665; end
        else if(!hsg&&!vsg) begin hsg<='d1039; vsg<='d665; end
        else if(!hsg) begin hsg<='d1039;vsg<=vsg-1'b1; end
        else begin hsg<=hsg-1'b1; end
    end


    always @ (*)begin
        if(hsg>919) begin hs=1;hen=0; end
        else if(hsg>855) begin hs=0;hen=0; end//855
        else if(hsg>55) begin hs=0;hen=1; end//55
        else begin hs=0;hen=0; end

        if(vsg>659) begin vs=1;ven=0; end
        else if(vsg>636) begin vs=0;ven=0; end//636
        else if(vsg>36) begin vs=0;ven=1; end//36
        else begin vs=0;ven=0; end
    end
endmodule
