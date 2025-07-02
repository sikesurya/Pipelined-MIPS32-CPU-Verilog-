// src/definitions.vh

// Opcodes
`define ADD    6'b000000
`define SUB    6'b000001
`define AND    6'b000010
`define OR     6'b000011
`define SLT    6'b000100
`define MUL    6'b000101
`define HLT    6'b111111
`define LW     6'b001000
`define SW     6'b001001
`define ADDI   6'b001010
`define SUBI   6'b001011
`define SLTI   6'b001100
`define BNEQZ  6'b001101
`define BEQZ   6'b001110

// Instruction Types
`define RR_ALU 3'b000
`define RM_ALU 3'b001
`define LOAD   3'b010
`define STORE  3'b011
`define BRANCH 3'b100
`define HALT   3'b101
