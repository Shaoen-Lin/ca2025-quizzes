.data
    BF16_SIGN_MASK:    .half   0x8000
    BF16_EXP_MASK:     .half   0x7F80
    BF16_MANT_MASK:    .half   0x007F
    BF16_EXP_BIAS:     .half   127
    BF16_NAN:          .half   0x7FC0
    BF16_ZERO:         .half   0x0000

    nl:                .string "\n"
    msg_case:          .string "Test case "
    msg_input:         .string "Input: "
    msg_output:        .string "Output: "
    msg_expect:        .string "Expect: "
    msg_ok:            .string "✅ Correct\n"
    msg_wrong:         .string "❌ Wrong\n"


    # ====== CONVERSION TEST String ======
    msg_conv1:         .string "\n=== BF16 -> F32 TESTS ===\n"
    msg_conv2:         .string "\n=== F32 -> BF16 TESTS ===\n"
    msg_add:           .string "\n=== BF16 ADD TESTS ===\n"
    msg_sub:           .string "\n=== BF16 SUB TESTS ===\n"
    msg_mul:           .string "\n=== BF16 MUL TESTS ===\n"
    msg_div:           .string "\n=== BF16 DIV TESTS ===\n"

    # ====== ADD String ======
    msg1:              .string "1.0 + 2.0 = "
    msg2:              .string "2.0 + (-2.0) = "
    msg3:              .string "inf + 1.0 = "
    msg4:              .string "inf + -inf = "
    msg5:              .string "NaN + 1.0 = "
    msg6:              .string "1.0 + 0.015625 = "

    # ====== SUB String ======
    msgs1:             .string "2.0 - 1.0 = "
    msgs2:             .string "5.0 - 2.0 = "
    msgs3:             .string "1.0 - 2.0 = "
    msgs4:             .string "(-2.0) - 3.0 = "
    msgs5:             .string "Inf - Inf = "
    msgs6:             .string "NaN - 1.0 = "
    msgs7:             .string "0.0 - 1.0 = "
    msgs8:             .string "1.0 - 0.0 = "

    # ====== MUL String ======
    msgm1:             .string "1.0 * 2.0 = "
    msgm2:             .string "0.5 * 0.5 = "
    msgm3:             .string "-1.0 * 3.0 = "
    msgm4:             .string "Inf * 2.0 = "
    msgm5:             .string "0 * 123.0 = "
    msgm6:             .string "Inf * 0 = "
    msgm7:             .string "NaN * 5.0 = "
    msgm8:             .string "subnormal * 2.0 = "

    # ====== DIV String ======
    msgd1:             .string "1.0 / 2.0 = "
    msgd2:             .string "2.0 / 1.0 = "
    msgd3:             .string "1.0 / 0.0 = "
    msgd4:             .string "0.0 / 1.0 = "
    msgd5:             .string "Inf / Inf = "
    msgd6:             .string "NaN / 1.0 = "
    msgd7:             .string "(-2.0) / 1.0 = "

    # ======= CONVERSION expected output =======
    conv_expect_b2f:   .word   0x3F800000, 0xC0000000     
    conv_expect_f2b:   .half   0x4060, 0xC194              
    # ======= ADD expected output =======
    add_expect:        .half   0x4040, 0x0000, 0x7F80, 0x7FC0, 0x7FC1, 0x3F80
    # ======= SUB expected output =======
    sub_expect:        .half   0x3F80, 0x4040, 0xBF80, 0xC0A0, 0x7FC0, 0x7FC0, 0xBF80, 0x3F80
    # ======= MUL expected output =======
    mul_expect:        .half   0x4000, 0x3E80, 0xC040, 0x7F80, 0x0000, 0x7FC0, 0x7FC1, 0x0000
    # ======= DIV expected output =======
    div_expect:        .half   0x3F00, 0x4000, 0x7F80, 0x0000, 0x7FC0, 0x7FC0, 0xC000
