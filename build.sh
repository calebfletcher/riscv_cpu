#!/usr/bin/env bash
set -eux

mkdir -p out
(
cd out
riscv32-unknown-elf-as ../mem.asm -o assembled.out
riscv32-unknown-elf-ld assembled.out -o linked.out -T ../linker.ld
riscv32-unknown-elf-objdump -d linked.out
riscv32-unknown-elf-objcopy -O binary linked.out raw.out

cat << EOF > out.coe
memory_initialization_radix=16;
memory_initialization_vector=
EOF

xxd -e -c 4 raw.out | cut -c11-19 >> out.coe
)
