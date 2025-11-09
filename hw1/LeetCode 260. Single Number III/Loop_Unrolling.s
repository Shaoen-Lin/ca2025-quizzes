.data
    nums1:          .word   2, 2, 3, 3, 4, 4, 0, 1, 100, 100, 99, 99
    nums1_size:     .word   12
    ans1:           .word   1, 0

    nums2:          .word   101, 17, 102, 102, -98, 0, 1, 101, 0, 1, 99, -98, 100, 17
    nums2_size:     .word   14
    ans2:           .word   100, 99

    nums3:          .word   -2, -2, -2, 2, 2, 2, -6, -9, -2, 2, 2, -5, 2, -6, -2, -10, -11, -10, -11, -2, -6, -9
    nums3_size:     .word   22
    ans3:           .word   -5, -6

    test_cases:     .word   nums1, nums2, nums3
    test_sizes:     .word   nums1_size, nums2_size, nums3_size
    test_ans:       .word   ans1, ans2, ans3

    ressize:        .word   0
    result:         .word   0, 0

    msg_case:       .string "Test case "
    msg_input:      .string "Input: "
    msg_output:     .string "Output: "
    msg_expect:     .string "Expect: "
    msg_ok:         .string "✅ Correct\n"
    msg_wrong:      .string "❌ Wrong\n"
    space:          .string " "
    nl:             .string "\n"


.text
.global main
main:
    # initialize iterators for case tables
    la      s5, test_cases
    la      s6, test_sizes
    la      s7, test_ans

    li      s3, 3                       # total cases
    li      s4, 1                       # case index (1-based)

loop_cases:
    beqz    s3, end_main

    # load current pointers
    lw      s0, 0(s5)                   # s0 = nums ptr
    lw      s1, 0(s6)                   # s1 = size ptr
    lw      s2, 0(s7)                   # s2 = ans  ptr

    # print "Test case i"
    la      a0, msg_case
    li      a7, 4
    ecall
    mv      a0, s4
    li      a7, 1
    ecall
    la      a0, nl
    li      a7, 4
    ecall

    # print input array
    la      a0, msg_input
    li      a7, 4
    ecall

    lw      t3, 0(s1)                   # size
    li      t4, 0
print_input_loop:
    bge     t4, t3, print_input_done
    slli    t5, t4, 2
    add     t6, s0, t5
    lw      a0, 0(t6)
    li      a7, 1
    ecall
    la      a0, space
    li      a7, 4
    ecall
    addi    t4, t4, 1
    j       print_input_loop
print_input_done:
    la      a0, nl
    li      a7, 4
    ecall

    # save registers before call
    addi    sp, sp, -24
    sw      ra, 20(sp)
    sw      s0, 16(sp)
    sw      s1, 12(sp)
    sw      s2, 8(sp)
    sw      s3, 4(sp)
    sw      s4, 0(sp)

    # call singleNumber(a0=nums, a1=size, a2=&ressize)
    mv      a0, s0
    lw      a1, 0(s1)
    la      a2, ressize
    jal     singleNumber
    mv      t6, a0                       # t6 = &result

    # restore registers
    lw      ra, 20(sp)
    lw      s0, 16(sp)
    lw      s1, 12(sp)
    lw      s2, 8(sp)
    lw      s3, 4(sp)
    lw      s4, 0(sp)
    addi    sp, sp, 24

    # print output
    la      a0, msg_output
    li      a7, 4
    ecall

    lw      t0, 0(t6)
    mv      a0, t0
    li      a7, 1
    ecall
    la      a0, space
    li      a7, 4
    ecall

    lw      t1, 4(t6)
    mv      a0, t1
    li      a7, 1
    ecall
    la      a0, nl
    li      a7, 4
    ecall

    # print expected result
    la      a0, msg_expect
    li      a7, 4
    ecall

    lw      t2, 0(s2)
    mv      a0, t2
    li      a7, 1
    ecall
    la      a0, space
    li      a7, 4
    ecall

    lw      t3, 4(s2)
    mv      a0, t3
    li      a7, 1
    ecall
    la      a0, nl
    li      a7, 4
    ecall

    # compare results
    lw      t4, 0(t6)
    lw      t5, 4(t6)
    beq     t4, t2, check_second
    j       print_wrong
check_second:
    beq     t5, t3, print_ok
    j       print_wrong

print_ok:
    la      a0, msg_ok
    li      a7, 4
    ecall
    j       next_case

print_wrong:
    la      a0, msg_wrong
    li      a7, 4
    ecall

next_case:
    addi    s5, s5, 4
    addi    s6, s6, 4
    addi    s7, s7, 4
    addi    s4, s4, 1
    addi    s3, s3, -1
    j       loop_cases

end_main:
    li      a7, 10
    ecall


