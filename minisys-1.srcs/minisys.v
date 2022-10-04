`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module minisys(prst,pclk,led2N4,switch2N4);
    input prst;               //板上的Reset信号，低电平复位
    input pclk;               //板上的100MHz时钟信号
    input[23:0] switch2N4;    //拨码开关输入
    output[23:0] led2N4;      //led结果输出到Nexys4数码管
    
    wire clock;              //clock: 分频后时钟供给系统
    wire iowrite,ioread;     //I/O读写信号
    wire[31:0] write_data;   //写RAM或IO的数据
    wire[31:0] read_data;        //读RAM或IO的数据
    wire[15:0] ioread_data;  //读IO的数据
    wire[31:0] pc_plus_4;    //PC+4
    wire[31:0] read_data_1;  //译码单元读出的数据1
    wire[31:0] read_data_2;  //译码单元读出的数据2
    wire[31:0] sign_extend;  //符号扩展
    wire[31:0] add_result;   //
    wire[31:0] alu_result;   //
    wire[31:0] mread_data;    //RAM中读取的数据
    wire[31:0] address;
    wire alusrc;
    wire branch;
    wire nbranch,jmp,jal,jrn,i_format;
    wire regdst;
    wire regwrite;
    wire zero;
    wire memwrite;
    wire memread;
    wire memoriotoreg;
    wire memreg;
    wire sftmd;
    wire[1:0] aluop;
    wire[31:0] instruction;
    wire[31:0] opcplus4;
    wire ledctrl,switchctrl;
    wire[15:0] ioread_data_switch;
    
    cpuclk cpuclk(
        .clk_in1(pclk),    //100MHz
        .clk_out1(clock)    //cpuclock,23MHz
    );
    
    Ifetc32 ifetch(
        .Instruction(instruction),
        .PC_plus_4_out(pc_plus_4),
        .Add_result(add_result),
        .Read_data_1(read_data_1),
        .Branch(branch),
        .nBranch(nbranch),
        .Jmp(jmp),
        .Jal(jal),
        .Jrn(jrn),
        .Zero(zero),
        .clock(clock),
        .reset(!prst),
        .opcplus4(opcplus4)
    );
    
    Idecode32 idecode(
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .Instruction(instruction),
        .read_data(read_data),////从DATA RAM or I/O port取出的数据
        .ALU_result(alu_result),
        .Jal(jal),
        .RegWrite(regwrite),
        .MemIOtoReg(memoriotoreg),
        .RegDst(regdst),
        .Sign_extend(sign_extend),
        .clock(clock),
        .reset(!prst),
        .opcplus4(opcplus4)
        //.read_register_1_address(instruction[25:21])//rs
    );
    
    control32 control(
        .Opcode(instruction[31:26]),
        .Function_opcode(instruction[5:0]),
        .Alu_resultHigh(alu_result[31:10]),
        .Jrn(jrn),
        .RegDST(regdst),
        .ALUSrc(alusrc),
        .MemIOtoReg(memoriotoreg),
        .RegWrite(regwrite),
        .MemRead(memread),
        .MemWrite(memwrite),
        .IORead(ioread),
        .IOWrite(iowrite),
        .Branch(branch),
        .nBranch(nbranch),
        .Jmp(jmp),
        .Jal(jal),
        .I_format(i_format),
        .Sftmd(sftmd),
        .ALUOp(aluop)
    );
                      
    Executs32 execute(
       .Read_data_1(read_data_1),
       .Read_data_2(read_data_2),
       .Sign_extend(sign_extend),
       .Function_opcode(instruction[5:0]),// func
       .Exe_opcode(instruction[31:26]),//op code
       .ALUOp(aluop),
       .Shamt(instruction[10:6]),
       .ALUSrc(alusrc),
       .I_format(i_format),
       .Zero(zero),
       .Sftmd(sftmd),
       .ALU_Result(alu_result),
       .Add_Result(add_result),
       .PC_plus_4(pc_plus_4)
     );
    
    memorio memio(//IO MEM统一编址
        .caddress(alu_result),// from alu_result in executs32
        .address(address),//output, address to DMEM
        .memread(memread),// read memory, from control32
        .memwrite(memwrite),// write memory, from control32
        .ioread(ioread),// read IO, from control32
        .iowrite(iowrite),// write IO, from control32
        .mread_data(mread_data),// data from memory
        .ioread_data(ioread_data),// data from io
        .wdata(read_data_2),// the data from idecode32,that want to write memory or io
        .rdata(read_data),// ouput,mread_data与ioread_data选其一
        .write_data(write_data),// output,data to memory or I/O，wdata（memwrite||iowrite有效）
        .LEDCtrl(ledctrl),
        .SwitchCtrl(switchctrl)
    );
    
    dmemory32 memory(                   //数据RAM
      .read_data(mread_data),           //RAM读出
      .address(address),
      .write_data(write_data),
      .Memwrite(memwrite),
      .clock(clock)
    );      
    
    ioread multiioread(
        .reset(!prst),///
        .clk(clock),///
        .ior(ioread),
        .switchctrl(switchctrl),
        .ioread_data(ioread_data),//output
        .ioread_data_switch(ioread_data_switch)//input
    );
 
    leds led16(
        .led_clk(clock),
        .ledrst(!prst),////
        .ledwrite(ledctrl),
        .ledcs(ledctrl),
        .ledaddr(address[1:0]),
        .ledwdata(write_data[15:0]),
        .ledout(led2N4)//output
     );
     
     switchs switch16(
        .switclk(clock),
        .switrst(!prst),///
        .switchread(switchctrl),
        .switchaddr(address[1:0]),
        .switchcs(switchctrl),
        .switchrdata(ioread_data_switch),//output
        .switch_i(switch2N4)//input
     );
endmodule
