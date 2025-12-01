`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 03:54:49 PM
// Design Name: 
// Module Name: hazard_unit
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


module hazard_unit(input [4:0] Rs1E,
                   input  [4:0] Rs2E,
                   input [4:0] RdM,
		   input [4:0] RdW,
		   input RegWriteM,
                    input RegWriteW,
                    input [4:0] Rs1D, Rs2D, RdE,
                    input [1:0] ResultSrcE,  // Corregido a [1:0]
                    input PCSrcE,  // Para detectar branch/jump
                   output reg [1:0] ForwardAE,
                   output reg [1:0] ForwardBE,
                   
                   // STALLS y FLUSHES
                    input MatmulBusy, // NUEVO
                   output StallF, StallD,
                   output FlushD, FlushE  // Cambiado a wire (assign)

    );
   
    // Forwarding for A (rs1E)
    always @(*) begin
        if ((Rs1E == RdM) && RegWriteM && (Rs1E != 0))
            ForwardAE = 2'b10;
        else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 0))
            ForwardAE = 2'b01;
        else
            ForwardAE = 2'b00;
    end

    // Forwarding for B (rs2E)
    always @(*) begin
        if ((Rs2E == RdM) && RegWriteM && (Rs2E != 0))
            ForwardBE = 2'b10;
        else if ((Rs2E == RdW) && RegWriteW && (Rs2E != 0))
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
    end
    
    // Load Hazard Detection
    wire lwStall;
    assign lwStall = ResultSrcE[0] & ((Rs1D == RdE) | (Rs2D == RdE));

    assign StallF = lwStall | MatmulBusy;
    assign StallD = lwStall | MatmulBusy;
    
    // Flushes - Flush cuando hay branch/jump tomado O Load Hazard
    assign FlushD = PCSrcE;  // Flush Decode cuando branch tomado (prioridad sobre stall?)
    assign FlushE = lwStall | PCSrcE | MatmulBusy;  // Flush Execute cuando branch tomado o Stall o MatmulBusy
    
endmodule