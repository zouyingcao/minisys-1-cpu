`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module control32(Opcode,Function_opcode,Alu_resultHigh,Jrn,RegDST,ALUSrc,MemIOtoReg,RegWrite,MemRead,MemWrite,IORead,IOWrite,Branch,nBranch,Jmp,Jal,I_format,Sftmd,ALUOp);
    input[5:0]   Opcode;            // ����ȡָ��Ԫinstruction[31..26]
    input[5:0]   Function_opcode;  	// r-form instructions[5..0]
    input[21:0]  Alu_resultHigh;    // ��������Ҫ�Ӷ˿ڻ�洢�������ݵ��Ĵ���,LW��SW��������ַΪAlu_Result,Alu_resultHigh=Alu_result[31..10]
    output       Jrn;               // jr
    output       RegDST;            // Ϊ1ʱѡ��rdΪĿ��Ĵ�����Ϊ0ʱѡ��rt
    output       ALUSrc;            // �����ڶ����������ǼĴ�������������, I��ָ��(beq,bne����)
    output       MemIOtoReg;        /// lw
    output       RegWrite;          // д�Ĵ���
    output       MemWrite;          /// sw��Alu_resultHigh������ȫ1(ȫ1��ʾIO��
    output       MemRead;           /// �洢����
    output       IORead;            /// IO��
    output       IOWrite;           /// IOд
    output       Branch;            // beq
    output       nBranch;           // bne
    output       Jmp;               // j
    output       Jal;               // jal
    output       I_format;          // 001xxx��I��ָ��
    output       Sftmd;             // ��λָ��:sll,srl,sra
    output[1:0]  ALUOp;             // lw,sw:00;beq,bne:01;r-format,I-format:10
     
    wire Jmp,I_format,Jal,Branch,nBranch;
    wire R_format,Lw,Sw;
    
    //R��ָ��:
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;    	//R��ָ��
    assign RegDST = R_format;                               //˵��Ŀ����rd��������rt
    assign Jrn = (Opcode==6'b000000 && Function_opcode==6'b001000)? 1'b1:1'b0;
    
    //I��ָ��:I_format+Branch+nBranch+Lw+Sw
    assign I_format = (Opcode[5:3]==3'b001)? 1'b1:1'b0;     //001xxx��I��ָ��
    assign Lw = (Opcode==6'b100011)? 1'b1:1'b0;             //lwָ��
    assign Sw = (Opcode==6'b101011)? 1'b1:1'b0;             //swָ��
    assign Branch = (Opcode==6'b000100)? 1'b1:1'b0;         //beqָ��
    assign nBranch = (Opcode==6'b000101)? 1'b1:1'b0;        //bneָ��
    
    //J��ָ��
    assign Jmp = (Opcode==6'b000010)? 1'b1:1'b0;            //jָ��
    assign Jal = (Opcode==6'b000011)? 1'b1:1'b0;            //jalָ��
    
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