module mips_multi_cycle (rst, clk, mem_adr, mem_in, mem_out, inst, mem_read, mem_write);
  input rst, clk;
  output [31:0] mem_adr;
  //input  [31:0] inst;
  output  [31:0] mem_in;
  input [31:0] mem_out;
  output [31:0] inst;
  output mem_read, mem_write;
  
  wire IorD, ir_write, reg_dst, mem_to_reg, alu_srcA, 
       reg_write, zero, reg_dst2, data_write, pc_load;
  wire [1:0] alu_srcB;
  wire [1:0] pc_src;
  wire [2:0] alu_ctrl;
  
  datapath DP(  clk, rst, mem_adr, mem_in, mem_out, IorD, ir_write, inst, 
                reg_dst, mem_to_reg, alu_srcA, alu_srcB, pc_src, alu_ctrl, reg_write,
                zero, reg_dst2, data_write, pc_load
            );
            
  controller CU(  clk, rst, inst[31:26], inst[5:0], zero, reg_dst, mem_to_reg, reg_write, 
                  alu_srcA, alu_srcB, mem_read, mem_write, pc_src, alu_ctrl, reg_dst2,
                  data_write, IorD, ir_write, pc_load
                );
  
endmodule
