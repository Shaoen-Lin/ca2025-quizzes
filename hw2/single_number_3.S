.section .data
.align 2
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

.section .rodata
.align 2
    msg_case:   .ascii "Test case "
    .set msg_case_size, . - msg_case

    msg_input:  .ascii "  Input: "
    .set msg_input_size, . - msg_input

    msg_output: .ascii "  Output: "
    .set msg_output_size, . - msg_output

    msg_expect: .ascii "  Expect: "
    .set msg_expect_size, . - msg_expect

    msg_ok:     .ascii "  PASSED\n"
    .set msg_ok_size, . - msg_ok

    msg_wrong:  .ascii "  FAILED\n"
    .set msg_wrong_size, . - msg_wrong

    space:      .ascii " "
    .set space_size, . - space

    nl:         .ascii "\n"
    .set nl_size, . - nl


.section .text
.align 4
.global single_number_3
single_number_3:
    addi    sp, sp, -36
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    sw      s3, 16(sp)
    sw      s4, 20(sp)
    sw      s5, 24(sp)
    sw      s6, 28(sp)
    sw      s7, 32(sp)

    la      s5, test_cases
    la      s6, test_sizes
    la      s7, test_ans
    li      s3, 3
    li      s4, 1

loop_cases:
    beqz    s3, end_main

    lw      s0, 0(s5)
    lw      s1, 0(s6)
    lw      s2, 0(s7)

    # === print "Test case " ===
    li      a0, 1
    la      a1, msg_case
    li      a2, msg_case_size
    li      a7, 64
    ecall

    # === print case number ===
    mv      a0, s4
    jal     ra, print_int

    # === newline ===
    li      a0, 1
    la      a1, nl
    li      a2, nl_size
    li      a7, 64
    ecall

    # === print "Input: " ===
    li      a0, 1
    la      a1, msg_input
    li      a2, msg_input_size
    li      a7, 64
    ecall

    lw      t3, 0(s1)
    li      t4, 0
print_input_loop:
    bge     t4, t3, print_input_done
    slli    t5, t4, 2
    add     t6, s0, t5
    lw      a0, 0(t6)
    jal     ra, print_int
    
    li      a0, 1
    la      a1, space
    li      a2, space_size
    li      a7, 64
    ecall
    
    addi    t4, t4, 1
    j       print_input_loop

print_input_done:
    li      a0, 1
    la      a1, nl
    li      a2, nl_size
    li      a7, 64
    ecall

    # save registers before call
    addi    sp, sp, -24
    sw      ra, 20(sp)
    sw      s0, 16(sp)
    sw      s1, 12(sp)
    sw      s2, 8(sp)
    sw      s3, 4(sp)
    sw      s4, 0(sp)

    mv      a0, s0
    lw      a1, 0(s1)
    la      a2, ressize
    jal     singleNumber
    mv      t6, a0

    # restore
    lw      ra, 20(sp)
    lw      s0, 16(sp)
    lw      s1, 12(sp)
    lw      s2, 8(sp)
    lw      s3, 4(sp)
    lw      s4, 0(sp)
    addi    sp, sp, 24

    # === Output ===
    li      a0, 1
    la      a1, msg_output
    li      a2, msg_output_size
    li      a7, 64
    ecall

    lw      t0, 0(t6)
    mv      a0, t0
    jal     ra, print_int

    li      a0, 1
    la      a1, space
    li      a2, space_size
    li      a7, 64
    ecall

    lw      t1, 4(t6)
    mv      a0, t1
    jal     ra, print_int

    li      a0, 1
    la      a1, nl
    li      a2, nl_size
    li      a7, 64
    ecall

    # === Expect ===
    li      a0, 1
    la      a1, msg_expect
    li      a2, msg_expect_size
    li      a7, 64
    ecall
    
    lw      t2, 0(s2)
    mv      a0, t2
    jal     ra, print_int

    li      a0, 1
    la      a1, space
    li      a2, space_size
    li      a7, 64
    ecall

    lw      t3, 4(s2)
    mv      a0, t3
    jal     ra, print_int

    li      a0, 1
    la      a1, nl
    li      a2, nl_size
    li      a7, 64
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
    li      a0, 1
    la      a1, msg_ok
    li      a2, msg_ok_size
    li      a7, 64
    ecall
    j       next_case