.text
.global main
main:
    li      s0, 255
    lui     t0, 0x8
    addi    s11, t0, -0x80               # s11 = 0x7F80 (Inf mask)

    # ------------------------------
    # BF16 -> F32 TESTS
    # ------------------------------
    la      a0, msg_conv1
    li      a7, 4
    ecall

    la      a0, msg_input
    li      a7, 4
    ecall
    li      a0, 0x3F80
    li      a7, 34
    ecall

    li      a0, 0x3F80
    jal     ra, bf16_to_f32
    mv      t0, a0

    la      a1, conv_expect_b2f
    li      a2, 0
    li      a3, 1               
    jal     ra, compare_result

    la      a0, msg_input
    li      a7, 4
    ecall
    li      a0, 0xC000
    li      a7, 34
    ecall

    li      a0, 0xC000
    jal     ra, bf16_to_f32
    mv      t0, a0

    la      a1, conv_expect_b2f
    li      a2, 1
    li      a3, 1
    jal     ra, compare_result
    
    # ------------------------------
    # F32 -> BF16 TESTS
    # ------------------------------
    la      a0, msg_conv2
    li      a7, 4
    ecall

    la      a0, msg_input
    li      a7, 4
    ecall
    li      a0, 0x40600000
    li      a7, 34
    ecall

    li      a0, 0x40600000
    jal     ra, f32_to_bf16
    mv      t0, a0

    la      a1, conv_expect_f2b
    li      a2, 0
    li      a3, 0               
    jal     ra, compare_result

    la      a0, msg_input
    li      a7, 4
    ecall
    li      a0, 0xC19447AE
    li      a7, 34
    ecall

    li      a0, 0xC19447AE
    jal     ra, f32_to_bf16
    mv      t0, a0

    la      a1, conv_expect_f2b
    li      a2, 1
    li      a3, 0
    jal     ra, compare_result

    # ------------------------------
    # ADD TEST
    # ------------------------------
    la      a0, msg_add
    li      a7, 4
    ecall

    la      a0, msg1
    li      a7, 4
    ecall
    li      a0, 0x3F80
    li      a1, 0x4000
    jal     ra, bf16_add
    la      a1, add_expect
    li      a2, 0
    jal     ra, compare_result

    la      a0, msg2
    li      a7, 4
    ecall
    li      a0, 0x4000
    li      a1, 0xC000
    jal     ra, bf16_add
    la      a1, add_expect
    li      a2, 1
    jal     ra, compare_result

    la      a0, msg3
    li      a7, 4
    ecall
    li      a0, 0x7F80
    li      a1, 0x3F80
    jal     ra, bf16_add
    la      a1, add_expect
    li      a2, 2
    jal     ra, compare_result

    la      a0, msg4
    li      a7, 4
    ecall
    li      a0, 0x7F80
    li      a1, 0xFF80
    jal     ra, bf16_add
    la      a1, add_expect
    li      a2, 3
    jal     ra, compare_result

    la      a0, msg5
    li      a7, 4
    ecall
    li      a0, 0x7FC1
    li      a1, 0x3F80
    jal     ra, bf16_add
    la      a1, add_expect
    li      a2, 4
    jal     ra, compare_result

    la      a0, msg6
    li      a7, 4
    ecall
    li      a0, 0x3F80
    li      a1, 0x3800
    jal     ra, bf16_add
    la      a1, add_expect
    li      a2, 5
    jal     ra, compare_result

    # ------------------------------
    # SUB TEST
    # ------------------------------
    la      a0, msg_sub
    li      a7, 4
    ecall

    la      a0, msgs1
    li      a7, 4
    ecall
    li      a0, 0x4000
    li      a1, 0x3F80
    jal     ra, bf16_sub
    la      a1, sub_expect
    li      a2, 0
    jal     ra, compare_result

    la      a0, msgs2
    li      a7, 4
    ecall
    li      a0, 0x40A0
    li      a1, 0x4000
    jal     ra, bf16_sub
    la      a1, sub_expect
    li      a2, 1
    jal     ra, compare_result

    la      a0, msgs3
    li      a7, 4
    ecall
    li      a0, 0x3F80
    li      a1, 0x4000
    jal     ra, bf16_sub
    la      a1, sub_expect
    li      a2, 2
    jal     ra, compare_result

    la      a0, msgs4
    li      a7, 4
    ecall
    li      a0, 0xC000
    li      a1, 0x4040
    jal     ra, bf16_sub
    la      a1, sub_expect
    li      a2, 3
    jal     ra, compare_result

    la      a0, msgs5
    li      a7, 4
    ecall
    li      a0, 0x7F80
    li      a1, 0x7F80
    jal     ra, bf16_sub
    la      a1, sub_expect
    li      a2, 4
    jal     ra, compare_result

    la      a0, msgs6
    li      a7, 4
    ecall
    li      a0, 0x7FC0
    li      a1, 0x3F80
    jal     ra, bf16_sub
    la      a1, sub_expect
    li      a2, 5
    jal     ra, compare_result

    la      a0, msgs7
    li      a7, 4
    ecall
    li      a0, 0x0000
    li      a1, 0x3F80
    jal     ra, bf16_sub
    la      a1, sub_expect
    li      a2, 6
    jal     ra, compare_result

    la      a0, msgs8
    li      a7, 4
    ecall
    li      a0, 0x3F80
    li      a1, 0x0000
    jal     ra, bf16_sub
    la      a1, sub_expect
    li      a2, 7
    jal     ra, compare_result

    # ------------------------------
    # MUL TEST
    # ------------------------------
    la      a0, msg_mul
    li      a7, 4
    ecall

    la      a0, msgm1
    li      a7, 4
    ecall
    li      a0, 0x3F80
    li      a1, 0x4000
    jal     ra, bf16_mul
	li 		a7, 34
    ecall
    la      a1, mul_expect
    li      a2, 0
    jal     ra, compare_result

    la      a0, msgm2
    li      a7, 4
    ecall
    li      a0, 0x3F00
    li      a1, 0x3F00
    jal     ra, bf16_mul
    la      a1, mul_expect
    li      a2, 1
    jal     ra, compare_result

    la      a0, msgm3
    li      a7, 4
    ecall
    li      a0, 0xBF80
    li      a1, 0x4040
    jal     ra, bf16_mul
    la      a1, mul_expect
    li      a2, 2
    jal     ra, compare_result

    la      a0, msgm4
    li      a7, 4
    ecall
    li      a0, 0x7F80
    li      a1, 0x4000
    jal     ra, bf16_mul
    la      a1, mul_expect
    li      a2, 3
    jal     ra, compare_result

    la      a0, msgm5
    li      a7, 4
    ecall
    li      a0, 0x0000
    li      a1, 0x42F6
    jal     ra, bf16_mul
    la      a1, mul_expect
    li      a2, 4
    jal     ra, compare_result

    la      a0, msgm6
    li      a7, 4
    ecall
    li      a0, 0x7F80
    li      a1, 0x0000
    jal     ra, bf16_mul
    la      a1, mul_expect
    li      a2, 5
    jal     ra, compare_result

    la      a0, msgm7
    li      a7, 4
    ecall
    li      a0, 0x7FC1
    li      a1, 0x40A0
    jal     ra, bf16_mul
    la      a1, mul_expect
    li      a2, 6
    jal     ra, compare_result

    la      a0, msgm8
    li      a7, 4
    ecall
    li      a0, 0x0001
    li      a1, 0x4000
    jal     ra, bf16_mul
    la      a1, mul_expect
    li      a2, 7
	jal ra, compare_result

    # ------------------------------
    # DIV TEST
    # ------------------------------
    la 	    a0, msg_div
    li      a7, 4
    ecall

    la      a0, msgd1
    li      a7, 4
    ecall
    li      a0, 0x3F80
    li      a1, 0x4000
    jal     ra, bf16_div
    la      a1, div_expect
    li      a2, 0
    jal     ra, compare_result

    la      a0, msgd2
    li      a7, 4
    ecall
    li      a0, 0x4000
    li      a1, 0x3F80
    jal     ra, bf16_div
    la      a1, div_expect
    li      a2, 1
    jal     ra, compare_result

    la      a0, msgd3
    li      a7, 4
    ecall
    li      a0, 0x3F80
    li      a1, 0x0000
    jal     ra, bf16_div
    la      a1, div_expect
    li      a2, 2
    jal     ra, compare_result

    la      a0, msgd4
    li      a7, 4
    ecall
    li      a0, 0x0000
    li      a1, 0x3F80
    jal     ra, bf16_div
    la      a1, div_expect
    li      a2, 3
    jal     ra, compare_result

    la      a0, msgd5
    li      a7, 4
    ecall
    li      a0, 0x7F80
    li      a1, 0x7F80
    jal     ra, bf16_div
    la      a1, div_expect
    li      a2, 4
    jal     ra, compare_result

    la      a0, msgd6
    li      a7, 4
    ecall
    li      a0, 0x7FC0
    li      a1, 0x3F80
    jal     ra, bf16_div
    la      a1, div_expect
    li      a2, 5
    jal     ra, compare_result

    la      a0, msgd7
    li      a7, 4
    ecall
    li      a0, 0xC000
    li      a1, 0x3F80
    jal     ra, bf16_div
    la      a1, div_expect
    li      a2, 6
    jal     ra, compare_result

    li      a7, 10
    ecall
					  
