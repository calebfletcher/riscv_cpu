.global _start

.text

_start:
    li a0, 0

loop:
    addi a0, a0, 1
    call wait
    j loop

wait:
    li a1, 1
    slli a1, a1, 4
wait_loop:
    addi a1, a1, -1
    bnez a1, wait_loop
    ret
