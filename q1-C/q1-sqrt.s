.data
    # ======= Constants =======
    BF16_SIGN_MASK: .half 0x8000
    BF16_EXP_MASK:  .half 0x7F80
    BF16_MANT_MASK: .half 0x007F
    BF16_EXP_BIAS:  .half 127
    BF16_NAN:   .half 0x7FC0
    BF16_ZERO:  .half 0x0000

    # ======= Common Messages =======
    nl:         .string "\n"
    msg_case:   .string "Test case "
    msg_input:  .string "Input: "
    msg_output: .string "Output: "
    msg_expect: .string "Expect: "
    msg_ok:     .string "✅ Correct\n"
    msg_wrong:  .string "❌ Wrong\n"

    # ======= SQRT Test Labels =======
    msg_sqrt:   .string "\n=== BF16 SQRT TESTS ===\n"
    msg0:       .string "sqrt(0.0) = "
    msg1:       .string "sqrt(1.0) = "
    msg2:       .string "sqrt(4.0) = "
    msg3:       .string "sqrt(9.0) = "
    msg4:       .string "sqrt(-1.0) = "
    msg5:       .string "sqrt(+Inf) = "
    msg6:       .string "sqrt(-Inf) = "
    msg7:       .string "sqrt(0.25) = "
    msg8:       .string "sqrt(16.0) = "
    msg9:       .string "sqrt(2.0) = "

    # ======= Test Inputs =======
    val0:   .half 0x0000     # 0.0
    val1:   .half 0x3F80     # 1.0
    val2:   .half 0x4080     # 4.0
    val3:   .half 0x4110     # 9.0
    val4:   .half 0xBF80     # -1.0
    val5:   .half 0x7F80     # +Inf
    val6:   .half 0xFF80     # -Inf
    val7:   .half 0x3E80     # 0.25
    val8:   .half 0x4180     # 16.0
    val9:   .half 0x4000     # 2.0

    # ======= Expected Outputs =======
    sqrt_expect: .half 0x0000, 0x3F80, 0x4000, 0x4040, 0x7FC0, 0x7F80, 0x7FC0, 0x3F00, 0x4080, 0x3FB5

.text
.global main
main:
    li      s0, 255
    lui     t0, 0x8
    addi    s11, t0, -0x80           # s11 = 0x7F80 (Inf mask)

    # ==== Print Header ====
    la      a0, msg_sqrt
    li      a7, 4
    ecall
    
# =======================================================
# Test 0: sqrt(0.0)
# =======================================================
    la      a0, msg0
    li      a7, 4
    ecall
    la      a0, val0
    lh      a0, 0(a0)
    jal     ra, bf16_sqrt
    mv      t5, a0
    la      a1, sqrt_expect
    li      a2, 0
    mv      a0, t5
    jal     ra, compare_result

# =======================================================
# Test 1: sqrt(1.0)
# =======================================================
    la      a0, msg1
    li      a7, 4
    ecall
    la      a0, val1
    lh      a0, 0(a0)
    jal     ra, bf16_sqrt
    mv      t5, a0
    la      a1, sqrt_expect
    li      a2, 1
    mv      a0, t5
    jal     ra, compare_result

# =======================================================
# Test 2: sqrt(4.0)
# =======================================================
    la      a0, msg2
    li      a7, 4
    ecall
    la      a0, val2
    lh      a0, 0(a0)
    jal     ra, bf16_sqrt
    mv      t5, a0
    la      a1, sqrt_expect
    li      a2, 2
    mv      a0, t5
    jal     ra, compare_result

# =======================================================
# Test 3: sqrt(9.0)
# =======================================================
    la      a0, msg3
    li      a7, 4
    ecall
    la      a0, val3
    lh      a0, 0(a0)
    jal     ra, bf16_sqrt
    mv      t5, a0
    la      a1, sqrt_expect
    li      a2, 3
    mv      a0, t5
    jal     ra, compare_result

