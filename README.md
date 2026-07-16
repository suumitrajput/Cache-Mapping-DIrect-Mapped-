# 🚀 16 KB Direct-Mapped Cache Controller in Verilog

This repository contains a synthesizable-style implementation of a **16 KB Direct-Mapped Cache Controller** written in Verilog, along with a comprehensive testbench to simulate hit/miss scenarios, conflict misses, and cold misses.

The design is fully compatible with **EDA Playground** and includes visual waveform dumping (`dump.vcd`) for EPWave.

---

## 📌 Cache Specifications

| Parameter | Value | Details / Derivation |
| :--- | :--- | :--- |
| **Cache Size** | 16 KB | $256 \text{ lines} \times 16 \text{ words/line} \times 4 \text{ bytes/word}$ |
| **Cache Lines** | 256 | Indexed using 8 bits (`Address[13:6]`) |
| **Line Size** | 16 Words (64 Bytes) | Offset using 4 bits (`Address[5:2]`) |
| **Address Width** | 32-bit | Byte-addressable representation |
| **Memory Mapping** | Direct Mapped | Each memory block maps to exactly one cache line |

### 🔍 Address Decoding Scheme
For any 32-bit incoming memory address:
* **Tag (`Address[31:14]`)**: 18 bits — Used to verify if the cached block matches the requested memory block.
* **Index (`Address[13:6]`)**: 8 bits — Maps to one of the 256 cache lines ($2^8 = 256$).
* **Word Offset (`Address[5:2]`)**: 4 bits — Selects one of the 16 words in the cache line ($2^4 = 16$).
* **Byte Offset (`Address[1:0]`)**: 2 bits — Ignored here since the cache outputs a whole 32-bit word.

---

## 📂 File Structure

* **`Cache.v`**: The main Cache memory design containing tag arrays, valid bits, hit/miss detection logic, and the main memory block transfer simulation.
* **`Cache_tb.v`**: Testbench providing memory stimulus, populating dummy data in the main memory, and generating waveform files (`dump.vcd`).

---

## ⚙️ How the Controller Works

1. **Hit Detection**:
   * On every positive edge of `clk`, the controller decodes the address into `tag`, `index`, and `offset`.
   * If `Cache_Valid[index]` is `1` AND `Cache_Tags[index]` matches the requested `tag`, a **CACHE HIT** occurs (`Hit_Miss = 1`).
   * The requested 32-bit word is routed instantly to `Data_Out`.

2. **Miss Handling (Block Fetch)**:
   * If there's a mismatch or the line is invalid, a **CACHE MISS** occurs (`Hit_Miss = 0`).
   * The `rate` (miss counter) increments.
   * The controller calculates the block's base address (`base_address = Address & 32'hFFFFFFC0`) to align with the 64-byte boundary.
   * It fetches all 16 words (64 bytes total) sequentially from the simulated main memory, reconstructs them from bytes, and populates the selected cache line.
   * `Cache_Tags[index]` is updated, `Cache_Valid[index]` is asserted, and the requested word is sent to `Data_Out`.

---

## 🛠️ Simulation & Waveform Generation (EDA Playground)

To run this simulation on **[EDA Playground](https://www.edaplayground.com/)**:

1. Paste the code from `Cache.v` into the design window (`design.sv`).
2. Paste the code from `Cache_tb.v` into the testbench window (`testbench.sv`).
3. Under **Tools & Simulators** (left pane):
   * Select **Icarus Verilog 0.10.0** (or any SystemVerilog/Verilog compatible simulator).
   * Check **"Open EPWave after run"** to view the output waveforms.
   * Set the **Top entity** to `Cache_tb`.
4. Click **Run**.

### 📈 Expected Simulation Sequence & Outputs

The testbench tests the cache controller against a series of strategic memory reads to demonstrate different states:

| Timestamp | Address Checked | Expected Outcome | Reason |
| :---: | :--- | :---: | :--- |
| **0 ns** | `32'h0000_0040` | **MISS** | **Cold Miss**: Cache is empty (Valid bits are 0). |
| **10 ns** | `32'h0000_0044` | **HIT** | **Spatial Locality**: Fetched into the cache in the previous cycle because it's in the same block. |
| **20 ns** | `32'h0000_0048` | **HIT** | **Spatial Locality**: Same cache block. |
| **30 ns** | `32'h0000_0080` | **MISS** | **Cold Miss**: Belongs to a different cache index line. |
| **40 ns** | `32'h0000_0084` | **HIT** | **Spatial Locality**: Read from the newly fetched block. |
| **50 ns** | `32'h0000_4040` | **MISS** | **Conflict Miss**: Maps to index `1` (same as address `0x40`) but has a different tag. Evicts the old block. |
| **60 ns** | `32'h0000_0040` | **MISS** | **Conflict Miss**: The original block was evicted in the previous step, so it has to be re-fetched. |

---

## 📝 License
This project is open-source. Feel free to use and modify it for your academic assignments or laboratory experiments!

# Author 

Sumit Kumar Singh
DTU,ECE
