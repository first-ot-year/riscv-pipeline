`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 02:32:11 PM
// Design Name: 
// Module Name: controller
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


module controller(
                    input clk,
                    input reset,
                    input  [6:0] op,
                  input  [2:0] funct3,
                  input  [6:0] funct7, // Modificado para FPU
                  input        ZeroE,
                  input        FlushE,  // Para flush de pipeline
                  output [1:0] ResultSrcW, 
                  output MemWriteM,
                  output PCSrcE, ALUSrcE,
                  output RegWriteW,
                  output [1:0] ImmSrcD, 
                  output [2:0] ALUControlE,
                  // forward
                  output RegWriteM,
                  output [1:0] ResultSrcE,
                  // FPU
                  output FPUStartE,
                  output [2:0] FPUControlE,
                  output MatmulStartE, // NUEVO
                  input  MatmulBusy,    // NUEVO
                  input  StallE         // NUEVO
                  );  // Exportado para hazard unit
  
  wire [1:0] ALUOp; 
  
  
  ////////
  wire        RegWriteD;
    wire  [1:0] ResultSrcD;
    wire        MemWriteD;
    wire        JumpD;
    wire        BranchD;
    wire  [2:0] ALUControlD;
    wire        ALUSrcD;
    
    //////////
    
    wire        RegWriteE;
    // ResultSrcE ya está declarado como output
    wire        MemWriteE;
    wire        JumpE;
    wire        BranchE;
    
    ///////////
    
    //wire        RegWriteM;
    wire  [1:0] ResultSrcM;

    
    wire FPUStartD;
    wire [2:0] FPUControlD;
    wire MatmulStartD; // NUEVO

  maindec md(
    .op(op),   // input
    .RegWrite(RegWriteD),  // out
    .ResultSrc(ResultSrcD), // out
    .MemWrite(MemWriteD),  // out
    .Branch(BranchD), // out
    .ALUSrc(ALUSrcD),  // out

    .Jump(JumpD), // out
    .ImmSrc(ImmSrcD),  // out
    .ALUOp(ALUOp) // hacia aludec
  ); 
  
  fpudec fd(
    .funct7(funct7),
    .op(op),
    .FPUControl(FPUControlD),
    .FPUStart(FPUStartD),
    .MatmulStart(MatmulStartD) // NUEVO
  );

  aludec  ad(
    .opb5(op[5]), 
    .funct3(funct3), 
    .funct7b5(funct7[5]), 
    .ALUOp(ALUOp), 
    .ALUControl(ALUControlD) // out 
  ); 
  
  
  // 
  
   dff1_controller dff1(
  .clk(clk),
  .reset(reset),
  .clr(FlushE),
  .en(~StallE), // Enable when NOT stalled
  
  .d0(RegWriteD),
  .d1(ResultSrcD),
  .d2(MemWriteD),
  .d3(JumpD),
  .d4(BranchD),
  .d5(ALUControlD),
  .d6(ALUSrcD),
  .d7(FPUStartD),
  .d8(FPUControlD),
  .d9(MatmulStartD), // NUEVO
  
  .q0(RegWriteE),
  .q1(ResultSrcE),
  .q2(MemWriteE),
  .q3(JumpE),
  .q4(BranchE),
  .q5(ALUControlE),
  .q6(ALUSrcE),
  .q7(FPUStartE),
  .q8(FPUControlE),
  .q9(MatmulStartE) // NUEVO
  );

    dff2_controller dff2(
   .clk(clk),
   .reset(reset),
   .d0(RegWriteE),
   .d1(ResultSrcE),
   .d2(MemWriteE),

   .q0(RegWriteM),
   .q1(ResultSrcM),
   .q2(MemWriteM)
   );
   //
   dff3_controller dff3(
    .clk(clk),
  .reset(reset),
  .d0(RegWriteM),
  .d1(ResultSrcM),


  .q0(RegWriteW),
  .q1(ResultSrcW)
  
  );

 assign PCSrcE = BranchE & ZeroE | JumpE; 
endmodule