# =======================================================
# Test 4: sqrt(-1.0)
# =======================================================
    la      a0, msg4
    li      a7, 4
    ecall
    la      a0, val4
    lh      a0, 0(a0)
    jal     ra, bf16_sqrt
    mv      t5, a0
    la      a1, sqrt_expect
    li      a2, 4
    mv      a0, t5
    jal     ra, compare_result

# =======================================================
# Test 5: sqrt(+Inf)
# =======================================================
    la      a0, msg5
    li      a7, 4
    ecall
    la      a0, val5
    lh      a0, 0(a0)
    jal     ra, bf16_sqrt
    mv      t5, a0
    la      a1, sqrt_expect
    li      a2, 5
    mv      a0, t5
    jal     ra, compare_result

# =======================================================
# Test 6: sqrt(-Inf)
# =======================================================
    la      a0, msg6
    li      a7, 4
    ecall
    la      a0, val6
    lh      a0, 0(a0)
    jal     ra, bf16_sqrt
    mv      t5, a0

    la      a1, sqrt_expect
    li      a2, 6
    mv      a0, t5
    jal     ra, compare_result

# =======================================================
# Test 7: sqrt(0.25)
# =======================================================
    la      a0, msg7
    li      a7, 4
    ecall
    la      a0, val7
    lh      a0, 0(a0)
    jal     ra, bf16_sqrt
    mv      t5, a0
    la      a1, sqrt_expect
    li      a2, 7
    mv      a0, t5
    jal     ra, compare_result

# =======================================================
# Test 8: sqrt(16.0)
# =======================================================
    la      a0, msg8
    li      a7, 4
    ecall
    la      a0, val8
    lh      a0, 0(a0)
    jal     ra, bf16_sqrt
    mv      t5, a0
    la      a1, sqrt_expect
    li      a2, 8
    mv      a0, t5
    jal     ra, compare_result

# =======================================================
# Test 9: sqrt(2.0)
# =======================================================
    la      a0, msg9
    li      a7, 4
    ecall
    la      a0, val9
    lh      a0, 0(a0)
    jal     ra, bf16_sqrt
    mv      t5, a0
    la      a1, sqrt_expect
    li      a2, 9
    mv      a0, t5
    jal     ra, compare_result

# =======================================================
# End of Program
# =======================================================
    li      a7, 10
    ecall

# =======================================================
# compare_result(a0, expect_addr, idx)
# =======================================================
# compare_result(a0, expect_addr, idx)
# a0 = actual result (16-bit)
# a1 = address of the expected value table
# a2 = test case index (0-based)
# =======================================================
compare_result:
    addi    sp, sp, -16
    sw      t0, 0(sp)
    sw      t1, 4(sp)
    sw      t2, 8(sp)
    sw      t3, 12(sp)

    mv      t0, a0                 
    slli    t1, a2, 1              
    add     t2, a1, t1
    lhu     t3, 0(t2)             
    li      t4, 0xFFFF               
    and     t0, t0, t4              
    and     t3, t3, t4
    la      a0, nl
    li      a7, 4
    ecall
    # ---- Output (hex) ----
    la      a0, msg_output
    li      a7, 4
    ecall
    mv      a0, t0
    li      a7, 34                   
    ecall
    la      a0, nl
    li      a7, 4
    ecall
    # ---- Expect (hex) ----
    la      a0, msg_expect
    li      a7, 4
    ecall
    mv      a0, t3
    li      a7, 34
    ecall
    la      a0, nl
    li      a7, 4
    ecall
    # ---- Compare ----
    beq     t0, t3, print_ok
    la      a0, msg_wrong
    li      a7, 4
    ecall
    j       done
print_ok:
    la      a0, msg_ok
    li      a7, 4
    ecall
done:
    lw      t0, 0(sp)
    lw      t1, 4(sp)
    lw      t2, 8(sp)
    lw      t3, 12(sp)
    addi    sp, sp, 16
    ret

