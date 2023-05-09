.data
score_tie: .asciiz "\t\t\t     ______  __   ______    \n\t\t\t    /\\__  _\\/\\ \\ /\\  ___\\   \n\t\t\t    \\/_/\\ \\/\\ \\ \\\\ \\  __\\  \n\t\t\t       \\ \\_\\ \\ \\_\\\\ \\_____\\ \n\t\t\t        \\/_/  \\/_/ \\/_____/ \n"
score_win: .asciiz "\t\t\t   __     __   __   __   __    \n\t\t\t  /\\ \\  _ \\ \\ /\\ \\ /\\ \"-.\\ \\   \n\t\t\t  \\ \\ \\/ \".\\ \\\\ \\ \\\\ \\ \\-.  \\  \n\t\t\t   \\ \\__/\". \\_\\\\ \\_\\\\ \\_\\ \"\\_\\ \n\t\t\t    \\/_/   \\/_/ \\/_/ \\/_/ \\/_/ \n"
score_prompt: .asciiz "\n\t\t\t   Enter any key to continue\n\n"

game_text1: .asciiz "\t\t\t       Player "
game_text2: .asciiz " : Round "
game_text3: .asciiz "\n\t\t\t    For intructions, enter 0\n\n"

game_board_original1: .asciiz "\t\t\t\t     |     |     \n"
game_board_original2: .asciiz "\t\t\t\t_____|_____|_____\n"
game_board1: .space 28
game_board2: .space 28
game_board3: .space 28

.text

.globl game_logic
game_logic: 
    addiu $sp, $sp, -4  #Create Stack Space
    sw $ra, 0($sp)      #Save return address

    li $s0, 1           #Round counter
    li $s1, 9           #Spaces left

    #Set-up tic-tac-toe board
    la $a0, game_board_original1
    la $a1, game_board1
    jal copy_board
    la $a1, game_board2
    jal copy_board
    la $a1, game_board3
    jal copy_board

    game_main:

        jal clear_screen

        jal check_board
        beqz $s1, game_main_complete_score

        jal print_board   

        #Mod 2
        div $a1, $s0, 2
        mfhi $a1
        #Determine Player
        bnez $a1, player_number_skip
        li $a1, 2
        player_number_skip:

        #Print player text (syscall 4)
        la $a0, game_text1
        li $v0, 4
        syscall

        #Print player number (syscall 1)
        move $a0, $a1
        li $v0, 1
        syscall

        #Print round text (syscall 4)
        la $a0, game_text2
        li $v0, 4
        syscall

        #Print round number (syscall 1)
        move $a0, $s0
        li $v0, 1
        syscall

        #Print intructions hint (syscall 4)
        la $a0, game_text3
        li $v0, 4
        syscall
        
        #Print input prompt (syscall 4)
        la $a0, input_prompt
        syscall

        #Read users' choice (syscall 12)
        li $v0, 12
        syscall
        move $t0, $v0

        beq $a3, -1, game_main_complete

        #Filter user's input
        addi $t1, $t0, 0                    #Load user's character as a byte
        beq $t1, 48, load_instructions      #ASCII number 0
        blt $t1, 49, game_main              #ASCII number 1
        bgt $t1, 57, game_main              #ASCII number 9

        jal modify_board    #Handle user's input
        beq $a0, -1, game_main

        addi $s0, $s0, 1    #Increment round counter
        subi $s1, $s1, 1    #Deincrement spaces left
        b game_main

        load_instructions:
            jal game_instructions
        b game_main

    game_main_complete:

    lw $ra, 0($sp)      #Retrieve return address
    addiu $sp, $sp, 4   #Delete stack Space

    jal main_menu

jr $ra  #Return to main function

