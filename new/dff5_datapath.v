`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:34:41 PM
// Design Name: 
// Module Name: dff5_datapath
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


module dff5_datapath(
    input  wire        clk,
    input  wire        reset,
    input  wire        en, // Enable input
    input  wire [31:0] d0,
    input  wire [31:0] d1,
    input  wire [31:0] d2,
    input  wire [4:0]  d3,
    input  wire [31:0] d4,
    input  wire [31:0] d5,
    // RS1D y RS2D
    input wire [4:0] d6,
    input wire [4:0] d7,
    input wire [31:0] d8, // RD3
    output reg  [31:0] q0,
    output reg  [31:0] q1,
    output reg  [31:0] q2,
    output reg  [4:0]  q3,
    output reg  [31:0] q4,
    output reg  [31:0] q5,
      // RS1D y RS2D
      output reg  [4:0] q6,
       output reg  [4:0] q7,
       output reg  [31:0] q8 // RD3
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q0 <= 0;
            q1 <= 0;
            q2 <= 0;
            q3 <= 0;
            q4 <= 0;
            q5 <= 0;
            q6<=0;
            q7<=0;
            q8<=0;
        end else if (en) begin
            q0 <= d0;
            q1 <= d1;
            q2 <= d2;
            q3 <= d3;
            q4 <= d4;
            q5 <= d5;
            q6 <= d6;
            q7 <= d7;
            q8 <= d8;
        end
    end
endmodule