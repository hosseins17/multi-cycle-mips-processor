`define IF  4'b0000
`define ID  4'b0001
`define J   4'b0010
`define BEQ 4'b0011
`define RT1 4'b0100
`define RT2 4'b0101
`define M1  4'b0110
`define M2  4'b0111
`define M3  4'b1000
`define M4  4'b1001
`define JAL 4'b1010
`define AI  4'b1011
`define WI  4'b1100
`define SI  4'b1101
`define JR  4'b1110 

module controller ( clk, rst, opcode, func, zero, reg_dst, mem_to_reg, reg_write, 
                    alu_srcA, alu_srcB, mem_read, mem_write, pc_src, operation,
		    reg_dst2, data_write, IorD, ir_write, pc_load
                  );
                    
    input [5:0] opcode;
    input [5:0] func;
    input clk, rst, zero;
    output  reg_dst, mem_to_reg, reg_write, alu_srcA, 
            mem_read, mem_write, reg_dst2,
            data_write, IorD, ir_write, pc_load;
    reg     reg_dst, mem_to_reg, reg_write, 
            alu_srcA, mem_read, mem_write,
	    reg_dst2, data_write, IorD, ir_write; 
    output [1:0] pc_src;
    reg [1:0] pc_src;
    output [1:0] alu_srcB;
    reg [1:0] alu_srcB;
    output [2:0] operation;
  //reg [2:0] operation;          
    reg [1:0] alu_op;    
    reg pc_write, pc_write_cond; 
    //reg branch;   
    reg [3:0] ps, ns;
    alu_controller ALU_CTRL(alu_op, func, operation);
    
    always @(posedge clk, posedge rst) begin
    	if(rst) ps <= `IF;
    	else ps <= ns;
    end

    always @(ps, opcode) begin
	case(ps)
		`IF : ns = `ID;
		`ID : begin
		     case(opcode)
			6'b000000 : ns = `RT1;   //RType
			6'b100011 : ns = `M1;    // lw
			6'b101011 : ns = `M1;    // sw
			6'b000100 : ns = `BEQ;   // beq
			6'b001001 : ns = `AI;    //addi
			6'b001010 : ns = `SI;    //slti
			6'b000010 : ns = `J;     //j
			6'b000011 : ns = `JAL;   //jal
			6'b000110 : ns = `JR;    //jr
		     endcase
		 end
		`J : ns = `IF;
		`BEQ : ns = `IF;
		`RT1 : ns = `RT2;
		`RT2 : ns = `IF;
		`M1 : begin
		     case(opcode)
			6'b101011 : ns = `M2;  //sw
			6'b100011 : ns = `M3;  //lw
		     endcase
		end
		`M2 : ns = `IF;
		`M3 : ns = `M4;
		`M4 : ns = `IF;
		`JAL : ns = `IF;
		`AI : ns = `WI;
		`SI : ns = `WI;
		`WI : ns = `IF;
		`JR : ns = `IF;
		default : ns = `IF;
	endcase

    end

    always @(ps) begin
	{IorD, mem_read, mem_write, ir_write, reg_dst, mem_to_reg, reg_write,
	 alu_srcA, alu_srcB, alu_op, pc_write, pc_write_cond, reg_dst2, 
         data_write, pc_src} = 18'd0;
	case(ps)
		`IF : {mem_read, ir_write, pc_write, alu_srcB} = 5'b11101;
		`ID : alu_srcB = 2'b11;
		`J : {pc_write, pc_src} = 3'b101;
		`BEQ : {alu_srcA , pc_write_cond, alu_op, pc_src} = 6'b110110;
		`RT1 : {alu_srcA, alu_op} = 3'b110;
		`RT2 : {reg_dst, reg_write} = 2'b11;
		`M1 : {alu_srcA, alu_srcB} = 3'b110;
		`M2 : {IorD, mem_write} = 2'b11;
		`M3 : {IorD, mem_read} = 2'b11;
		`M4 : {mem_to_reg, reg_write} = 2'b11;
		`JAL : {reg_write, pc_write, reg_dst2, data_write, pc_src} = 6'b111101;
		`AI : {alu_srcA, alu_srcB} = 3'b110;
		`WI : reg_write = 1'b1;
		`SI : {alu_srcA, alu_srcB, alu_op} = 5'b11011;
		`JR : {alu_srcA, pc_write, pc_src} = 4'b11;
	endcase
    end
    
    assign pc_load = pc_write | ( pc_write_cond & zero);

endmodule