# =======================================================
# compare_result(a0, expect_addr, idx, is32bit)
# =======================================================
# a0 = actual result (16-bit or 32-bit)
# a1 = address of expected value table
# a2 = test case index (0-based)
# a3 = is32bit flag (1 = 32-bit, 0 = 16-bit)
# =======================================================
compare_result:
    addi    sp, sp, -20
    sw      t0, 0(sp)
    sw      t1, 4(sp)
    sw      t2, 8(sp)
    sw      t3, 12(sp)
    sw      t4, 16(sp)

    mv      t0, a0               
    beqz    a3, half_case        
    slli    t1, a2, 2            
    add     t2, a1, t1
    lw      t3, 0(t2)
    j       load_done

half_case:
    slli    t1, a2, 1            
    add     t2, a1, t1
    lhu     t3, 0(t2)

load_done:
    li      t4, 0xFFFFFFFF
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
    lw      t4, 16(sp)
    addi    sp, sp, 20
    ret

# ------------------------------
# bf16_isnan(a0): check if NaN
# ------------------------------
bf16_isnan:
    la      t0, BF16_EXP_MASK
    lh      t1, 0(t0)
    and     t2, a0, t1
    bne     t2, t1, not_nan
    la      t0, BF16_MANT_MASK
    lh      t1, 0(t0)
    and     t2, a0, t1
    beqz    t2, not_nan
    li      a0, 1
    ret
