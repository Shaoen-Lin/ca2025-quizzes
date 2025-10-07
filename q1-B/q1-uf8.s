.data
    nl:      .string "\n"
    msg0:    .string ": produces value "
    msg1:    .string " but encodes back to "
    msg2:    .string ": value "
    msg3:    .string " <= previous_value "
    msg4:    .string "All tests passed."

.text
.global main
main:
    jal     ra, test
    beqz    a0, return_1
    la      a0, msg4
    li      a7, 4
    ecall
    la      a0, nl
    li      a7, 4
    ecall
    li      a0, 0
    li      a7, 10
    ecall
return_1:
    li      a0, 1
    li      a7, 10
    ecall

# ============================================================
# clz: Count leading zeros (binary search)
# Input : a0 (unsigned int)
# Output: a0 = leading zero count
# ============================================================
clz:
    li      s0, 32
    li      s1, 16
clz_while_loop:
    srl     t0, a0, s1
    bnez    t0, clz_if
    srli    s1, s1, 1
    j       check_condition
clz_if:
    sub     s0, s0, s1
    add     a0, t0, zero
check_condition:
    bnez    s1, clz_while_loop
    sub     a0, s0, a0
    ret

# ============================================================
# uf8_decode: Decode uf8 -> uint32_t
# ============================================================
uf8_decode:
    andi    s0, a0, 0x0f        
    srli    s1, a0, 4           
    li      t0, 15
    sub     t0, t0, s1
    li      s2, 0x7FFF
    srl     s2, s2, t0
    slli    s2, s2, 4           
    sll     a0, s0, s1
    add     a0, a0, s2          
    ret

# ============================================================
# uf8_encode: Encode uint32_t -> uf8
# ============================================================
uf8_encode:
    li      t0, 16
    blt     a0, t0, return_a0   

    addi    sp, sp, -8
    sw      ra, 0(sp)
    sw      a0, 4(sp)
    jal     ra, clz
    add     s4, a0, zero        
    lw      ra, 0(sp)
    lw      a0, 4(sp)
    addi    sp, sp, 8

    li      t0, 31
    sub     s5, t0, s4          
    li      s6, 0               
    li      s7, 0               
    li      t0, 5
    bge     s5, t0, encode_if_msb_bge_5

msb_less_5:                     # If msb < 5, find exponent loop
    li      t0, 15
check_while_loop2_condition:
    blt     s6, t0, encode_while_loop2
encode_return:
    sub     s0, a0, s7
    srl     s0, s0, s6          
    slli    t0, s6, 4
    or      a0, t0, s0
    ret

encode_if_msb_bge_5:            # If msb >= 5, estimate exponent
    addi    s6, s5, -4
    li      t0, 15
    bgt     s6, t0, set_expoent_15
back_encode_if_msb_bge_5:
    li      t0, 0
encode_for_loop:                # overflow = (overflow << 1) + 16
    bge     t0, s6, out_of_encode_loop
    slli    t1, s7, 1
    addi    s7, t1, 16
    addi    t0, t0, 1
    j       encode_for_loop
out_of_encode_loop:
    bgt     s6, zero, encode_while_loop1
    j       msb_less_5

encode_while_loop1:             # Adjust exponent if overflow too large
    bge     a0, s7, msb_less_5
    addi    t0, s7, -16
    srli    s7, t0, 1
    addi    s6, s6, -1
    j       out_of_encode_loop

set_expoent_15:
    addi    s6, zero, 15
    j       back_encode_if_msb_bge_5

encode_while_loop2:             # Find exact exponent
    slli    s8, s7, 1
    addi    s8, s8, 16
    blt     a0, s8, encode_return
    add     s7, s8, x0
    addi    s6, s6, 1
    j       check_while_loop2_condition

return_a0:
    ret

# ============================================================
# test: Run encode/decode test loop
# ============================================================
test:
    li      s0, -1              
    li      s1, 1              
    addi    t2, zero, 0
    li      t3, 256
test_for_loop:
    bge     t2, t3, out_test_for_loop
    addi    t4, t2, 0           

    # call uf8_decode(fl)
    addi    sp, sp, -12
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    add     a0, t4, x0
    jal     ra, uf8_decode
    addi    t5, a0, 0           
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    addi    sp, sp, 12

    # call uf8_encode(value)
    addi    sp, sp, -12
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    jal     ra, uf8_encode
    addi    t6, a0, 0           
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    addi    sp, sp, 12

    bne     t4, t6, test_if_1   # if (fl != fl2)
out_test_if_1:
    ble     t5, s0, test_if_2   # if (value <= previous_value)
out_test_if_2:
    add     s0, t5, x0          
    addi    t2, t2, 1
    j       test_for_loop
out_test_for_loop:
    add     a0, s1, zero
    ret

# Print mismatch: fl != fl2
test_if_1:
    mv      a0, t4
    li      a7, 34
    ecall
    la      a0, msg0
    li      a7, 4
    ecall
    mv      a0, t5
    li      a7, 1
    ecall
    la      a0, msg1
    li      a7, 4
    ecall
    mv      a0, t6
    li      a7, 34
    ecall
    la      a0, nl
    li      a7, 4
    ecall
    li      s1, 0
    j       out_test_if_1

# Print non-monotonic: value <= previous_value
test_if_2:
    mv      a0, t4
    li      a7, 34
    ecall
    la      a0, msg2
    li      a7, 4
    ecall
    mv      a0, t5
    li      a7, 1
    ecall
    la      a0, msg3
    li      a7, 4
    ecall
    mv      a0, s0
    li      a7, 34
    ecall
    la      a0, nl
    li      a7, 4
    ecall
    li      s1, 0
    j       out_test_if_2

