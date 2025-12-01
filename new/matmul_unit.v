`timescale 1ns / 1ps

module matmul_unit(
    input clk,
    input reset,
    input start,
    input [31:0] base_A,
    input [31:0] base_B,
    input [31:0] base_C,
    
    // Interface to Memory
    output reg [31:0] mem_addr,
    output reg [31:0] mem_wd,
    output reg        mem_we,
    input      [31:0] mem_rd,
    
    // Interface to FPU
    output reg [2:0]  fpu_op,
    output reg [31:0] fpu_a,
    output reg [31:0] fpu_b,
    output reg        fpu_start,
    input      [31:0] fpu_result,
    input             fpu_valid,
    
    // Status
    output reg busy
);

    // State encoding
    localparam IDLE         = 4'd0;
    localparam INIT_ACC     = 4'd1;
    localparam LOAD_A       = 4'd2;
    localparam LOAD_B       = 4'd3;
    localparam START_MUL    = 4'd4;
    localparam WAIT_MUL     = 4'd5;
    localparam START_ADD    = 4'd6;
    localparam WAIT_ADD     = 4'd7;
    localparam WRITE_C      = 4'd8;
    localparam DONE         = 4'd9;

    reg [3:0] state, next_state;
    
    // Counters
    reg [2:0] i, j, k; // 0..3
    
    // Data registers
    reg [31:0] val_A, val_B;
    reg [31:0] acc;
    reg [31:0] prod;
    
    // Latched Base Addresses
    reg [31:0] latched_base_A;
    reg [31:0] latched_base_B;
    reg [31:0] latched_base_C;
    
    // Address calculation
    // A: Row i, Col k -> Offset = (i*4 + k)*4
    // B: Row k, Col j -> Offset = (k*4 + j)*4
    // C: Row i, Col j -> Offset = (i*4 + j)*4
    
    wire [31:0] offset_A = ({27'd0, i, 2'd0} + {29'd0, k}) << 2;
    wire [31:0] offset_B = ({27'd0, k, 2'd0} + {29'd0, j}) << 2;
    wire [31:0] offset_C = ({27'd0, i, 2'd0} + {29'd0, j}) << 2;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            i <= 0; j <= 0; k <= 0;
            val_A <= 0; val_B <= 0;
            acc <= 0;
            prod <= 0;
            latched_base_A <= 0;
            latched_base_B <= 0;
            latched_base_C <= 0;
        end else begin
            state <= next_state;
            
            // Latch data based on state transitions or current state
            case (state)
                IDLE: begin
                    i <= 0; j <= 0; k <= 0;
                    if (start) begin
                        latched_base_A <= base_A;
                        latched_base_B <= base_B;
                        latched_base_C <= base_C;
                    end
                end
                
                INIT_ACC: begin
                    acc <= 32'd0;
                    k <= 0;
                end
                
                LOAD_A: begin
                    // mem_rd has A value at end of this cycle (assuming addr set in prev cycle logic? No, addr is combinational from state)
                    // Wait, if I set mem_addr in LOAD_A, mem_rd is valid in same cycle (combinational RAM).
                    // So I can latch it at posedge.
                    val_A <= mem_rd;
                end
                
                LOAD_B: begin
                    val_B <= mem_rd;
                end
                
                WAIT_MUL: begin
                    if (fpu_valid) prod <= fpu_result;
                end
                
                WAIT_ADD: begin
                    if (fpu_valid) begin
                        acc <= fpu_result;
                        k <= k + 1;
                    end
                end
                
                WRITE_C: begin
                    // Loop updates
                    if (j == 3) begin
                        j <= 0;
                        i <= i + 1;
                    end else begin
                        j <= j + 1;
                    end
                end
            endcase
        end
    end

    // Combinational Logic
    always @* begin
        next_state = state;
        
        // Defaults
        busy = 0;
        mem_we = 0;
        mem_addr = 0;
        mem_wd = 0;
        fpu_start = 0;
        fpu_op = 3'b000;
        fpu_a = 0;
        fpu_b = 0;
        
        case (state)
            IDLE: begin
                busy = 0;
                if (start) begin
                    next_state = INIT_ACC;
                    busy = 1;
                end
            end
            
            INIT_ACC: begin
                busy = 1;
                next_state = LOAD_A;
            end
            
            LOAD_A: begin
                busy = 1;
                mem_addr = latched_base_A + offset_A;
                next_state = LOAD_B;
            end
            
            LOAD_B: begin
                busy = 1;
                mem_addr = latched_base_B + offset_B;
                next_state = START_MUL;
            end
            
            START_MUL: begin
                busy = 1;
                fpu_op = 3'b010; // MUL
                fpu_a = val_A;
                fpu_b = val_B;
                fpu_start = 1;
                next_state = WAIT_MUL;
            end
            
            WAIT_MUL: begin
                busy = 1;
                fpu_op = 3'b010; // Keep MUL op
                if (fpu_valid) begin
                    next_state = START_ADD;
                end
            end
            
            START_ADD: begin
                busy = 1;
                fpu_op = 3'b000; // ADD
                fpu_a = acc;
                fpu_b = prod;
                fpu_start = 1;
                next_state = WAIT_ADD;
            end
            
            WAIT_ADD: begin
                busy = 1;
                fpu_op = 3'b000; // Keep ADD op
                if (fpu_valid) begin
                    if (k == 3) next_state = WRITE_C;
                    else next_state = LOAD_A;
                end
            end
            
            WRITE_C: begin
                busy = 1;
                mem_addr = latched_base_C + offset_C;
                mem_wd = acc;
                mem_we = 1;
                
                if (i == 3 && j == 3) next_state = DONE;
                else next_state = INIT_ACC;
            end
            
            DONE: begin
                busy = 0;
                if (!start) next_state = IDLE; // Handshake
            end
        endcase
    end
  always @(posedge clk) begin
    if (start) $display("MATMUL: Start received. BaseA=%h, BaseB=%h, BaseC=%h", base_A, base_B, base_C);
    if (state != next_state) $display("MATMUL: State transition %d -> %d", state, next_state);
    if (mem_we) $display("MATMUL: Writing Memory Addr=%h Data=%h", mem_addr, mem_wd);
  end
endmodule
