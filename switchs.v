`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module switchs(switclk,switrst,switchread,switchaddr,switchcs,switchrdata,switch_i);
    input switclk,switrst;
    input switchcs,switchread;
    input[1:0] switchaddr;
    output [15:0] switchrdata;
    //拨码开关输入
    input [23:0] switch_i;

    reg [23:0] switchrdata;
    always@(negedge switclk or posedge switrst) begin
        if(switrst)
            switchrdata=24'h000000;
        else if(switchcs&&switchread) begin
            if(switchaddr==2'b00)  
                switchrdata[15:0]=switch_i;
            else if(switchaddr==2'b10) // 0xFFFFC62,24位数据的高8位数据对应红色的RLD
                switchrdata[15:0]={8'd0,switch_i[23:16]};
        end    
    end
endmodule
