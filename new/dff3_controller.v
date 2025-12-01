`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:32:34 PM
// Design Name: 
// Module Name: dff3_controller
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


module dff3_controller (
    input clk, reset,
    input [0:0] d0,
    input [1:0] d1,
    output reg [0:0] q0,
    output reg [1:0] q1
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q0 <= 1'b0;
            q1 <= 2'b0;
        end else begin
            q0 <= d0;
            q1 <= d1;
        end
    end
endmodule
