module datapath ( clk, rst, mem_adr, mem_in, mem_out, IorD, ir_write, inst,
                  reg_dst, mem_to_reg, alu_srcA, alu_srcB, pc_src, alu_ctrl, reg_write,
                  zero, reg_dst2, data_write, pc_load//, pc_write, pc_write_cond
                 );
  input  clk, rst;
  output [31:0] mem_adr;
  output [31:0] mem_in;
  input  [31:0] mem_out;
  output [31:0] inst;
  input  IorD, ir_write, reg_dst, mem_to_reg, alu_srcA, reg_write, reg_dst2, data_write, pc_load;
 // input pc_write, pc_write_cond;
  input  [1:0] alu_srcB;
  input  [2:0] alu_ctrl;
  input  [1:0] pc_src;
  output zero;

  //wire [31:0] inst;
  wire [31:0] pc_out;
  wire [31:0] adder1_out;
  wire [31:0] read_data1, read_data2;
  wire [31:0] sgn_ext_out;
  wire [31:0] mux1_out;
  wire [4:0] mux2_out;
  wire [31:0] alu_out;
  wire [31:0] adder2_out;
  wire [31:0] shl2_out;
  wire [31:0] mux3_out;
  wire [4:0] mux4_out;
  wire [31:0] mux5_out;
  wire [31:0] mux6_out;
  wire [31:0] mux7_out;
  wire [31:0] mux8_out;
  wire [31:0] shl2_2_out;
  wire [31:0] mdr_out;
  wire [31:0] regA_out;
  wire [31:0] regB_out;
  wire [31:0] aluReg_out;  

  //assign pc_load = pc_write | ( pc_write_cond & zero);
  reg_32b PC(mux8_out, rst, pc_load, clk, pc_out);

  mux2to1_32b MUX_1(pc_out, aluReg_out, IorD, mux1_out);

 // memory MEM(mux1_out, regB_out, mem_read, mem_write, clk, mem_out);

  reg_32b IR(mem_out, rst, ir_write, clk, inst);

  reg_32b MDR(mem_out, rst, 1'b1, clk, mdr_out);

  mux2to1_5b MUX_2(inst[20:16], inst[15:11], reg_dst, mux2_out);

  mux2to1_32b MUX_3(aluReg_out, mdr_out, mem_to_reg, mux3_out);

  mux2to1_5b MUX_4(mux2_out, 5'd31, reg_dst2, mux4_out);

  mux2to1_32b MUX_5(mux3_out, pc_out, data_write, mux5_out);

  reg_file  RF(mux5_out, inst[25:21], inst[20:16], mux4_out, reg_write, rst, clk, read_data1, read_data2);

  sign_ext SGN_EXT(inst[15:0], sgn_ext_out);

  reg_32b regA(read_data1, rst, 1'b1, clk, regA_out);

  reg_32b regB(read_data2, rst, 1'b1, clk, regB_out);

  shl2 SHL2(sgn_ext_out, shl2_out);

  mux2to1_32b MUX_6(pc_out, regA_out, alu_srcA, mux6_out);

  mux4to1_32b MUX_7(regB_out, 32'd4, sgn_ext_out, shl2_out, alu_srcB, mux7_out);

  alu ALU(mux6_out, mux7_out, alu_ctrl, alu_out, zero);

  reg_32b ALUOUT(alu_out, rst, 1'b1, clk, aluReg_out);

  mux4to1_32b MUX_8(alu_out, shl2_2_out, aluReg_out, mux6_out, pc_src, mux8_out);

  assign mem_adr = mux1_out;
  assign mem_in = regB_out;
  assign shl2_2_out = {pc_out[31:28], inst[25:0], 2'b00};
endmodule
