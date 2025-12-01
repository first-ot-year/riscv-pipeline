`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:18:39 PM
// Design Name: 
// Module Name: regfile
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


module regfile(input  clk, 
               input  we3, 
               input  [ 4:0] a1, a2, a3, 
               input  [ 4:0] a4, // Read address 3
               input  [31:0] wd3, 
               output [31:0] rd1, rd2,
               output [31:0] rd3); // Read data 3

  reg [31:0] rf[31:0]; 

  // Inicializar registros a 0
  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1)
      rf[i] = 32'b0;
  end

  // write third port on FALLING edge of clock (A3/WD3/WE3)
  always @(negedge clk) begin 
    if (we3) rf[a3] <= wd3; 
  end
  
  // read ports combinationally
  assign rd1 = (a1 != 0) ? rf[a1] : 0; 
  assign rd2 = (a2 != 0) ? rf[a2] : 0; 
  assign rd3 = (a4 != 0) ? rf[a4] : 0;
endmodule