not_nan:
    li      a0, 0
    ret

# ------------------------------
# bf16_isinf(a0): check if Inf
# ------------------------------
bf16_isinf:
    la      t0, BF16_EXP_MASK
    lh      t1, 0(t0)
    and     t2, a0, t1
    bne     t2, t1, not_inf
    la      t0, BF16_MANT_MASK
    lh      t1, 0(t0)
    and     t2, a0, t1
    bnez    t2, not_inf
    li      a0, 1
    ret
not_inf:
    li      a0, 0
    ret

# ------------------------------
# bf16_iszero(a0): check if Zero
# ------------------------------
bf16_iszero:
    lui     t0, 8
    addi    t0, t0, -1
    and     a0, a0, t0
    beqz    a0, is_zero
    li      a0, 1
    ret
is_zero:
    li      a0, 0
    ret

# ------------------------------
# f32_to_bf16(a0): convert f32 → bf16
# ------------------------------
f32_to_bf16:
    srli    t0, a0, 23
    li      t1, 255
    and     t0, t0, t1
    beq     t0, t1, is_nan_inf
    srli    t0, a0, 16
    andi    t0, t0, 1
    lui     t1, 8
    addi    t1, t1, -1
    add     t0, t0, t1
    add     a0, a0, t0
    srli    a0, a0, 16
    ret

is_nan_inf:
    srli    t0, a0, 16
    lui     t1, 16
    addi    t1, t1, -1
    and     a0, t0, t1
    ret

# ------------------------------
# bf16_to_f32(a0): extend bf16 → f32
# ------------------------------
bf16_to_f32:
    slli    a0, a0, 16
    ret