game_main_complete_score:
        subi $s0, $s0, 1    #Deincrement round counter

        bne $a0, 1, score_screen_tie
        #Print win text (syscall 4)
        la $a0, score_win
        li $v0, 4
        syscall

        b score_screen_cont
        score_screen_tie:
        #Print tie text (syscall 4)
        la $a0, score_tie
        li $v0, 4
        syscall
        
        score_screen_cont:

        jal print_board   

        #Mod 2
        div $a1, $s0, 2
        mfhi $a1
        #Determine Player
        bnez $a1, player_number_skip1
        li $a1, 2
        player_number_skip1:

        #Print player text (syscall 4)
        la $a0, game_text1
        li $v0, 4
        syscall

        #Print player number (syscall 1)
        move $a0, $a1
        li $v0, 1
        syscall

        #Print round text (syscall 4)
        la $a0, game_text2
        li $v0, 4
        syscall

        #Print round number (syscall 1)
        move $a0, $s0
        li $v0, 1
        syscall

        #Print contiue prompt (syscall 4)
        la $a0, score_prompt
        li $v0, 4
        syscall
        
        #Print input prompt (syscall 4)
        la $a0, input_prompt
        syscall

        #Read users' choice (syscall 12)
        li $v0, 12
        syscall
        move $t0, $v0

b game_main_complete

print_board:
    addiu $sp, $sp, -20    #Allocate 20 bytes for stack space
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)

    #Set-up registers
    li $v0, 4           #Load syscall 4
    li $a1, 1           #Loop counter

    #Loop to print board
    print_board_loop:
        beq $a1, 9, print_board_complete

        #Modulo 3
        div $a2, $a1, 3
        mfhi $a2

        #Print Tic-Tac-Toe board
        addi $a1, $a1, 1
        beq $a2, $zero, print_board_odd   
            #Even; Not divisible by 3
            la $a0, game_board_original1

            #Modulo 3
            div $a2, $a1, 3
            mfhi $a2

            bne $a2, $zero, print_board_skip  #If odd, print modified board
            div $a2, $a1, 3

            beq $a2, 1, print_board1
            beq $a2, 2, print_board2
            beq $a2, 3, print_board3

            print_board1:
                la $a0, game_board1
            b print_board_skip

            print_board2:
                la $a0, game_board2
            b print_board_skip

            print_board3:
                la $a0, game_board3

            print_board_skip:
            syscall

            b print_board_loop
        print_board_odd: 
            #Odd; Divisible by 3
            la $a0, game_board_original2
            syscall

            b print_board_loop
    print_board_complete:
    la $a0, game_board_original1
    syscall

    lw $t3, 16($sp)
    lw $t2, 12($sp)
    lw $t1, 8($sp)
    lw $t0, 4($sp)
    addiu $sp, $sp, 20      #Delete stack Space

jr $ra  #Return to previous function (caller)

modify_board:
    addiu $sp, $sp, -20    #Allocate 20 bytes for stack space
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)

    sub $t2, $t0, 48

    beq $a1, 2, modify_board_player2
    li $t0, 'X'
    b modify_board_logic
    modify_board_player2:
    li $t0, 'O'

    modify_board_logic:

        ble $t1, 51, modify_board_check1        #ASCII number 3
        ble $t1, 54, modify_board_check2        #ASCII number 6
        ble $t1, 57, modify_board_check3        #ASCII number 9

        modify_board_check1:        #Numbers 1-3
            mul $t2, $t2, 6
            lb $t3, game_board1($t2)
            bne $t3, 32, modify_board_failed

            sb $t0, game_board1($t2)

        b modify_board_complete

        modify_board_check2:        #Numbers 3-6
            subi $t2, $t2, 3
            mul $t2, $t2, 6
            lb $t3, game_board2($t2)
            bne $t3, 32, modify_board_failed

            sb $t0, game_board2($t2)

        b modify_board_complete

        modify_board_check3:        #Numbers 6-9
            subi $t2, $t2, 6
            mul $t2, $t2, 6
            lb $t3, game_board3($t2)
            bne $t3, 32, modify_board_failed

            sb $t0, game_board3($t2)

        b modify_board_complete

    modify_board_failed:
    li $a0, -1
        
    modify_board_complete:

    lw $t3, 16($sp)
    lw $t2, 12($sp)
    lw $t1, 8($sp)
    lw $t0, 4($sp)
    addiu $sp, $sp, 20      #Delete stack Space
