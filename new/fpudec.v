`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 02:30:55 PM
// Design Name: 
// Module Name: fpudec
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


module fpudec(input [6:0] funct7,
              input [6:0] op,
              output reg [2:0] FPUControl,
              output reg FPUStart,
              output reg MatmulStart);

  always @* begin
    FPUStart = 0;
    FPUControl = 3'b000;
    MatmulStart = 0;
    if (op == 7'b1010011) begin // OP-FP
      FPUStart = 1;
      case (funct7)
        7'b0000000: FPUControl = 3'b000; // FADD
        7'b0000100: FPUControl = 3'b001; // FSUB
        7'b0001000: FPUControl = 3'b010; // FMUL
        7'b0001100: FPUControl = 3'b011; // FDIV
        7'b0010000: begin // MATMUL.FP
            FPUStart = 0; // Matmul unit handles FPU
            MatmulStart = 1;
        end
        default:    FPUStart = 0;
      endcase
    end
  end
endmodule