# ------------------------------
# bf16_add(a0, a1): BF16 addition
# ------------------------------
bf16_add:
    # Extract sign/exponent/mantissa
    srli    t0, a0, 15
    andi    t0, t0, 1
    srli    t1, a1, 15
    andi    t1, t1, 1
    srli    t2, a0, 7
    and     t2, t2, s0
    srli    t3, a1, 7
    and     t3, t3, s0
    andi    t4, a0, 127
    andi    t5, a1, 127

    # Handle Inf/NaN and zeros
    beq     t2, s0, a_inf_nan
    beq     t3, s0, return_b
    beqz    t2, check_mantissa_a_zero
    jal     x0, next

check_mantissa_a_zero:
    beqz    t4, return_b
next:
    beqz    t3, check_mantissa_b_zero
    jal     x0, next0

check_mantissa_b_zero:
    beqz    t5, return_a
next0:
    beqz    t2, skip_a_implicit_1
    ori     t4, t4, 0x80
skip_a_implicit_1:
    beqz    t3, skip_b_implicit_1
    ori     t5, t5, 0x80
skip_b_implicit_1:
    jal     x0, next1

# --- handle special cases ---
a_inf_nan:
    bnez    t4, return_a
    beq     t3, s0, a_and_b_inf_nan
    ret

a_and_b_inf_nan:
    bnez    t5, return_b
    beq     t0, t1, return_b
    jal     x0, return_nan

# --- align exponents ---
next1:
    sub     s2, t2, t3
    bgt     s2, zero, greater_than_zero
    blt     s2, zero, less_than_zero
    add     s3, zero, t2
    jal     x0, next2

greater_than_zero:
    add     s3, zero, t2
    li      t6, 8
    bgt     s2, t6, return_a
    srl     t5, t5, s2
    jal     x0, next2

less_than_zero:
    add     s3, zero, t3
    li      t6, -8
    blt     s2, t6, return_b
    neg     t6, s2
    srl     t4, t4, t6

# --- perform mantissa add/sub ---
next2:
    beq     t0, t1, signa_eq_signb
    bge     t4, t5, mant_a_greater_mant_b
    add     s4, t1, zero
    sub     s5, t5, t4
    jal     x0, next4

mant_a_greater_mant_b:
    add     s4, t0, zero
    sub     s5, t4, t5

# --- normalize result ---
next4:
    bnez    s5, normalize_loop
    la      t6, BF16_ZERO
    lh      a0, 0(t6)
    ret

normalize_loop:
    andi    t6, s5, 0x80
    bnez    t6, final_return
    addi    s3, s3, -1
    blez    s3, underflow_zero
    slli    s5, s5, 1
    j       normalize_loop

underflow_zero:
    la      t6, BF16_ZERO
    lh      a0, 0(t6)
    ret

# --- same sign addition ---
signa_eq_signb:
    add     s4, t0, zero
    add     s5, t4, t5
    andi    t6, s5, 0x100
    beqz    t6, final_return
    srli    s5, s5, 1
    addi    s3, s3, 1
    j       final_return

# --- pack result ---
final_return:
    slli    s4, s4, 15
    and     s3, s3, s0
    slli    s3, s3, 7
    andi    s5, s5, 0x7F
    or      a0, s3, s4
    or      a0, a0, s5
    ret

# ------------------------------
# bf16_sub(a0, a1): subtraction
# ------------------------------
bf16_sub:
    lui     t6, 0x8
    xor     a1, a1, t6            # flip sign bit
    addi    sp, sp, -4
    sw      ra, 0(sp)
    jal     ra, bf16_add
    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret
# ------------------------------
# bf16_mul(a0, a1): BF16 multiplication
# ------------------------------
bf16_mul:
    # Extract sign / exponent / mantissa
    srli    t0, a0, 15
    andi    t0, t0, 1
    srli    t1, a1, 15
    andi    t1, t1, 1
    srli    t2, a0, 7
    and     t2, t2, s0
    srli    t3, a1, 7
    and     t3, t3, s0
    andi    t4, a0, 127
    andi    t5, a1, 127
    xor     s1, t0, t1

    # Check for NaN / Inf cases
    bne     t2, s0, check_b_exp
    bnez    t4, return_a
    beqz    t3, check_b_mant
back1:
    slli    a0, s1, 15
    or      a0, a0, s11
    ret