# ============================================================
# Function: bf16_sqrt
# Input : a0 (BF16 value)
# Output: a0 (sqrt result)
# ============================================================
bf16_sqrt:
    srai    s1, a0, 15
    andi    s1, s1, 1                   
    srai    s2, a0, 7
    and     s2, s2, s0                  
    andi    s3, a0, 0x7F                
    beq     s2, s0, Handle_special_cases
    beqz    s2, sqrt_check_mant
    bnez    s1, return_nan 
    beqz    s2, return_zero
    la      s4, BF16_EXP_BIAS
    lh      s4, 0(s4)                   
    sub     t0, s2, s4                  
    ori     t2, s3, 0x80                
    andi    t3, t0, 1
    bnez    t3, Adjust_for_odd_exponents
    srai    t3, t0, 1
    add     t1, t3, s4                  

# Binary search: find integer sqrt(mantissa)
low_high_result:
    li      s5, 90                     
    li      s6, 256                     
    li      s7, 128                     
Binary_search_loop:
    bgt     s5, s6, out_Binary_Search
    add     t3, s5, s6
    srli    t3, t3, 1                   
    addi    sp, sp, -12
    sw      a0, 0(sp)
    sw      a1, 4(sp)
    sw      ra, 8(sp)
    mv      a0, t3
    mv      a1, t3
    jal     ra, multiply8
    mv      t4, a0                      
    lw      a0, 0(sp)
    lw      a1, 4(sp)
    lw      ra, 8(sp)
    addi    sp, sp, 12
    srli    t4, t4, 7                  
    ble     t4, t2, binary_search_if
    addi    s6, t3, -1                  
    j       Binary_search_loop
binary_search_if:
    add     s7, t3, x0                  
    addi    s5, t3, 1                   
    j       Binary_search_loop

# Post-processing after binary search
out_Binary_Search:
    li      t3, 256
    bge     s7, t3, result_greater_256
    li      t3, 128  
    blt     s7, t3, result_less_128
Extract_7_bit_mantissa:
    andi    t3, s7, 0x7F
    bge     t1, s0, sqrt_overflow
    ble     t1, zero, return_zero
    and     a0, t1, s0
    slli    a0, a0, 7
    or      a0, a0, t3
    ret

# Special / edge case handlers
Handle_special_cases:
    bnez    s3, return_a
    bnez    s1, return_nan
    j       return_a
sqrt_check_mant:
    beqz    s3, return_zero
Adjust_for_odd_exponents:
    slli    t2, t2, 1
    addi    t3, t0, -1
    srai    t3, t3, 1
    add     t1, t3, s4
    j       low_high_result

# Handle result normalization
result_greater_256:
    srli    s7, s7, 1
    addi    t1, t1, 1
    j       Extract_7_bit_mantissa
result_less_128:
    li      t3, 128 
    blt     s7, t3, sqrt_check_new_exp
    j       Extract_7_bit_mantissa
sqrt_check_new_exp:
    li      t3, 1
    bgt     t1, t3, sqrt_while_loop_2
    j       Extract_7_bit_mantissa
sqrt_while_loop_2:
    slli    s7, s7, 1
    addi    t1, t1, -1
    j       result_less_128
sqrt_overflow:
    add     a0, zero, s11
    ret

# Return helper sections
return_zero:
    la      t6, BF16_ZERO
    lh      a0, 0(t6)
    ret 
return_nan:
    la      t6, BF16_NAN
    lh      a0, 0(t6)
    ret  
return_a:
    ret             
return_b:
    add     a0, a1, zero        
    ret
# ============================================================
# multiply8: Egyptian Multiplication
# Input : a0=a, a1=b
# Output: a0=a*b (16-bit result)
# ============================================================
multiply8:
    mv      s10, a0
    mv      s9,  a1
    li      a0, 0
mul_loop:
    beqz    s9, mul_done
    andi    s8, s9, 1
    beqz    s8, skip_add
    add     a0, a0, s10
skip_add:
    slli    s10, s10, 1
    srli    s9,  s9, 1
    j       mul_loop
mul_done:
    ret

