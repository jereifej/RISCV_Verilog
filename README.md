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

## Compile C to RV64I Assembly
- Install a cross toolchain (WSL/Ubuntu examples):
  - Bare metal: `sudo apt-get update && sudo apt-get install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf libnewlib-dev`
  - Linux target (fallback if bare-metal headers/libs are missing): `sudo apt-get install gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu`
- Build from the repo root: `bash tools/build_riscv.sh path/to/file.c [output_prefix]`
- The script:
  - Uses `tools/runtime/start.S` to seed `sp` to `0x100` and call `main` (no libc needed).
  - Produces `[output_prefix].elf`, `[output_prefix].s` (for the C file), `[output_prefix].bin`, and `[output_prefix].hex` (word-per-line for `$readmemh`).
  - Falls back to `riscv64-linux-gnu-gcc` if the bare-metal compiler is absent and adds `/usr/include/newlib` automatically when present.

## Run a compiled C program in simulation
Example (run from repo root, using the provided testbench):
```sh
bash tools/build_riscv.sh examples/add.c examples/add
iverilog -g2012 -s add_program_tb -o tb/add_program_tb.vvp \
  -I source -I ALU/source -I Memory/source -I Register_File/source \
  tb/add_program_tb.v source/riscv_single_cycle.v source/instruction_memory.v \
  source/immediate_generator.v source/pc_update.v source/control_fsm.v \
  ALU/source/ALU.v ALU/source/alu_control.v ALU/source/add2.v ALU/source/and2.v \
  ALU/source/or2.v ALU/source/xor2.v ALU/source/sll.v ALU/source/srl.v ALU/source/sra.v ALU/source/slt.v \
  Memory/source/data_mem64.v Register_File/source/regfile64.v Register_File/source/reg64.v
vvp tb/add_program_tb.vvp
```
- Override the program at runtime: `vvp tb/add_program_tb.vvp +HEX=path/to/other.hex`
- Add `-DADD_TB_TRACE` to the `iverilog` command for per-cycle tracing.

### WSL (run from PowerShell)
```powershell
wsl -e bash -lc "
  cd /mnt/c/Users/ereij/OneDrive/Documents/PostGrad/RISCV_Verilog &&
  bash tools/build_riscv.sh examples/add.c examples/add &&
  iverilog -g2012 -s add_program_tb -o tb/add_program_tb.vvp \
    -I source -I ALU/source -I Memory/source -I Register_File/source \
    tb/add_program_tb.v source/riscv_single_cycle.v source/instruction_memory.v \
    source/immediate_generator.v source/pc_update.v source/control_fsm.v \
    ALU/source/ALU.v ALU/source/alu_control.v ALU/source/add2.v ALU/source/and2.v \
    ALU/source/or2.v ALU/source/xor2.v ALU/source/sll.v ALU/source/srl.v ALU/source/sra.v ALU/source/slt.v \
    Memory/source/data_mem64.v Register_File/source/regfile64.v Register_File/source/reg64.v
"
wsl -e bash -lc "cd /mnt/c/Users/ereij/OneDrive/Documents/PostGrad/RISCV_Verilog && vvp tb/add_program_tb.vvp"
```
Use `+HEX=path/to/your.hex` on the `vvp` command to point at a different compiled program.
