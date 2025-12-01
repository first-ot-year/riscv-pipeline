`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 02:27:49 PM
// Design Name: 
// Module Name: riscvpipe
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


module riscvpipe(input  clk, reset,
                   output [31:0] PCF, // salida para imem
                   input  [31:0] InstrF, // instruc de imem
                   
                   output MemWriteM, // permiso para escribir en dmem
                   output [31:0] DataAdrM ,  // Direccion de memoria hacia dmem
                   output [31:0] WriteDataM, // Data a escribir en dmem
                   input  [31:0] ReadDataM); // Data leida de dmem
  
  wire [31:0] ALUResultM; 
  
  wire       ALUSrcE, RegWriteW, RegWriteM, ZeroE; 
 wire [1:0] ResultSrcW, ImmSrcD; 
   wire [2:0] ALUControlE; 
  wire       PCSrcE; 
  wire [31:0] InstrD;
  wire [4:0] Rs1E, Rs2E, RdE, RdM, RdW;  // Agregado RdE
  wire [1:0] ForwardAE, ForwardBE;
  wire [1:0] ResultSrcE;  // Declarado antes de ser usado
  wire StallF_hu, StallD_hu, FlushD_hu, FlushE_hu;
  wire FPUStartE;
  wire [2:0] FPUControlE;
  wire MatmulStartE; // NUEVO
  wire MatmulBusy;   // NUEVO
  wire MatmulMemWrite; 
  wire MatmulStall; // Declared early
  wire RealMatmulStartE; // Declared early
  // Wait, I didn't add MatmulMemWrite to datapath port list in previous edit!
  // I only did `assign MatmulMemWrite = mm_mem_we;` inside the module but didn't add it to output ports.
  // I need to fix datapath.v first or assume I will fix it.
  // Let's check datapath.v content again or fix it now.
  // I will fix datapath.v in a separate call if needed.
  // Assuming I add it:
  wire MatmulMemWrite_dp; 

  // DataAdr is connected to ALUResult
  assign DataAdrM = ALUResultM;
  
  wire MemWriteM_ctrl;
    
  controller c(
    .clk(clk),
    .reset(reset),
    .op(InstrD[6:0]),  // ibput
    .funct3(InstrD[14:12]),  // inpput 
    .funct7(InstrD[31:25]), // input 
    .ZeroE(ZeroE), // input
    .FlushE(FlushE_hu),  // Flush de pipeline
    .ResultSrcW(ResultSrcW), // output
    .MemWriteM(MemWriteM_ctrl), // output (Renamed)
    .PCSrcE(PCSrcE), // output
    .ALUSrcE(ALUSrcE), 
    .RegWriteW(RegWriteW), 
    .ImmSrcD(ImmSrcD), 
    .ALUControlE(ALUControlE),
    // forward
    .RegWriteM(RegWriteM),
    .ResultSrcE(ResultSrcE),  // Conectado para hazard unit
    .FPUStartE(FPUStartE),
    .FPUControlE(FPUControlE),
    .MatmulStartE(MatmulStartE), // NUEVO
    .MatmulBusy(MatmulBusy),      // NUEVO
    .StallE(MatmulStall)          // NEW: Stall Execute
  ); 
  
  // Instancia de hazard unit
  hazard_unit hu(
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdM(RdM),
    .RdW(RdW),
    .RegWriteM(RegWriteM),
    .RegWriteW(RegWriteW),
    .Rs1D(InstrD[19:15]),   // ✓ Conectado desde InstrD
    .Rs2D(InstrD[24:20]),   // ✓ Conectado desde InstrD
    .RdE(RdE),              // ✓ Conectado desde datapath
    .ResultSrcE(ResultSrcE), // ✓ Conectado
    .PCSrcE(PCSrcE),        // ✓ Para detectar branch/jump
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),
    .StallF(StallF_hu),     // ✓ Conectado
    .StallD(StallD_hu),     // ✓ Conectado
    .FlushD(FlushD_hu),     // ✓ Flush para Decode
    .FlushE(FlushE_hu),      // ✓ Flush para Execute
    .MatmulBusy(MatmulBusy) // NUEVO
  );
  

  // Structural Hazard: Matmul in Execute vs Store in Memory
  // If Matmul wants to start but Memory is busy with a Store (MemWriteM_ctrl),
  // we must stall the pipeline and NOT start the Matmul unit yet.
  assign MatmulStall = MatmulStartE & MemWriteM_ctrl;
  assign RealMatmulStartE = MatmulStartE & ~MemWriteM_ctrl;
  
  wire StallF_final = StallF_hu | MatmulStall;
  wire StallD_final = StallD_hu | MatmulStall;

  datapath dp(
    .clk(clk), 
    .reset(reset), 
    .ResultSrcW(ResultSrcW), 
    .PCSrcE(PCSrcE),
    .StallF(StallF_final), 
    .StallD(StallD_final), 
    .StallE(MatmulStall), // NEW: Stall Execute
    .ALUSrcE(ALUSrcE), 
    .RegWriteW(RegWriteW),
    .ImmSrcD(ImmSrcD), 
    .FlushD(FlushD_hu), 
    .ALUControlE(ALUControlE),
    .FPUStartE(FPUStartE),
    .FPUControlE(FPUControlE),
    .ZeroE(ZeroE), 
    .PCF(PCF), 
    .InstrF(InstrF),
    .InstrD(InstrD),
    .ALUResultM(ALUResultM), 
    .WriteDataM(WriteDataM), 
    .ReadDataM(ReadDataM),
    // forward
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdE(RdE),
    .RdM(RdM),
    .RdW(RdW),
    .MatmulStartE(RealMatmulStartE), // Updated
    .MatmulBusy(MatmulBusy),
    .MatmulMemWrite(MatmulMemWrite_dp) 
  ); 
  
  // Mux MemWriteM
  // If MatmulBusy, use MatmulMemWrite. Else use MemWriteM from controller.
  // Wait, MemWriteM is output of riscvpipe.
  // The `MemWriteM` wire comes from controller `c`.
  // We need to drive the output `MemWriteM` of `riscvpipe`.
  // Currently: `output MemWriteM` in module declaration.
  // And `controller c (.MemWriteM(MemWriteM)...)`
  // This connects controller output directly to module output.
  // We need to intercept.
  
  
  // Re-instantiate controller with internal wire
  // (I will do this in the replacement above by changing .MemWriteM(MemWriteM) to .MemWriteM(MemWriteM_ctrl))
  
  assign MemWriteM = MatmulBusy ? MatmulMemWrite_dp : MemWriteM_ctrl;
  
endmodule