##################################
# Count Leading Zeros (unrolled)
# input : a0 = 32-bit unsigned
# output: a0 = #leading zeros
##################################
clz:
    addi    sp, sp, -16
    sw      s8,  0(sp)
    sw      s9,  4(sp)
    sw      s10, 8(sp)
    sw      s11,12(sp)

    beqz    a0, clz_zero
    li      s8, 32
    mv      s9, a0

    # (x >> 16)
    srli    s10, s9, 16
    beqz    s10, clz_chk8
    addi    s8, s8, -16
    mv      s9, s10
clz_chk8:
    # (x >> 8)
    srli    s10, s9, 8
    beqz    s10, clz_chk4
    addi    s8, s8, -8
    mv      s9, s10
clz_chk4:
    # (x >> 4)
    srli    s10, s9, 4
    beqz    s10, clz_chk2
    addi    s8, s8, -4
    mv      s9, s10
clz_chk2:
    # (x >> 2)
    srli    s10, s9, 2
    beqz    s10, clz_chk1
    addi    s8, s8, -2
    mv      s9, s10
clz_chk1:
    # (x >> 1)
    srli    s10, s9, 1
    beqz    s10, clz_ret
    addi    s8, s8, -1
    mv      s9, s10

clz_ret:
    sub     a0, s8, s9
    lw      s8,  0(sp)
    lw      s9,  4(sp)
    lw      s10, 8(sp)
    lw      s11, 12(sp)
    addi    sp, sp, 16
    ret

clz_zero:
    li      a0, 32
    lw      s8,  0(sp)
    lw      s9,  4(sp)
    lw      s10, 8(sp)
    lw      s11, 12(sp)
    addi    sp, sp, 16
    ret


##################################
# singleNumber (loop unrolled)
# input : a0 = nums*, a1 = size, a2 = &returnSize
# output: a0 = &result
##################################
singleNumber:
    # first loop: XOR all numbers (unrolled ×4)
    li      s2, 0
    li      s1, 0
    mv      s0, a0

loop1_unroll4:
    addi    t2, s1, 4
    bgt     t2, a1, loop1_remainder

    lw      t3,  0(s0)
    lw      t4,  4(s0)
    lw      t5,  8(s0)
    lw      t6, 12(s0)
    xor     s2, s2, t3
    xor     s2, s2, t4
    xor     s2, s2, t5
    xor     s2, s2, t6

    addi    s0, s0, 16
    addi    s1, s1, 4
    j       loop1_unroll4

loop1_remainder:
    bge     s1, a1, after_loop1
loop1_rem_iter:
    bge     s1, a1, after_loop1
    lw      t3, 0(s0)
    xor     s2, s2, t3
    addi    s0, s0, 4
    addi    s1, s1, 1
    j       loop1_rem_iter

after_loop1:
    # compute mask bit
    li      t1, 31
    addi    sp, sp, -8
    sw      ra, 0(sp)
    sw      a0, 4(sp)
    mv      a0, s2
    jal     ra, clz
    sub     s3, t1, a0
    lw      a0, 4(sp)
    lw      ra, 0(sp)
    addi    sp, sp, 8

    li      t1, 1
    sll     s4, t1, s3

    # second loop: split by mask (unrolled ×4)
    li      t1, 0
    li      t2, 0
    li      s1, 0
    mv      s0, a0

loop2_unroll4:
    addi    t3, s1, 4
    bgt     t3, a1, loop2_remainder

    lw      t3,  0(s0)
    lw      t4,  4(s0)
    lw      t5,  8(s0)
    lw      t6, 12(s0)

    # element1
    and     t0, t3, s4
    beqz    t0, l2_e1
    xor     t1, t1, t3
    j       l2_n1
l2_e1:
    xor     t2, t2, t3
l2_n1:

    # element2
    and     t0, t4, s4
    beqz    t0, l2_e2
    xor     t1, t1, t4
    j       l2_n2
l2_e2:
    xor     t2, t2, t4
l2_n2:

    # element3
    and     t0, t5, s4
    beqz    t0, l2_e3
    xor     t1, t1, t5
    j       l2_n3
l2_e3:
    xor     t2, t2, t5
l2_n3:

    # element4
    and     t0, t6, s4
    beqz    t0, l2_e4
    xor     t1, t1, t6
    j       l2_n4
l2_e4:
    xor     t2, t2, t6
l2_n4:

    addi    s0, s0, 16
    addi    s1, s1, 4
    j       loop2_unroll4

loop2_remainder:
    bge     s1, a1, end_loop2
loop2_rem_iter:
    bge     s1, a1, end_loop2
    lw      t3, 0(s0)
    and     t0, t3, s4
    beqz    t0, l2_eR
    xor     t1, t1, t3
    j       l2_nR
l2_eR:
    xor     t2, t2, t3
l2_nR:
    addi    s0, s0, 4
    addi    s1, s1, 1
    j       loop2_rem_iter

end_loop2:
    la      a0, result
    sw      t1, 0(a0)
    sw      t2, 4(a0)
    li      t3, 2
    sw      t3, 0(a2)
    ret

