// =================================================================
// Direct Mapped Cache Design
// Specifications: 256 lines, 16 words per line (64 Bytes/line -> 16 KB total)
// Address Split: Tag [31:14] (18 bits), Index [13:6] (8 bits), Offset [5:2] (4 bits)
// =================================================================

module Cache (
    input clk,
    input [31:0] Address,
    output reg [31:0] Data_Out,
    output reg Hit_Miss,          // 1 = Hit, 0 = Miss
    output reg [31:0] rate        // Miss counter
);

    // Cache Structure
    reg [31:0] Cache_Memory [0:255][0:15];
    reg [17:0] Cache_Tags [0:255];
    reg Cache_Valid [0:255];
    
    // Main Memory (64KB Byte-addressable simulation)
    reg [7:0] memory [0:65535];   

    // Internal Variables
    reg [17:0] tag;
    reg [7:0] index;
    reg [3:0] offset;
    reg [31:0] base_address;
    reg [31:0] temp_word;
    integer i, j;

    // Initialize Cache State
    initial begin
        rate = 0;
        for (i = 0; i < 256; i = i + 1) begin
            Cache_Valid[i] = 0;
        end
    end

    // Cache Controller Logic
    always @(posedge clk) begin
        // Address Decoding
        tag    = Address[31:14];
        index  = Address[13:6];
        offset = Address[5:2];

        // Cache Hit Check
        if (Cache_Valid[index] && (Cache_Tags[index] == tag)) begin
            Hit_Miss = 1'b1;
            Data_Out = Cache_Memory[index][offset];
        end
        // Cache Miss - Fetch block from main memory
        else begin
            Hit_Miss = 1'b0;
            rate     = rate + 1;
            
            // Align base address to 64-byte block boundary (clear lower 6 bits)
            base_address = Address & 32'hFFFFFFC0; 

            // Fill the cache line (16 words)
            for (i = 0; i < 16; i = i + 1) begin
                temp_word = 32'b0;
                // Reconstruct 32-bit word from 4 consecutive bytes (Big-Endian)
                for (j = 0; j < 4; j = j + 1) begin
                    temp_word = (temp_word << 8) | memory[base_address + j];
                end
                Cache_Memory[index][i] = temp_word;
                base_address = base_address + 4;
                
                // Safety check: Prevent simulation array index out-of-bounds
                if (base_address >= 65536) begin
                     base_address = 0; 
                end
            end
            
            // Update Tag and Valid bits
            Cache_Tags[index]  = tag;
            Cache_Valid[index] = 1'b1;
            
            // Output requested word
            Data_Out = Cache_Memory[index][offset];
        end
    end

endmodule
