.data
    # ==== Three test cases ====
    nums1:          .word   2, 2, 3, 3, 4, 4, 0, 1, 100, 100, 99, 99
    nums1_size:     .word   12
    ans1:           .word   1, 0

    nums2:          .word   101, 17, 102, 102, -98, 0, 1, 101, 0, 1, 99, -98, 100, 17
    nums2_size:     .word   14
    ans2:           .word   99, 100

    nums3:          .word   -2, -2, -2, 2, 2, 2, -6, -9, -2, 2, 2, -5, 2, -6, -2, -10, -11, -10, -11, -2, -6, -9
    nums3_size:     .word   22
    ans3:           .word   -5, -6

    # === Pointer tables ===
    test_cases:     .word   nums1, nums2, nums3
    test_sizes:     .word   nums1_size, nums2_size, nums3_size
    test_ans:       .word   ans1, ans2, ans3

    ressize:        .word   0
    result:         .word   0, 0

    # ===== Display strings =====
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

# =====================================================
# main: iterate through three test cases for singleNumber
# =====================================================
main:
    # Setup iterators for the three pointer tables
    la      s5, test_cases
    la      s6, test_sizes
    la      s7, test_ans

    li      s3, 3                       # total test cases
    li      s4, 1                       # current case index (1-based)

loop_cases:
    beqz    s3, end_main

    # Load current case pointers
    lw      s0, 0(s5)                   # s0 = &nums
    lw      s1, 0(s6)                   # s1 = &size
    lw      s2, 0(s7)                   # s2 = &expected answer

    # Print "Test case i"
    la      a0, msg_case
    li      a7, 4
    ecall
    mv      a0, s4
    li      a7, 1
    ecall
    la      a0, nl
    li      a7, 4
    ecall

    # Print input array
    la      a0, msg_input
    li      a7, 4
    ecall

    lw      t3, 0(s1)
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

    # Save caller-saved registers
    addi    sp, sp, -24
    sw      ra, 20(sp)
    sw      s0, 16(sp)
    sw      s1, 12(sp)
    sw      s2, 8(sp)
    sw      s3, 4(sp)
    sw      s4, 0(sp)

    # Call singleNumber(nums, size, &ressize)
    mv      a0, s0
    lw      a1, 0(s1)
    la      a2, ressize
    jal     singleNumber
    mv      t6, a0

    # Restore saved registers
    lw      ra, 20(sp)
    lw      s0, 16(sp)
    lw      s1, 12(sp)
    lw      s2, 8(sp)
    lw      s3, 4(sp)
    lw      s4, 0(sp)
    addi    sp, sp, 24

    # Print output
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

    # Print expected answer
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

    # Check correctness
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


# =====================================================
# function: singleNumber
# input:  a0 = pointer to nums, a1 = numsSize, a2 = returnSize
# output: a0 = pointer to integer array
# =====================================================
singleNumber:
    li      s2, 0
    li      t0, 0

# First loop: XOR all numbers
for_loop_1:
    bge     t0, a1, after_for_1
    slli    t1, t0, 2
    add     t1, a0, t1
    lw      t1, 0(t1)
    xor     s2, s2, t1
    addi    t0, t0, 1
    j       for_loop_1

after_for_1:
    # diff_bit = xor_all & (-xor_all)
    neg     t0, s2
    and     s4, s2, t0

    li      t1, 0
    li      t2, 0
    li      t0, 0

# Second loop: XOR numbers into two groups
for_loop_2:
    bge     t0, a1, done
    slli    t3, t0, 2
    add     t3, a0, t3
    lw      t3, 0(t3)

    and     t4, t3, s4
    beqz    t4, else_part
    xor     t1, t1, t3
    j       inc_i

else_part:
    xor     t2, t2, t3
inc_i:
    addi    t0, t0, 1
    j       for_loop_2

# Store result [a, b] and return
done:
    la      a0, result
    sw      t1, 0(a0)
    sw      t2, 4(a0)
    li      t3, 2
    sw      t3, 0(a2)
    ret