print_wrong:
    li      a0, 1
    la      a1, msg_wrong
    li      a2, msg_wrong_size
    li      a7, 64
    ecall

next_case:
    addi    s5, s5, 4
    addi    s6, s6, 4
    addi    s7, s7, 4
    addi    s4, s4, 1
    addi    s3, s3, -1
    j       loop_cases

end_main:
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      s3, 16(sp)
    lw      s4, 20(sp)
    lw      s5, 24(sp)
    lw      s6, 28(sp)
    lw      s7, 32(sp)
    addi    sp, sp, 36
    ret


# =====================================================
# print_int(a0)
# =====================================================
.global print_int
print_int:
    addi    sp, sp, -92
    sw      ra, 88(sp)
    sw      t0, 84(sp)
    sw      t1, 80(sp)
    sw      t2, 76(sp)
    sw      t3, 72(sp)
    sw      t4, 68(sp)
    sw      t5, 64(sp)
    
    mv      t0, a0
    addi    t1, sp, 64
    li      t2, 10
    li      t5, 0

    bltz    t0, make_positive
    j       convert_loop_i
make_positive:
    neg     t0, t0
    li      t5, 1

convert_loop_i:
    mv      t3, x0
sub_loop:
    blt     t0, t2, div_done
    sub     t0, t0, t2
    addi    t3, t3, 1
    j       sub_loop
div_done:
    mv      t4, t0
    mv      t0, t3
    addi    t4, t4, 48
    addi    t1, t1, -1
    sb      t4, 0(t1)
    bnez    t0, convert_loop_i

    beqz    t5, print_number_i
    addi    t1, t1, -1
    li      t3, '-'
    sb      t3, 0(t1)

print_number_i:
    li      a0, 1
    mv      a1, t1
    add     a2, sp, 64
    sub     a2, a2, t1
    li      a7, 64
    ecall

    lw      ra, 88(sp)
    lw      t0, 84(sp)
    lw      t1, 80(sp)
    lw      t2, 76(sp)
    lw      t3, 72(sp)
    lw      t4, 68(sp)
    lw      t5, 64(sp)
    addi    sp, sp, 92
    ret

##################################
# Count Leading Zeros (clz)
##################################
clz:
    li      t0, 32
    li      t1, 16
1:
    srl     t2, a0, t1
    bnez    t2, 2f
    srli    t1, t1, 1
    j       3f
2:
    sub     t0, t0, t1
    mv      a0, t2
3:
    bnez    t1, 1b
    mv      a0, t0
    ret


##################################
# singleNumber
##################################
singleNumber:
    li      s2, 0
    li      t0, 0
for1_cond:
    blt     t0, a1, for1_body
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
    li      t1, 0
    li      t2, 0
    li      t0, 0
    j       for2_cond

for1_body:
    slli    t1, t0, 2
    add     t1, a0, t1
    lw      t1, 0(t1)
    xor     s2, s2, t1
    addi    t0, t0, 1
    j       for1_cond

for2_cond:
    blt     t0, a1, for2_body
    la      a0, result
    sw      t1, 0(a0)
    sw      t2, 4(a0)
    li      t3, 2
    sw      t3, 0(a2)
    ret

for2_body:
    slli    t3, t0, 2
    add     t3, a0, t3
    lw      t3, 0(t3)
    and     t4, t3, s4
    bnez    t4, for2_if
    xor     t2, t2, t3
    j       for2_next
for2_if:
    xor     t1, t1, t3
for2_next:
    addi    t0, t0, 1
    j       for2_cond

