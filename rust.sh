#!/usr/bin/env bash
set -eux

mkdir -p out
(
cd out
riscv32-unknown-elf-objcopy -O binary ../sample_prog/target/riscv32i-unknown-none-elf/debug/sample_prog raw.out

cat << EOF > out.coe
memory_initialization_radix=16;
memory_initialization_vector=
EOF

xxd -e -c 4 raw.out | cut -c11-19 >> out.coe
)
