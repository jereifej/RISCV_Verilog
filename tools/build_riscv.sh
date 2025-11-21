#!/usr/bin/env bash
set -euo pipefail

# Compile a C file to RV64I assembly, ELF, flat binary, and word-per-line hex.
# A tiny runtime stub (tools/runtime/start.S) sets up SP and calls main.
# Usage: ./tools/build_riscv.sh path/to/file.c [output_prefix]

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <input.c> [output_prefix]" >&2
  exit 1
fi

cc=${RISCV_CC:-riscv64-unknown-elf-gcc}
# If the preferred CC is missing, fall back to the Linux-target cross toolchain for easier setup.
if ! command -v "$cc" >/dev/null 2>&1; then
  if command -v riscv64-linux-gnu-gcc >/dev/null 2>&1; then
    cc=riscv64-linux-gnu-gcc
  fi
fi
input=$1
prefix=${2:-out}
arch_flags="-march=rv64i -mabi=lp64"
include_flags=""
objcopy_cmd=""
runtime_stub="$(cd "$(dirname "$0")"/.. && pwd)/tools/runtime/start.S"

if ! command -v "$cc" >/dev/null 2>&1; then
  echo "Error: $cc not found. Install a RISC-V cross toolchain (riscv64-unknown-elf-gcc)." >&2
  exit 1
fi

# Some distros ship bare-metal headers under /usr/include/newlib; add it if present.
if [[ -d /usr/include/newlib ]]; then
  include_flags="-isystem /usr/include/newlib"
fi

echo "Using compiler: $cc"
echo "Compiling $input -> $prefix.elf"

# Detect objcopy matching the compiler prefix
case "$cc" in
  *-gcc) objcopy_cmd="${cc%-gcc}-objcopy" ;;
esac
if ! command -v "$objcopy_cmd" >/dev/null 2>&1; then
  # Fallback to common names
  if command -v riscv64-unknown-elf-objcopy >/dev/null 2>&1; then
    objcopy_cmd="riscv64-unknown-elf-objcopy"
  elif command -v riscv64-linux-gnu-objcopy >/dev/null 2>&1; then
    objcopy_cmd="riscv64-linux-gnu-objcopy"
  else
    echo "Error: objcopy for RISC-V not found." >&2
    exit 1
  fi
fi

if [[ ! -f "$runtime_stub" ]]; then
  echo "Error: runtime stub not found at $runtime_stub" >&2
  exit 1
fi

# Build: freestanding, no libc, fixed text at 0x0 so the hex aligns with imem
"$cc" $arch_flags $include_flags -O2 -nostdlib -nostartfiles -ffreestanding \
  -Wl,-Ttext=0 -Wl,--no-relax \
  "$runtime_stub" "$input" -o "$prefix.elf"

# Emit assembly for inspection
"$cc" $arch_flags $include_flags -O2 -S "$input" -o "$prefix.s"

# Convert to flat binary and word-per-line hex
"$objcopy_cmd" -O binary "$prefix.elf" "$prefix.bin"
od -An -tx4 -v "$prefix.bin" | sed 's/^ *//' | tr ' ' '\n' | sed '/^$/d' > "$prefix.hex"

echo "Done."
