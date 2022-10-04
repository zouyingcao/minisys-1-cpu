`timescale 1ns / 1ps
////////////////////////////////////////ȡָ��Ԫ//////////////////////////////////////

module Ifetc32(Instruction,PC_plus_4_out,Add_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jrn,Zero,clock,reset,opcplus4);
    output[31:0] Instruction;			// ���ָ��
    output[31:0] PC_plus_4_out;         // PC+4�Ľ�����,����ӷ���
    input[31:0]  Add_result;            // �ӷ������������ת��ַ(��������λ),beq,bne
    input[31:0]  Read_data_1;           // �Ĵ������ж�������ת��ַ��jr:(PC)��(rs)
    input        Branch;                // beq
    input        nBranch;               // bne
    input        Jmp;                   // j
    input        Jal;                   // jal
    input        Jrn;                   // jr
    input        Zero;                  // �Ƿ����
    input        clock,reset;           // PC&����ROM��clock
    output[31:0] opcplus4;              // jalָ��ר�õ�PC+4,��������ѡ����-7

    
    wire[31:0]   PC_plus_4;             // PC+4
    reg[31:0]	  PC;                    // PC�Ĵ�������
    reg[31:0]    next_PC;               // ��һ��ָ���PC,��4�ֽ�Ϊ��λ��1��2��3��...
    wire[31:0]   Jpadr;                 // ROMȡ�������ݼ�ָ��
    reg[31:0]    opcplus4;
    
   //����64KB ROM��������ʵ��ֻ�� 64KB ROM������ROM����ȡָ��
    prgrom instmem(
        .clka(clock),         // input wire clka
        .addra(PC[15:2]),     // input wire [13 : 0] addra
        .douta(Jpadr)         // output wire [31 : 0] douta
    );

    assign Instruction = Jpadr;              // ȡ��ָ��
    assign PC_plus_4 = {PC[31:2] + 1,2'b00}; // PC+4
    assign PC_plus_4_out = PC_plus_4;
    
    always @* begin                                 // beq $n ,$m if $n=$m branch   bne if $n /=$m branch jr
        if(Jrn) next_PC = Read_data_1;              // jr
        else if((Branch&&Zero)||(nBranch&&!Zero))   // beq || bne
            next_PC = Add_result;
        else next_PC = {2'b00,PC_plus_4[31:2]};     // һ�����
    end
    
   always @(negedge clock) begin                    // ʱ���½��ظ���PC
     if(reset) PC = 32'h00000000;
     else if(Jmp||Jal) begin                        // j || jal
        if(Jal)opcplus4 = {2'b00,PC_plus_4[31:2]};  // PC+4������jal��$31=PC+4��������λ�Դ���Ĵ���
        PC = {4'b0000,Instruction[27:0]<<2};        // (Zero-Extend)address<<2��������������չ
        end
     else PC = next_PC<<2;
   end
endmodule
