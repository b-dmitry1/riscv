# li pseudo-instruction

        j       factorial

        li      t0, 0x123
        li      t1, 0x12345678
        li      t2, 0x12345000
        li      t3, -0x123

# RISC-V fibonacci program
#
# Stanislav Zhelnio, 2020
# Amended by Yuri Panchul, 2024

fibonacci:

        mv      a0, zero
        li      t0, 1

loop:   add     t1, a0, t0
        mv      a0, t0
        mv      t0, t1

# We use b instead of beqz

#       beqz    zero, loop
	sw      a0, 0x210(t2)
        j       loop

# RISC-V factorial program
# Uncomment it when necessary

factorial:

         li      a0, 1
         li      t0, 2

floop:   mul     a0, a0, t0
	 sw      a0, 0x210(t2)
         addi    t0, t0, 1
         j       floop
