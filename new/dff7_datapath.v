`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:36:05 PM
// Design Name: 
// Module Name: dff7_datapath
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


module dff7_datapath(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] d0,
    input  wire [31:0] d1,
    input  wire [4:0]  d2,
    input  wire [31:0] d3,
    output reg  [31:0] q0,
    output reg  [31:0] q1,
    output reg  [4:0]  q2,
    output reg  [31:0] q3
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q0 <= 0;
            q1 <= 0;
            q2 <= 0;
            q3 <= 0;
        end else begin
            q0 <= d0;
            q1 <= d1;
            q2 <= d2;
            q3 <= d3;
        end
    end
endmodule
