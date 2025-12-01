`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:23:48 PM
// Design Name: 
// Module Name: dff1_controller
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


module dff1_controller (
    input clk, reset, clr,  // clr = FlushE
    input en, // Enable
    input [0:0] d0,
    input [1:0] d1,
    input [0:0] d2,
    input [0:0] d3,
    input [0:0] d4,
    input [2:0] d5,
    input [0:0] d6,
    input       d7, // FPUStartD
    input [2:0] d8, // FPUControlD
    input       d9, // MatmulStartD
    output reg [0:0] q0,
    output reg [1:0] q1,
    output reg [0:0] q2,
    output reg [0:0] q3,
    output reg [0:0] q4,
    output reg [2:0] q5,
    output reg [0:0] q6,
    output reg      q7, // FPUStartE
    output reg [2:0] q8, // FPUControlE
    output reg      q9  // MatmulStartE
);
    always @(posedge clk or posedge reset) begin
        if (reset || clr) begin
             q0 <= 0;
             q1 <= 0;
             q2 <= 0;
             q3 <= 0;
             q4 <= 0;
             q5 <= 0;
             q6 <= 0;
             q7 <= 0;
             q8 <= 0;
             q9 <= 0;
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
             q9 <= d9;
        end
    end
endmodule