.global _start

.data
value:
    .word 0xa5b6d7e8

.text
_start:
    la x1, value
    li x9, 0xdeadbeef
    sw x9, 0(x1)
    lw x2, 0(x1)
    lhu x3, 0(x1)
    lhu x4, 2(x1)
    lbu x5, 0(x1)
    lbu x6, 1(x1)
    lbu x7, 2(x1)
    lbu x8, 3(x1)
    ebreak
