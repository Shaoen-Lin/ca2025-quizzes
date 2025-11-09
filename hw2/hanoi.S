    .text
    .globl  hanoi
hanoi:

    addi     x2, x2, -4
    sw       x1, 0(x2)
    
    addi     x2, x2, -32
    sw       x8, 0(x2)
    sw       x9, 4(x2)
    sw       x18, 8(x2)
    sw       x19, 12(x2)
    sw       x20, 16(x2)

    li       x5, 0x15
    sw       x5, 20(x2)
    sw       x5, 24(x2)
    sw       x5, 28(x2)

    # Fix disk positions (BLANK 1–3: neutralize x5 effect)
    sw       x0, 20(x2)
    sw       x0, 24(x2)
    sw       x0, 28(x2)

    addi     x8, x0, 1
game_loop:
    addi     x5, x0, 8
    beq      x8, x5, finish_game

    srli     x5, x8, 1
    xor      x6, x8, x5
    addi     x7, x8, -1
    srli     x28, x7, 1
    xor      x7, x7, x28
    xor      x5, x6, x7

    addi     x9, x0, 0
    andi     x6, x5, 1
    bne      x6, x0, disk_found
    addi     x9, x0, 1
    andi     x6, x5, 2
    bne      x6, x0, disk_found
    addi     x9, x0, 2

disk_found:
    andi     x30, x5, 5
    addi     x31, x0, 5
    beq      x30, x31, pattern_match
    jal      x0, continue_move
pattern_match:
continue_move:
    slli     x5, x9, 2
    addi     x5, x5, 20
    add      x5, x2, x5
    lw       x18, 0(x5)
    bne      x9, x0, handle_large

    addi     x19, x18, 2
    addi     x6, x0, 3
    blt      x19, x6, display_move
    sub      x19, x19, x6
    jal      x0, display_move

handle_large:
    lw       x6, 20(x2)
    addi     x19, x0, 3
    sub      x19, x19, x18
    sub      x19, x19, x6

display_move:
    la       x20, obdata
    add      x5, x20, x18
    lbu      x11, 0(x5)
    li       x6, 0x6F
    xor      x11, x11, x6
    addi     x11, x11, -0x12
    addi     x27, x11, 0
    add      x7, x20, x19
    lbu      x12, 0(x7)
    xor      x12, x12, x6
    addi     x12, x12, -0x12
    addi     x26, x12, 0

    li       x10, 1          
    la       x11, str1       
    la       x12, str1_size  
    li       x17, 64
    ecall
    
    addi     x10, x9, 49     
    addi     x2, x2, -1      
    sb       x10, 0(x2)      
    li       x10, 1          
    mv       x11, x2         
    li       x12, 1          
    li       x17, 64         
    ecall
    addi     x2, x2, 1      
    
    li       x10, 1          
    la       x11, str2       
    la       x12, str2_size  
    li       x17, 64
    ecall
    
    addi     x10, x27, 0
    jal      x1, print_char
    
    li       x10, 1          
    la       x11, str3       
    la       x12, str3_size  
    li       x17, 64
    ecall
 
    addi     x10, x26, 0
    jal      x1, print_char
    
    addi     x5, x0, 10     
    addi     x2, x2, -1
    sb       x5, 0(x2)      
    li       x10, 1          
    mv       x11, x2        
    li       x12, 1         
    li       x17, 64         
    ecall
    addi     x2, x2, 1      

    slli     x5, x9, 2
    addi     x5, x5, 20
    add      x5, x2, x5
    sw       x19, 0(x5)
    addi     x8, x8, 1
    jal      x0, game_loop

finish_game:
    lw       x8, 0(x2)
    lw       x9, 4(x2)
    lw       x18, 8(x2)
    lw       x19, 12(x2)
    lw       x20, 16(x2)
    addi     x2, x2, 32
 
    lw       x1, 0(x2)
    addi     x2, x2, 4
    ret
    
# ======================================================
# print_char(x10)
#   Print a single character to stdout
#   Argument:
#       x10 = ASCII value of the character (e.g., 65 = 'A')
# ======================================================
.global print_char
print_char:
    addi     x2, x2, -4     
    sw       x10, 0(x2)      
    li       x10, 1          
    add      x11, x2, x0     
    li       x12, 1          
    li       x17, 64         
    ecall
    addi     x2, x2, 4      
    ret

    .data
obdata:     .byte   0x3c, 0x3b, 0x3a
str1:       .asciz  "  Move Disk "
.set        str1_size, . - str1 
str2:       .asciz  " from "
.set        str2_size, . - str2 
str3:       .asciz  " to "
.set        str3_size, . - str3


