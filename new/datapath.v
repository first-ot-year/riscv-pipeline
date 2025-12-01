`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 02:34:33 PM
// Design Name: 
// Module Name: datapath
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


module datapath(input  clk, reset,
                // fetch
                input  PCSrcE,
                input  StallF, // Stall Fetch
                input  StallD, // Stall Decode
                input  StallE, // Stall Execute (NEW)
                output [31:0] PCF, // va para risc --> imem
                input  [31:0] InstrF, // viene de imem -> risc
                
                // decode 
                output [31:0] InstrD, // output para controller
                input  RegWriteW,
                input  [1:0]  ImmSrcD,
                input         FlushD, // Flush para Decode
                
                // execute 
                input ALUSrcE,
                input  [2:0]  ALUControlE,
                input        FPUStartE, // NUEVO
                input  [2:0] FPUControlE, // NUEVO
                input        MatmulStartE, // NUEVO: Start signal for Matmul
                output       MatmulBusy,   // NUEVO: Busy signal from Matmul
                output       MatmulMemWrite, // NUEVO: MemWrite from Matmul
                output ZeroE, 
                
                // memoria
                output [31:0] ALUResultM, WriteDataM, 
                input  [31:0] ReadDataM, // input 
                
                // wb
                input  [1:0]  ResultSrcW,
                
                // forward
                input [1:0] ForwardAE, ForwardBE,
                
                /// salidas para forward 
                output [4:0] Rs1E, Rs2E,
                output [4:0] RdE, RdM, RdW  // Agregado RdE
                // salidas para 
                );  // input de controller 
                
  
  localparam WIDTH = 32; // Define a local parameter for bus width
 /// fetch
  wire [31:0] PCFNext, PCPlus4F;
  
    //  Control de stall
    

  
  // decode
  wire [31:0] ImmExtD; 
  wire [31:0] RD1D;
  wire [31:0] RD2D;
  wire [31:0] PCD;
  wire [4:0] RdD;
  wire [4:0] Rs3D; // For MATMUL (Base C)
  wire [31:0] PCPlus4D;
  
  
  // execute
  wire [31:0] SrcAE, SrcBE; 
  wire [31:0] RD1E, RD2E;
  wire [31:0] ALUResultE; 
   wire [31:0] WriteDataE;
   wire [31:0] PCE;
   wire [31:0] ImmExtE;
   // RdE ya está declarado como output
   wire [31:0] PCPlus4E;
   wire [31:0] PCTargetE;
  
  // memoria  
   //wire [4:0] RdM;
   wire [31:0] PCPlus4M;
   
   // wb
   wire [31:0] ALUResultW;
   wire [31:0] ReadDataW;
   wire [31:0] PCPlus4W;
   //wire [4:0] RdW;
   wire [31:0] ResultW;
   
  
  // next PC logic
  flopr pcreg(
    .clk(clk), 
    .reset(reset),
    .en(~StallF), 
    .d(PCFNext), 
    .q(PCF)
  ); 

  adder       pcadd4(
    .a(PCF), 
    .b(32'd4), // Using WIDTH parameter for constant 4
    .y(PCPlus4F)
  ); 


  mux2 #(WIDTH)  pcmux(
    .d0(PCPlus4F), 
    .d1(PCTargetE), 
    .s(PCSrcE), 
    .y(PCFNext)
  ); 
 
   dff4_datapath dff4(
   .clk(clk),
   .reset(reset),
   .clr(FlushD), // Flush cuando branch tomado
   .en(~StallD), // Enable (Stall)
   .d0(InstrF),
   .d1(PCF),
   .d2(PCPlus4F),
   .q0(InstrD),
   .q1(PCD),
   .q2(PCPlus4D)
   );
   
   assign RdD = InstrD[11:7];
   assign Rs3D = InstrD[11:7]; // Reuse Rd field as Rs3 for MATMUL input
  // register file logic
  // register file logic
  wire [31:0] RD3D; // Output for 3rd port
  
  regfile     rf(
    .clk(clk), 
    .we3(RegWriteW), 
    .a1(InstrD[19:15]), 
    .a2(InstrD[24:20]), 
    .a3(RdW),  // Write address
    .a4(Rs3D), // Read address 3 (using Rd field)
    .wd3(ResultW), 
    .rd1(RD1D), 
    .rd2(RD2D),
    .rd3(RD3D)
  ); 

  extend      ext(
    .instr(InstrD[31:7]), 
    .immsrc(ImmSrcD), 
    .immext(ImmExtD)
  ); 
  
      // RS1D RS2D
   wire [4:0] Rs1D;
   wire [4:0] Rs2D;
   
   assign Rs1D = InstrD[19:15];
   assign Rs2D = InstrD[24:20];
   
   wire [31:0] RD3E; // Base C in Execute

   dff5_datapath dff5(
   .clk(clk),
   .en(~StallE), // Enable when NOT stalled
   .d0(RD1D),
   .d1(RD2D), 
   .d2(PCD),
   .d3(RdD),
   .d4(ImmExtD),
   .d5(PCPlus4D),
  
   
   .d6(Rs1D),
   .d7(Rs2D),
   .d8(RD3D), // Pass Base C to Execute
   .q0(RD1E),
   .q1(RD2E), 
   .q2(PCE),
   .q3(RdE),
   .q4(ImmExtE),
   .q5(PCPlus4E),
   .q6(Rs1E),
   .q7(Rs2E),
   .q8(RD3E),
   .reset(reset)

   );
   
   // execute
   mux3 #(WIDTH) mux_forwardAE(
   .d0(RD1E),
   .d1(ResultW),
   .d2(ALUResultM),
   .s(ForwardAE),
   .y(SrcAE)
   );
   
   
   mux3 #(WIDTH) mux_forwardBE(
   .d0(RD2E),
   .d1(ResultW),
   .d2(ALUResultM),
   .s(ForwardBE),
   .y(WriteDataE)
   );
  
  // ALU logic - SrcB mux selecciona entre WriteDataE (con forwarding) o ImmExtE
  mux2 #(WIDTH)  srcbmux(
    .d0(WriteDataE),  // ✓ CORREGIDO: Usa WriteDataE (con forwarding) en lugar de RD2E
    .d1(ImmExtE), 
    .s(ALUSrcE), 
    .y(SrcBE)
  ); 

  alu         alu(
    .a(SrcAE), 
    .b(SrcBE), 
    .alucontrol(ALUControlE), 
    .result(ALUResultE), 
    .zero(ZeroE)
  ); 
  
  adder       pcaddbranch(
    .a(PCE), 
    .b(ImmExtE), 
    .y(PCTargetE)
  ); 
  
  
  // dfff
   // FPU Instance
   wire [31:0] FPUResultM_internal;
   wire [4:0] FPUFlagsM;
   wire FPUValidM;
   
   // MATMUL Signals
   wire [31:0] mm_mem_addr, mm_mem_wd;
   wire mm_mem_we;
   wire [2:0] mm_fpu_op;
   wire [31:0] mm_fpu_a, mm_fpu_b;
   wire mm_fpu_start;
   
   // Muxes for FPU inputs
   wire [2:0] fpu_op_in = MatmulBusy ? mm_fpu_op : FPUControlE;
   wire [31:0] fpu_a_in = MatmulBusy ? mm_fpu_a : SrcAE;
   wire [31:0] fpu_b_in = MatmulBusy ? mm_fpu_b : SrcBE;
   wire fpu_start_in    = MatmulBusy ? mm_fpu_start : FPUStartE;

   // Muxes for Memory outputs (ALUResultM drives DataAdrM)
   // We need to intercept ALUResultM and WriteDataM and MemWriteM
   // But ALUResultM comes from pipeline registers.
   // Matmul operates in Execute stage (conceptually) but controls memory directly.
   // Actually, Matmul needs to override the Memory stage outputs.
   
   // Let's instantiate Matmul Unit
   // Base addresses: A=Rs1, B=Rs2, C=Rd (from RegFile)
   // Note: RdE is the destination register index. We need the VALUE of Rd.
   // Standard RISC-V doesn't read Rd.
   // We need to change RegFile to read 3 ports? Or use a trick.
   // Trick: MATMUL instruction format.
   // If we use R-type: rs1, rs2, rd.
   // We need 3 input values.
   // Maybe we use rs1, rs2, and... rs3? RV32I doesn't have rs3.
   // Alternative: C is an output? No, C is input pointer.
   // Maybe we use (rs1), (rs2) -> (rd).
   // rd is just an index. We need the value in register rd.
   // Standard RegFile has 2 read ports.
   // We can't read 3 registers.
   
   // Solution: Use Rd as destination register that holds the POINTER to C?
   // No, if we want to write to memory at C, we need the pointer value.
   // If the instruction is `matmul rs1, rs2, rd`, we expect `rd` to be the register holding the base address of C.
   // But we can't read `rd` from RegFile.
   
   // Workaround:
   // Use `matmul rs1, rs2, rs3`? (R4-type, used in FMADD).
   // FMADD: rd, rs1, rs2, rs3.
   // Our instruction is custom. We can define it as using rs1, rs2, and...
   // Wait, if we use `rd` as the register index for Base C, we can't read it.
   // UNLESS we modify RegFile to have 3 read ports.
   // OR we use `rs1`, `rs2` for A and B. And we assume C is fixed or passed differently?
   // Or we use two instructions?
   
   // Let's check `regfile.v`. It has 2 read ports.
   // Modifying RegFile is risky/intrusive.
   
   // Alternative:
   // `matmul x10, x11, x12` -> A=x10, B=x11, C=x12.
   // But we can only read 2.
   // Maybe we use `rs2` for B and `rs1` for A.
   // Where is C?
   // Maybe C is hardcoded or we use a specific register?
   // Or we use `rs1` for A, `rs2` for B, and `rd` is just the destination register for the "result" (maybe success code).
   // But we need Base C.
   
   // Let's assume the user wants `MATMUL.FP A, B -> C`.
   // Maybe we can reuse the FMADD format which has rs3?
   // `InstrD[31:27]` is rs3.
   // If we decode rs3, we can read it.
   // But RegFile only has 2 ports.
   
   // Let's modify RegFile to have 3 read ports?
   // It's small (32x32). Adding a port is easy.
   
   // Let's check `regfile.v` first.
   
   fp_core32 fpu(
     .clk(clk),
     .rst(reset),
     .start(fpu_start_in),
     .op(fpu_op_in),
     .a(fpu_a_in),
     .b(fpu_b_in),
     .result(FPUResultM_internal),
     .flags(FPUFlagsM),
     .valid_out(FPUValidM)
   );

   wire [31:0] ALUResultM_raw;
   wire FPUStartM;

   // Instantiate MATMUL Unit
   matmul_unit mm_unit(
     .clk(clk),
     .reset(reset),
     .start(MatmulStartE),
     .base_A(SrcAE), // Use Forwarded A
     .base_B(SrcBE), // Use Forwarded B (via SrcBE mux? No, SrcBE is Mux(ForwardB, Imm). For MATMUL, ALUSrcE should be 0)
     .base_C(RD3E),  // Base C from Rd field (no forwarding for now, or add forwarding if needed)
     
     .mem_addr(mm_mem_addr),
     .mem_wd(mm_mem_wd),
     .mem_we(mm_mem_we),
     .mem_rd(ReadDataM), // ReadData comes from Memory stage. But Matmul is in Execute?
                         // Issue: Matmul drives address, but ReadData comes from Memory.
                         // If Matmul is in Execute, it needs to drive DataAdrM.
                         // And wait for ReadDataM in next cycle?
                         // Yes, Matmul FSM handles latency.
     
     .fpu_op(mm_fpu_op),
     .fpu_a(mm_fpu_a),
     .fpu_b(mm_fpu_b),
     .fpu_start(mm_fpu_start),
     .fpu_result(FPUResultM_internal),
     .fpu_valid(FPUValidM),
     
     .busy(MatmulBusy)
   );

   // Muxing Memory Signals
   // DataAdrM is driven by ALUResultM usually.
   // Now it can be driven by mm_mem_addr.
   // But ALUResultM is output of Execute pipeline register.
   // mm_mem_addr is generated in Execute stage (combinational from FSM).
   // So we should mux it BEFORE the pipeline register?
   // No, Matmul FSM runs across multiple cycles.
   // If we mux before dff6, then DataAdrM changes every cycle as FSM updates.
   // But dff6 latches ALUResultE.
   // If Matmul is active, we bypass the pipeline register for Memory control?
   // Or we feed mm_mem_addr into dff6?
   // If we feed into dff6, we add 1 cycle latency to address.
   // Matmul FSM expects address to go to memory.
   // If we bypass dff6, we are "in" Memory stage?
   // But FPU is in Execute/Memory.
   
   // Let's bypass dff6 for Matmul Memory Control.
   // ALUResultM is the address port for dmem.
   // We will mux ALUResultM with mm_mem_addr.
   
   // Wait, ALUResultM is defined as output of dff6.
   // We need to redefine ALUResultM to be the Mux output.
   
   wire [31:0] ALUResultM_pipe;
   wire [31:0] WriteDataM_pipe;
   
   dff6_datapath dff6(
    .clk(clk),
    .d0(ALUResultE),
    .d1(WriteDataE),
    .d2(RdE),
    .d3(PCPlus4E),
    .d4(FPUStartE), // FPU
    .q0(ALUResultM_pipe), // RAW
    .q1(WriteDataM_pipe),
    .q2(RdM),
    .q3(PCPlus4M),
    .q4(FPUStartM), // FPU
    .reset(reset)
    );
    
    
    // Muxes for Memory Stage outputs
    assign ALUResultM = MatmulBusy ? mm_mem_addr : (FPUStartM ? FPUResultM_internal : ALUResultM_pipe);
    // Note: FPUResultM_internal is also muxed here in original code?
    // Original: assign ALUResultM = FPUStartM ? FPUResultM_internal : ALUResultM_raw;
    // We need to preserve that logic for non-matmul FPU ops.
    
    // Logic:
    // If MatmulBusy: Address comes from Matmul.
    // Else if FPUStartM: Result comes from FPU (this is for WB, not Address! Wait.)
    // For FPU instructions, ALUResultM carries the RESULT to WB.
    // For Load/Store, ALUResultM carries the ADDRESS to Mem.
    
    // Matmul needs to drive ADDRESS to Mem.
    // So:
    assign ALUResultM = MatmulBusy ? mm_mem_addr : (FPUStartM ? FPUResultM_internal : ALUResultM_pipe);
    
    // WriteDataM
    assign WriteDataM = MatmulBusy ? mm_mem_wd : WriteDataM_pipe;
    
    // We also need to control MemWriteM.
    // MemWriteM comes from Controller -> dff1 -> dff2.
    // We need to intercept it.
    // But MemWriteM is output of Controller, not Datapath.
    // Datapath doesn't output MemWriteM.
    // Controller outputs MemWriteM.
    // We need to modify Controller or pass MemWriteM through Datapath?
    // Currently `riscvpipe.v` connects `controller.MemWriteM` to `dmem.we`.
    // We should move MemWriteM muxing to `riscvpipe.v` or pass it through datapath.
    // Let's pass a "OverrideMemWrite" signal from Datapath to Controller? Or output the final MemWrite from Datapath?
    // Better: Output `MatmulMemWrite` from Datapath and mux in `riscvpipe.v`.
    
    assign MatmulMemWrite = mm_mem_we;
   // entra memoria
   
   dff7_datapath dff7(
   .clk(clk),
   .d0(ALUResultM),
   .d1(ReadDataM),
   .d2(RdM),
   .d3(PCPlus4M),
   .q0(ALUResultW),
   .q1(ReadDataW),
   .q2(RdW),
   .q3(PCPlus4W),
   .reset(reset)
   );
   
 
  mux3 #(WIDTH)  resultmux(
    .d0(ALUResultW), 
    .d1(ReadDataW), 
    .d2(PCPlus4W), 
    .s(ResultSrcW), 
    .y(ResultW)
  ); 
endmodule

