.data
.globl input_prompt
input_prompt: .asciiz "ENTER > "

.text
b main

.globl copy_board
copy_board:
    addi $sp, $sp, -20      #Allocate 20 bytes for stack space 
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $t0, 12($sp)
    sw $t1, 16($sp)

    li $t0, 0               #Loop counter
    # $a0 = Original Board
    # $a1 = Copy Board

    loop:
        #Load and store a character from the orignal into the copied strinng
        lb $t1, ($a0)
        sb $t1, ($a1)

        addi $a0, $a0, 1        #Increment original string pointer
        addi $a1, $a1, 1        #Increment copy string pointer
        addi $t0, $t0, 1        #Increment loop counter

        bne $t1, $zero, loop    #Loop until null terminator is reached

    lw $t1, 16($sp)
    lw $t0, 12($sp)
    lw $a1, 8($sp)
    lw $a0, 4($sp)
    addi $sp, $sp, 20        #Delete stack Space

jr $ra                   #Return to previous function (caller)

.globl clear_screen
clear_screen:
    #Set-up registers
    la $a0, '\n'     #Load newline
    li $v0, 11       #Load syscall 11
    li $a1, 0        #Loop counter

    #Loop 100 times
    clear_screen_loop:
        beq $a1, 100, clear_screen_complete

        #Clear screen (syscall 1)
        syscall
        addi $a1, $a1, 1

        b clear_screen_loop
    clear_screen_complete:
jr $ra      #Return to previous function (caller)

main:
    jal game_title   #Load game title
    jal main_menu    #Load main menu
    
#Terminate program (precation)
li $v0, 10
syscall