jr $ra

check_board:
    addiu $sp, $sp, -24    #Allocate 20 bytes for stack space
    sw $ra, 4($sp)
    sw $t0, 8($sp)
    sw $t1, 12($sp)
    sw $t2, 16($sp)
    sw $t3, 20($sp)

    li $t0, 6              #Starting byte position
    li $a0, 0              #Loop count counter

    check_board_row1:
        #Collect characters in row 1
        lb $t1, game_board1($t0)        #Load current character
        addi $t2, $t0, 6
        lb $t2, game_board1($t2)        #Load next character
        addi $t3, $t0, 12
        lb $t3, game_board1($t3)        #Load next character

        jal ascii32_check

        bne $t1, $t2, check_board_row2
        bne $t1, $t3, check_board_row2
        b check_board_completed

    check_board_row2:
        #Collect characters in row 2
        lb $t1, game_board2($t0)        #Load current character
        addi $t2, $t0, 6
        lb $t2, game_board2($t2)        #Load next character
        addi $t3, $t0, 12
        lb $t3, game_board2($t3)        #Load next character

        jal ascii32_check

        bne $t1, $t2, check_board_row3
        bne $t1, $t3, check_board_row3
        b check_board_completed

    check_board_row3:
        #Collect characters in row 3
        lb $t1, game_board3($t0)        #Load current character
        addi $t2, $t0, 6
        lb $t2, game_board3($t2)        #Load next character
        addi $t3, $t0, 12
        lb $t3, game_board3($t3)        #Load next character

        jal ascii32_check

        bne $t1, $t2, check_board_column
        bne $t1, $t3, check_board_column
        b check_board_completed

    check_board_column:
        beq $a0, 3, check_board_diagonal1

        #Collect characters in all columns
        lb $t1, game_board1($t0)        #Load current character
        lb $t2, game_board2($t0)        #Load next character
        lb $t3, game_board3($t0)        #Load next character

        jal ascii32_check

        bne $t1, $t2, check_board_next
        bne $t1, $t3, check_board_next
        b check_board_completed

    check_board_next:
        #Move to next column
        addi $t0, $t0, 6
        addi $a0, $a0, 1
        b check_board_column

    check_board_diagonal1:
        #Collect characters in diagonal: /
        addi $t0, $t0, -6
        lb $t1, game_board1($t0)        #Load current character
        addi $t0, $t0, -6
        lb $t2, game_board2($t0)        #Load next character
        addi $t0, $t0, -6
        lb $t3, game_board3($t0)        #Load next character

        jal ascii32_check

        bne $t1, $t2, check_board_diagonal2
        bne $t1, $t3, check_board_diagonal2
        b check_board_completed

    check_board_diagonal2:
        #Collect characters in diagonal: \
        lb $t1, game_board1($t0)        #Load current character
        addi $t2, $t0, 6
        lb $t2, game_board2($t2)        #Load next character
        addi $t3, $t0, 12
        lb $t3, game_board3($t3)        #Load next character

        jal ascii32_check

        bne $t1, $t2, check_board_failed
        bne $t1, $t3, check_board_failed
        b check_board_completed

    check_board_failed:
    li $a1, -1

    check_board_completed:
    beq $a1, -1, skip
        li $a0, 1
        li $s1, 0
    skip:

    lw $t3, 20($sp)
    lw $t2, 16($sp)
    lw $t1, 12($sp)
    lw $t0, 8($sp)
    lw $ra, 4($sp)
    addiu $sp, $sp, 24      #Delete stack Space
jr $ra

ascii32_check:
    bne $t1, 32, ascii32_check_complete
    bne $t2, 32, ascii32_check_complete
    bne $t3, 32, ascii32_check_complete

    b check_board_failed

    ascii32_check_complete:
jr $ra