`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds(led_clk,ledrst,ledwrite,ledcs,ledaddr,ledwdata,ledout);
    input led_clk,ledrst;
    input ledwrite;
    input ledcs;            // 从memorio来的，由低至高位形成的LED片选信号，有效说明对led操作
    input[1:0] ledaddr;     // 到LED模块的地址低端决定是C60还是C62
    input[15:0] ledwdata;   // 写到LED模块的数据，注意数据线只有16根
    output[23:0] ledout;    // 向板子上输出的24位LED信号
    
    reg [23:0] ledout;
    
    always@(posedge led_clk or posedge ledrst) begin
        if(ledrst)
            ledout=24'h000000;
        else if(ledcs&&ledwrite) begin
            if(ledaddr==2'b00)  // 0xFFFFC60,24位数据的低8位数据对应绿色的GLD,次低8位数据对应黄色的YLD
                ledout[15:0]=ledwdata;
            else if(ledaddr==2'b10) // 0xFFFFC62,24位数据的高8位数据对应红色的RLD
                ledout[23:16]=ledwdata[7:0];
        end
    end
endmodule