check_b_mant:
    bnez    t5, back1
    j       return_nan

# --- check exponent B special case ---
check_b_exp:
    bne     t3, s0, next6
    bnez    t4, return_b
    beqz    t2, check_a_mant
back2:
    slli    a0, s1, 15
    or      a0, a0, s11
    ret

check_a_mant:
    bnez    t4, back2
    jal     x0, return_nan

# --- handle zero operands ---
next6:
    beqz    t2, check_a_is_zero
check_b:
    beqz    t3, check_b_is_zero
a_b_no_zero:
    j       next7

check_a_is_zero:
    beqz    t4, a_or_b_is_zero
    j       check_b

check_b_is_zero:
    beqz    t5, a_or_b_is_zero
    j       a_b_no_zero

a_or_b_is_zero:
    slli    a0, s1, 15
    ret

# --- normalize subnormal exponents ---
next7:
    add     s2, zero, zero
    beqz    t2, exp_a_zero
    ori     t4, t4, 0x80
    j       check_b_exp_zero

exp_a_zero:
    addi    t2, zero, 1
    andi    t6, t4, 0x80
    bnez    t6, check_b_exp_zero
    slli    t4, t4, 1
    addi    s2, s2, -1
    j       exp_a_zero

# --- same for operand B ---
check_b_exp_zero:
    beq     t3, s0, exp_b_zero
    ori     t5, t5, 0x80
    j       next8

exp_b_zero:
    addi    t3, zero, 1
    andi    t6, t5, 0x80
    bnez    t6, next8
    slli    t5, t5, 1
    addi    s2, s2, -1
    j       exp_b_zero

# --- perform mantissa multiplication (Egyptian method) ---
next8:
    addi    sp, sp, -12
    sw      a0, 0(sp)
    sw      a1, 4(sp)
    sw      ra, 8(sp)
    add     a0, t4, zero
    add     a1, t5, zero
    jal     ra, multiply8
    add     s3, a0, zero
    lw      a0, 0(sp)
    lw      a1, 4(sp)
    lw      ra, 8(sp)
    addi    sp, sp, 12

    # Calculate result exponent
    add     s4, t2, t3
    la      t6, BF16_EXP_BIAS
    lh      t6, 0(t6)
    sub     s4, s4, t6
    add     s4, s4, s2

    # Normalize mantissa
    lui     t6, 0x8
    and     t6, s3, t6
    bnez    t6, ret_val_is_neg
    srli    t6, s3, 7
    andi    s3, t6, 0x7F
    j       ret_exp

ret_val_is_neg:
    srli    t6, s3, 8
    andi    s3, t6, 0x7F
    addi    s4, s4, 1

# --- check overflow/underflow ---
ret_exp:
    bge     s4, s0, over_ff
    ble     s4, zero, under_zero
mul_final_return:
    slli    s1, s1, 15
    and     s4, s4, s0
    slli    s4, s4, 7
    andi    s3, s3, 0x7F
    or      a0, s1, s4
    or      a0, a0, s3
    ret

# overflow → Inf
over_ff:
    slli    a0, s1, 15
    or      a0, a0, s11
    ret

# underflow → 0
under_zero:
    li      t6, -6
    blt     s4, t6, shift_sign_15
    li      t6, 1
    sub     t6, t6, s4
    srl     s3, s3, t6
    li      s4, 0
    j       mul_final_return

shift_sign_15:
    slli    a0, s1, 15
    ret


# ------------------------------
# bf16_div(a0, a1): BF16 division
# ------------------------------
bf16_div:
	# Extract sign / exponent / mantissa									
    srli    t0, a0, 15
    andi    t0, t0, 1
    srli    t1, a1, 15
    andi    t1, t1, 1
    srli    t2, a0, 7
    and     t2, t2, s0
    srli    t3, a1, 7
    and     t3, t3, s0
    andi    t4, a0, 127
    andi    t5, a1, 127
    xor     s1, t0, t1

    # --- check special cases ---
    beq     t3, s0, div_b_inf_nan
    beqz    t3, div_b_check_mant_0

