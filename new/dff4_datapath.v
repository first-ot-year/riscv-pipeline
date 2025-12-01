`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:33:15 PM
// Design Name: 
// Module Name: dff4_datapath
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


module dff4_datapath(
    input  wire        clk,
    input  wire        reset,
    input  wire        clr, // Flush input
    input  wire        en,  // Enable input (Stall)
    input  wire [31:0] d0,
    input  wire [31:0] d1,
    input  wire [31:0] d2,
    output reg  [31:0] q0,
    output reg  [31:0] q1,
    output reg  [31:0] q2
);
    always @(posedge clk or posedge reset) begin
        if (reset || clr) begin // Reset or Flush
            q0 <= 32'b0;
            q1 <= 32'b0;
            q2 <= 32'b0;
        end else if (en) begin // Solo actualiza si enable=1
            q0 <= d0;
            q1 <= d1;
            q2 <= d2;
        end
    end
endmodule
