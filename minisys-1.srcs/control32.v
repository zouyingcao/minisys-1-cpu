`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module control32(Opcode,Function_opcode,Alu_resultHigh,Jrn,RegDST,ALUSrc,MemIOtoReg,RegWrite,MemRead,MemWrite,IORead,IOWrite,Branch,nBranch,Jmp,Jal,I_format,Sftmd,ALUOp);
    input[5:0]   Opcode;            // 来自取指单元instruction[31..26]
    input[5:0]   Function_opcode;  	// r-form instructions[5..0]
    input[21:0]  Alu_resultHigh;    // 读操作需要从端口或存储器读数据到寄存器,LW和SW的真正地址为Alu_Result,Alu_resultHigh=Alu_result[31..10]
    output       Jrn;               // jr
    output       RegDST;            // 为1时选择rd为目标寄存器，为0时选择rt
    output       ALUSrc;            // 决定第二个操作数是寄存器还是立即数, I型指令(beq,bne除外)
    output       MemIOtoReg;        /// lw
    output       RegWrite;          // 写寄存器
    output       MemWrite;          /// sw且Alu_resultHigh不等于全1(全1表示IO）
    output       MemRead;           /// 存储器读
    output       IORead;            /// IO读
    output       IOWrite;           /// IO写
    output       Branch;            // beq
    output       nBranch;           // bne
    output       Jmp;               // j
    output       Jal;               // jal
    output       I_format;          // 001xxx的I型指令
    output       Sftmd;             // 移位指令:sll,srl,sra
    output[1:0]  ALUOp;             // lw,sw:00;beq,bne:01;r-format,I-format:10
     
    wire Jmp,I_format,Jal,Branch,nBranch;
    wire R_format,Lw,Sw;
    
    //R型指令:
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;    	//R型指令
    assign RegDST = R_format;                               //说明目标是rd，否则是rt
    assign Jrn = (Opcode==6'b000000 && Function_opcode==6'b001000)? 1'b1:1'b0;
    
    //I型指令:I_format+Branch+nBranch+Lw+Sw
    assign I_format = (Opcode[5:3]==3'b001)? 1'b1:1'b0;     //001xxx的I型指令
    assign Lw = (Opcode==6'b100011)? 1'b1:1'b0;             //lw指令
    assign Sw = (Opcode==6'b101011)? 1'b1:1'b0;             //sw指令
    assign Branch = (Opcode==6'b000100)? 1'b1:1'b0;         //beq指令
    assign nBranch = (Opcode==6'b000101)? 1'b1:1'b0;        //bne指令
    
    //J型指令
    assign Jmp = (Opcode==6'b000010)? 1'b1:1'b0;            //j指令
    assign Jal = (Opcode==6'b000011)? 1'b1:1'b0;            //jal指令
    
    assign RegWrite = (R_format&&!Jrn)||I_format||Lw||Jal;     
    assign MemWrite = Sw&&(Alu_resultHigh!=22'b1111111111111111111111);   ///
    assign MemRead = Lw&&(Alu_resultHigh!=22'b1111111111111111111111);    ///
    assign IOWrite = Sw&&(Alu_resultHigh==22'b1111111111111111111111);    ///
    assign IORead = Lw&&(Alu_resultHigh==22'b1111111111111111111111);     ///
    assign MemIOtoReg = Lw; // Opcode==6'b100011
    assign Sftmd = (Opcode==6'b000000)&&(Function_opcode[5:3]==3'b000);   ///
    assign ALUSrc = I_format||Lw||Sw;
    assign ALUOp = {(R_format||I_format),(Branch||nBranch)};
    
endmodule
