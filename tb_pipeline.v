`timescale 1ns / 1ps

module tb_pipeline;

  reg clk;
  reg reset;
  wire [31:0] WriteDataM, DataAdrM;
  wire MemWriteM;

  // Instantiate Top Module
  top dut(
    .clk(clk),
    .reset(reset),
    .WriteDataM(WriteDataM),
    .DataAdrM(DataAdrM),
    .MemWriteM(MemWriteM)
  );

  // Clock Generation
  always #5 clk = ~clk;

  // Test Sequence
  initial begin
    // Initialize
    clk = 0;
    reset = 1;
    
    // Reset Pulse
    #20 reset = 0;
    
    // Run Simulation
    $display("Starting Pipeline Verification...");
    $display("Time\tPC\tInstr\tMemWrite\tAddress\tData");
    
    // Check Memory Content
    $display("Checking IMEM content:");
    $display("RAM[0] = %h", dut.imem.RAM[0]);
    $display("RAM[1] = %h", dut.imem.RAM[1]);
    
    // Monitor loop
    repeat(2000) @(posedge clk) begin
      // Print every cycle
      $display("%0t\tPC=%h\tInstr=%h\tMW=%b\tAdr=%h\tWD=%h\tResM=%h\tFPUCtrl=%b\tFPUStart=%b", 
               $time, 
               dut.rvpipeline.PCF, 
               dut.rvpipeline.InstrF, 
               MemWriteM, 
               DataAdrM, 
               WriteDataM,
               dut.rvpipeline.ALUResultM,
               dut.rvpipeline.FPUControlE,
               dut.rvpipeline.FPUStartE);
    end
  
    
    wait(dut.rvpipeline.PCF == 32'h000000F4); 
    #100;

    $display("Checking Python Matmul Results:");

    if (dut.dmem.RAM[192] === 32'h41bf70a4)
        $display("PASS: C[0,0] = %h (Expected 41bf70a4)", dut.dmem.RAM[192]);
    else
        $display("FAIL: C[0,0] = %h (Expected 41bf70a4)", dut.dmem.RAM[192]);

    if (dut.dmem.RAM[193] === 32'h41e67ae2)
        $display("PASS: C[0,1] = %h (Expected 41e67ae2)", dut.dmem.RAM[193]);
    else
        $display("FAIL: C[0,1] = %h (Expected 41e67ae2)", dut.dmem.RAM[193]);

    if (dut.dmem.RAM[196] === 32'h424851eb)
        $display("PASS: C[1,0] = %h (Expected 424851eb)", dut.dmem.RAM[196]);
    else
        $display("FAIL: C[1,0] = %h (Expected 424851eb)", dut.dmem.RAM[196]);

    if (dut.dmem.RAM[197] === 32'h42710a3e)
        $display("PASS: C[1,1] = %h (Expected 42710a3e)", dut.dmem.RAM[197]);
    else
        $display("FAIL: C[1,1] = %h (Expected 42710a3e)", dut.dmem.RAM[197]);

    $display("Simulation Finished.");
    $finish;
  end

endmodule
