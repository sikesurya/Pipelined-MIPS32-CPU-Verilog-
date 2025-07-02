# MIPS32 Pipelined CPU in Verilog

This repository implements a **5-stage pipelined MIPS32 processor** using Verilog.

## Pipeline Stages
- **IF**: Instruction Fetch
- **ID**: Instruction Decode
- **EX**: Execute
- **MEM**: Memory Access
- **WB**: Write Back

## Features
- 32-bit instructions and registers
- 1024-word data memory
- Support for R-type and I-type instructions
- Load/Store/Branch operations
- HALT instruction for simulation stop

## Folder Structure

| Folder       | Description                                 |
|--------------|---------------------------------------------|
| `src/`       | CPU source modules (`pipe_MIPS32.v`)        |
| `testbenches/` | Simulation testbenches (`*.v`)             |
| `waveforms/` | Xilinx Vivado waveforms            |
| `docs/`      | Diagrams and analysis notes                 |
| `mem_init/`  | Pre-written memory dumps         |

## Testbenches

### `test2_mips32.v` (Load/Add/Store)
Loads value from memory[120], adds 45, and stores to memory[121].


### `test_mips32.v` (Arithmetic Chaining)
- `ADDI R1, R0, 10`
- `ADDI R2, R0, 20`
- `ADDI R3, R0, 25`
- `ADD R4, R1, R2`
- `ADD R5, R4, R3`
- HALT

### `test3_mips32.v` — Factorial Computation

This testbench reads a number `N` from memory location 200 and computes its factorial using a loop and multiply-subtract-branch logic. The result is stored in memory location 198.

Registers Used:
- `R10`: Address pointer to memory
- `R3`: Loop counter (initial `N`)
- `R2`: Factorial accumulator

Verifies:
✅ Load/Store  
✅ MUL, SUBI, BNEQZ  
✅ Looping and memory output




## Simulating with Icarus Verilog

```bash
# Compile
iverilog -o sim.out src/pipe_MIPS32.v testbenches/test_mips32.v

# Run
vvp sim.out

# Optional: View waveforms
gtkwave dump.vcd
