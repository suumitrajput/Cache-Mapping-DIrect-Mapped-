// =================================================================
// Testbench for Direct Mapped Cache
// Designed for EDA Playground (EPWave support included)
// =================================================================

`timescale 1ns/1ps

module Cache_tb;

    // Inputs to DUT
    reg clk;
    reg [31:0] Address;

    // Outputs from DUT
    wire [31:0] Data_Out;
    wire Hit_Miss;
    wire [31:0] rate;

    // Loop variable
    integer k;

    // Instantiate Design Under Test (DUT) - Named Connection Style
    Cache dut (
        .clk(clk), 
        .Address(Address), 
        .Data_Out(Data_Out), 
        .Hit_Miss(Hit_Miss), 
        .rate(rate)
    );

    // Clock Generation (10ns Period -> 100MHz)
    initial begin
        clk = 0;
    end
    always #5 clk = ~clk;

    // Initialize Main Memory with a predictable pattern
    initial begin
        for (k = 0; k < 65536; k = k + 1) begin
            dut.memory[k] = k[7:0]; // Loading 8-bit pattern into byte memory
        end
    end

    // Monitor Outputs on every positive edge (with a small delay for stable signals)
    always @(posedge clk) begin
        #1 $display("Time=%0t ns | Addr=0x%h | Index=%0d | Offset=%0d | %s | Data=0x%h | Total Misses=%0d",
                    $time, Address, Address[13:6], Address[5:2],
                    Hit_Miss ? "HIT " : "MISS", Data_Out, rate);
    end

    // Main Stimulus & VCD Dumping
    initial begin
        // Required for EDA Playground to generate waveforms
        $dumpfile("dump.vcd"); // EDA Playground defaults to dump.vcd
        $dumpvars(0, Cache_tb);

        // --- Stimulus Sequence ---
        $display("\n--- Starting Cache Simulation ---");
        
        Address = 32'h0000_0040;      // Miss (Cold miss)
        #10;
        Address = 32'h0000_0044;      // Hit (Same line, next word)
        #10;
        Address = 32'h0000_0048;      // Hit (Same line)
        #10;
        Address = 32'h0000_0080;      // Miss (New cache line/index)
        #10;
        Address = 32'h0000_0084;      // Hit (Same new line)
        #10;
        Address = 32'h0000_4040;      // Miss (Same index, different tag -> Conflict Miss)
        #10;
        Address = 32'h0000_0040;      // Miss (Evicted line requested again)
        #10;
        
        $display("--- Simulation Finished --- \n");
        $finish;
    end

endmodule
