`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds(led_clk,ledrst,ledwrite,ledcs,ledaddr,ledwdata,ledout);
    input led_clk,ledrst;
    input ledwrite;
    input ledcs;            // ��memorio���ģ��ɵ�����λ�γɵ�LEDƬѡ�źţ���Ч˵����led����
    input[1:0] ledaddr;     // ��LEDģ��ĵ�ַ�Ͷ˾�����C60����C62
    input[15:0] ledwdata;   // д��LEDģ������ݣ�ע��������ֻ��16��
    output[23:0] ledout;    // ������������24λLED�ź�
    
    reg [23:0] ledout;
    
    always@(posedge led_clk or posedge ledrst) begin
        if(ledrst)
            ledout=24'h000000;
        else if(ledcs&&ledwrite) begin
            if(ledaddr==2'b00)  // 0xFFFFC60,24λ���ݵĵ�8λ���ݶ�Ӧ��ɫ��GLD,�ε�8λ���ݶ�Ӧ��ɫ��YLD
                ledout[15:0]=ledwdata;
            else if(ledaddr==2'b10) // 0xFFFFC62,24λ���ݵĸ�8λ���ݶ�Ӧ��ɫ��RLD
                ledout[23:16]=ledwdata[7:0];
        end
    end
endmodule
