`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:22:13 PM
// Design Name: 
// Module Name: flopr
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


module flopr #(parameter WIDTH = 32)
             (input  clk, reset,
              input  en,              // NUEVO puerto
              input  [WIDTH-1:0] d,
              output reg [WIDTH-1:0] q);

  always @(posedge clk or posedge reset) begin
    if (reset) 
      q <= 0;                        // PC = 0 durante reset
    else if (en)                     // Solo actualiza si enable=1
      q <= d;
    // Si en=0, mantiene el valor
  end
endmodule