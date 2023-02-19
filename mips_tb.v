//`timescale 1ns/1ns

module mips_tb;
  
  wire [31:0] mem_adr, mem_in, mem_out, inst;
  wire mem_read, mem_write;
  reg clk, rst;
  
  mips_multi_cycle CPU(rst, clk, mem_adr, mem_in, mem_out, inst, mem_read, mem_write);
  
  memory MEM(mem_adr, mem_in, mem_read, mem_write, clk, mem_out);
  
  initial
  begin
    rst = 1'b1;
    clk = 1'b0;
    #5 rst = 1'b0;
    #2500 $stop;
  end
  
  always
  begin
    #2 clk = ~clk;
  end
  
endmodule
