open_project riscv_cpu

# Restore memory initialisation file
set_property CONFIG.Coe_File {../../rom.coe} [get_ips blk_mem_gen_0]
reset_target all [get_ips blk_mem_gen_0]
generate_target -force all [get_ips blk_mem_gen_0]

quit 0
