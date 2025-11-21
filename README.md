# RISC-V Single-Cycle (RV64) Core

This repository contains a simple RV64I single‑cycle processor implemented in Verilog along with unit testbenches and integration programs that exercise arithmetic/logic, branches/jumps, loads/stores, and immediate/upper-immediate instructions.

## Layout
- `source/` – top-level core (`riscv_single_cycle.v`) and submodules: control, immediate generation, PC update, and instruction memory.
- `ALU/` – arithmetic/logic unit and ALU control.
- `Memory/` – data memory.
- `Register_File/` – 32 × 64-bit register file and primitives.
- `tb/` – testbenches and hex programs for each instruction class plus a final integration program.

## Running Simulation
Use your preferred simulator (e.g., iverilog/vvp):
```sh
iverilog -g2012 -o sim.out tb/riscv_single_cycle_tb.v source/riscv_single_cycle.v \
  source/control_fsm.v source/immediate_generator.v source/instruction_memory.v \
  source/pc_update.v ALU/source/ALU.v ALU/source/alu_control.v \
  Memory/source/data_mem64.v Register_File/source/regfile64.v Register_File/source/reg64.v
vvp sim.out
```
The testbench will load the hex programs in `tb/`, run through nine tests (R/I/shift/U/J/branch/load/store/final integration), and report pass/fail for each.

## Notes
- Instruction memory is preloaded via `$readmemh` in the testbench; data memory initializes to `0xFF` to simplify expected load values.
- The final integration program (`tb/test_final.hex`) combines most instructions and validates both register results and memory side effects.
