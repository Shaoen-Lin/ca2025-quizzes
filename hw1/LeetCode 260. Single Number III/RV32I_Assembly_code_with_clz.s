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
    li      s3, 3
    li      s4, 1

loop_cases:
    beqz    s3, end_main

    # load current pointers
    lw      s0, 0(s5)
    lw      s1, 0(s6)
    lw      s2, 0(s7)

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
    mv      t6, a0

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
# Count Leading Zeros (clz)
# a0 = input, return a0 = clz(x)
##################################
clz:
    li      s0, 32
    li      s1, 16
clz_loop:
    srl     t0, a0, s1
    bnez    t0, clz_if
    srli    s1, s1, 1
    j       clz_check
clz_if:
    sub     s0, s0, s1
    mv      a0, t0
clz_check:
    bnez    s1, clz_loop
    sub     a0, s0, a0
    ret


##################################
# singleNumber
# a0 = nums ptr, a1 = size, a2 = &returnSize
# return a0 = &result
##################################
singleNumber:
    li      s2, 0
    li      t0, 0

# first loop: xor all numbers
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
    sll     s4, t1, s3        # mask = 1U << shift
    li      t1, 0             # a = 0
    li      t2, 0             # b = 0
    li      t0, 0
    j       for2_cond

for1_body:
    slli    t1, t0, 2
    add     t1, a0, t1
    lw      t1, 0(t1)
    xor     s2, s2, t1
    addi    t0, t0, 1
    j       for1_cond

# second loop: split by mask bit
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
