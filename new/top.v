`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 01:53:58 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// ============================================================================
// MÓDULO TOP - Nivel Superior
// ============================================================================
module top(input  clk, reset, 
           output [31:0] WriteDataM, DataAdrM, 
           output MemWriteM);
  
  wire [31:0] PCF, InstrF, ReadDataM; 
  
  // instantiate processor and memories
  riscvpipe rvpipeline(
    .clk(clk), 
    .reset(reset), 
    .PCF(PCF), 
    .InstrF(InstrF), 
    .MemWriteM(MemWriteM), 
    .DataAdrM(DataAdrM), 
    .WriteDataM(WriteDataM), 
    .ReadDataM(ReadDataM)
  ); 

  imem imem(
    .a(PCF), 
    .rd(InstrF)
  ); 

  dmem dmem(
    .clk(clk), 
    .we(MemWriteM), 
    .a(DataAdrM),    
    .wd(WriteDataM), 
    .rd(ReadDataM) // output
  ); 
endmodule
