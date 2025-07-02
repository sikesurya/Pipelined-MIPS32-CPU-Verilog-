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
| `waveforms/` | GTKWave `.gtkw` files (optional)            |
| `docs/`      | Diagrams and analysis notes                 |
| `mem_init/`  | Pre-written memory dumps (optional)         |

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

Displays values of R0–R5 at the end.

## Simulating with Icarus Verilog

```bash
# Compile
iverilog -o sim.out src/pipe_MIPS32.v testbenches/test_mips32.v

# Run
vvp sim.out

# Optional: View waveforms
gtkwave dump.vcd
