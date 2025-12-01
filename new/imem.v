`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:19:40 PM
// Design Name: 
// Module Name: imem
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

module imem(input  [31:0] a,
            output [31:0] rd);
  
  reg [31:0] RAM[0:63];  // Corregido: índice ascendente para readmemh 

  initial begin
      //$readmemh("riscvtest.mem",RAM); 
      $readmemh("matmul_test.mem",RAM); 
  end

  assign rd = RAM[a[31:2]]; // word aligned
endmodule
