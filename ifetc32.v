`timescale 1ns / 1ps
////////////////////////////////////////取指单元//////////////////////////////////////

module Ifetc32(Instruction,PC_plus_4_out,Add_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jrn,Zero,clock,reset,opcplus4);
    output[31:0] Instruction;			// 输出指令
    output[31:0] PC_plus_4_out;         // PC+4的结果输出,送入加法器
    input[31:0]  Add_result;            // 加法器中算出的跳转地址(已右移两位),beq,bne
    input[31:0]  Read_data_1;           // 寄存器组中读出的跳转地址，jr:(PC)←(rs)
    input        Branch;                // beq
    input        nBranch;               // bne
    input        Jmp;                   // j
    input        Jal;                   // jal
    input        Jrn;                   // jr
    input        Zero;                  // 是否相等
    input        clock,reset;           // PC&程序ROM的clock
    output[31:0] opcplus4;              // jal指令专用的PC+4,送入数据选择器-7

    
    wire[31:0]   PC_plus_4;             // PC+4
    reg[31:0]	  PC;                    // PC寄存器内容
    reg[31:0]    next_PC;               // 下一条指令的PC,以4字节为单位，1，2，3，...
    wire[31:0]   Jpadr;                 // ROM取出的内容即指令
    reg[31:0]    opcplus4;
    
   //分配64KB ROM，编译器实际只用 64KB ROM，程序ROM用于取指令
    prgrom instmem(
        .clka(clock),         // input wire clka
        .addra(PC[15:2]),     // input wire [13 : 0] addra
        .douta(Jpadr)         // output wire [31 : 0] douta
    );

    assign Instruction = Jpadr;              // 取出指令
    assign PC_plus_4 = {PC[31:2] + 1,2'b00}; // PC+4
    assign PC_plus_4_out = PC_plus_4;
    
    always @* begin                                 // beq $n ,$m if $n=$m branch   bne if $n /=$m branch jr
        if(Jrn) next_PC = Read_data_1;              // jr
        else if((Branch&&Zero)||(nBranch&&!Zero))   // beq || bne
            next_PC = Add_result;
        else next_PC = {2'b00,PC_plus_4[31:2]};     // 一般情况
    end
    
   always @(negedge clock) begin                    // 时钟下降沿更改PC
     if(reset) PC = 32'h00000000;
     else if(Jmp||Jal) begin                        // j || jal
        if(Jal)opcplus4 = {2'b00,PC_plus_4[31:2]};  // PC+4，用于jal，$31=PC+4，右移两位以存入寄存器
        PC = {4'b0000,Instruction[27:0]<<2};        // (Zero-Extend)address<<2，先左移再零扩展
        end
     else PC = next_PC<<2;
   end
endmodule
