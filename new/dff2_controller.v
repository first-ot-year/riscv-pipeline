`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:32:04 PM
// Design Name: 
// Module Name: dff2_controller
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


module dff2_controller (
    input clk, reset,
    input [0:0] d0,
    input [1:0] d1,
    input [0:0] d2,
    output reg [0:0] q0,
    output reg [1:0] q1,
    output reg [0:0] q2
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q0 <= 1'b0;
            q1 <= 2'b0;
            q2 <= 1'b0;
        end else begin
            q0 <= d0;
            q1 <= d1;
            q2 <= d2;
        end
    end
endmodule
