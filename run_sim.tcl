open_project riscv_cpu

# Set memory initialisation file
set_property CONFIG.Coe_File {../../../../test_files/rom.coe} [get_ips blk_mem_gen_0]
reset_target all [get_ips blk_mem_gen_0]
generate_target -force all [get_ips blk_mem_gen_0]

# Run simulation
launch_simulation
run 100us

# Save results
for {set i 0} {$i < 32} {incr i} {
    set registers($i) [get_value -radix dec /tb_top/top/s_registers[$i]]
}

# Restore memory initialisation file
set_property CONFIG.Coe_File {../../rom.coe} [get_ips blk_mem_gen_0]
reset_target all [get_ips blk_mem_gen_0]
generate_target -force all [get_ips blk_mem_gen_0]

# Check results
array set expected {
    0 0
    1 63
    2 4
    3 -67108864
    4 0
    5 0
    6 0
    7 0
    8 0
    9 0
    10 0
    11 0
    12 0
    13 0
    14 0
    15 0
    16 0
    17 0
    18 0
    19 0
    20 0
    21 0
    22 0
    23 0
    24 0
    25 0
    26 0
    27 0
    28 0
    29 0
    30 0
    31 0
}

for {set i 0} {$i < 32} {incr i} {
    if {$registers($i) != $expected($i)} {
        puts stderr [format "invalid: reg %d has value %d, expected %d" $i $registers($i) $expected($i)]
        quit 1
    }
}

quit 0