b_is_not_zero_but_exp_0:
    beq     t2, s0, div_a_inf_nan
    beqz    t2, div_a_exp_0_check_mant_0

a_is_not_zero_but_exp_0:
    bnez    t2, set_a_mant
also_check_b:
    bnez    t3, set_b_mant
    j       set_div

# --- handle b = Inf/NaN ---
div_b_inf_nan:
    bnez    t5, return_b
    beq     t2, s0, b_check_a_mant
div_b_inf_nan_return:
    slli    a0, s1, 15
    ret

b_check_a_mant:
    beqz    t4, return_nan
    j       div_b_inf_nan_return

# --- b = 0 case ---
div_b_check_mant_0:
    beqz    t5, div_a_check_0
    j       b_is_not_zero_but_exp_0

div_b_check_0_return:
    slli    a0, s1, 15
    or      a0, a0, s11
    ret

div_a_check_0:
    beq     t2, s0, div_a_check_mant_0
    j       div_b_check_0_return

div_a_check_mant_0:
    beqz    t4, return_nan
    j       div_b_check_0_return

# --- a = Inf/NaN ---
div_a_inf_nan:
    bnez    t4, return_a
    slli    a0, s1, 15
    ret

# --- a = 0 case ---
div_a_exp_0_check_mant_0:
    beqz    t4, div_a_exp_0_check_0
    j       a_is_not_zero_but_exp_0

div_a_exp_0_check_0:
    slli    a0, s1, 15
    ret

# --- set implicit 1 ---
set_a_mant:
    ori     t4, t4, 0x80
    j       also_check_b

set_b_mant:
    ori     t5, t5, 0x80
    j       set_div


# ------------------------------
# division core (long division)
# ------------------------------
set_div:
    slli    s2, t4, 15
    add     s3, t5, zero
    li      s4, 0
    li      t6, 0
    li      s5, 16

# --- for loop: binary long division ---										
for_loop:
    bge     t6, s5, out_for_loop
    slli    s4, s4, 1
    addi    s6, zero, 15
    sub     s6, s6, t6
    sll     s6, s3, s6
    blt     s2, s6, out_if
    sub     s2, s2, s6
    ori     s4, s4, 1
out_if:
    addi    t6, t6, 1
    j       for_loop
out_for_loop:

	# --- compute exponent ---						  
    sub     s5, t2, t3
    la      t6, BF16_EXP_BIAS
    lh      t6, 0(t6)
    add     s5, s5, t6
    bnez    t2, exp_a_isnot_zero
    addi    s5, s5, -1
exp_a_isnot_zero:
    bnez    t3, exp_b_isnot_zero
    addi    s5, s5, 1
exp_b_isnot_zero:

	# --- normalize quotient ---							
    lui     t6, 0x8
    and     t6, s4, t6
    beqz    t6, check_while_condition
    srli    s4, s4, 8
    j       next9

# --- normalization loop ---							
check_while_condition:
    lui     t6, 0x8
    and     t6, s4, t6
    beqz    t6, check_result_exp
else_shift_quotient:
    srli    s4, s4, 8
    j       next9

check_result_exp:
    li      s6, 1
    bgt     s5, s6, while_loop
    j       else_shift_quotient

while_loop:
    slli    s4, s4, 1
    addi    s5, s5, -1
    j       check_while_condition

# --- pack final result ---						   
next9:
    andi    s4, s4, 0x7F
    bge     s5, s0, exp_greater_all_one
    ble     s5, zero, exp_less_equal_zero
    slli    s1, s1, 15
    and     s5, s5, s0
    slli    s5, s5, 7
    andi    s4, s4, 0x7F
    or      a0, s1, s5
    or      a0, a0, s4
    ret

# --- overflow / underflow handling ---									   
exp_greater_all_one:
    slli    a0, s1, 15
    or      a0, a0, s11
    ret

exp_less_equal_zero:
    slli    a0, s1, 15
    ret

# Common return labels
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

# =======================================================
# multiply8(a0, a1): Egyptian Multiplication
# =======================================================
# Parameters:			 
#     a0 = multiplicand (8-bit)
#     a1 = multiplier   (8-bit)
# 		 
# Return: 
#     a0 = 16-bit result
# =======================================================
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