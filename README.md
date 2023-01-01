# RISC-V CPU
An experimental RISC-V CPU designed in VHDL for the Digilent Arty A7.

## Running Rust
Modify sample_prog
```
./rust.sh
cp out/out.coe riscv_cpu.srcs/sources_1/rom.coe
vivado -mode tcl -source regen_rom.tcl
```

## Running Assembly
To run assembly, first the assembly has to be assembled, linked, and converted into a Xilinx
coefficients file format. This can be done by running:

```
./build.sh
```
The coefficient file will now be in `out/out.coe`.

Copy the file into the Xilinx project sources:
```
cp out/out.coe riscv_cpu.srcs/sources_1/rom.coe
```

Regenerate the Block ROM IP:
```
vivado -mode tcl -source regen_rom.tcl
```

When you run the simulation, it should run the expected assembly.

## Resources
This project is heavily inspired by Bruno Levy's work on RISC-V processors:
[Bruno Levy](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV/README.md)

[RISC-V Unprivileged Specification](https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf)
