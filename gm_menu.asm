.data
menu_options: .asciiz "\t\t     Tic-Tac-Toe v1\n\t\t     +----------------------------------------+\n\t\t     |                 Play: 1                |\n\t\t     +----------------------------------------+\n\t\t     |              How To Play: 2            |\n\t\t     +----------------------------------------+\n\t\t     |               Exit Game: 3             |\n\t\t     +----------------------------------------+\n"
menu_prompt: .asciiz "\t\t          Enter the above options (numbers)\n\n\n"

inst_board1: .asciiz "\t\t\t\t     |     |     \n"
inst_board2: .asciiz "\t\t\t\t_____|_____|_____\n"
inst_board_copy: .space 28
inst_text1: .asciiz "\t\t     Here, the game starts with an empty grid.\n\tTo represent each player, Player 1 will be given Xs, and Player 2 Os.\n\n"
inst_text2: .asciiz "  As depicted above, both players are allowed to select any number between 1 to 9.\n\tThe number they choose corresponds to a specific spot on the grid,\n\t\t      where they will place their symbol.\n\n"
inst_text3: .asciiz "\t  Players alternate turns placing their symbol on an empty spot,\n\t     until a player gets three in a row, column, or diagonal.\n\t\tIf all spots are filled, the game is declared a tie.\n\n"
inst_prompt: .asciiz "\t\t\t   Enter any key to continue\n\n"

.text

.globl main_menu
main_menu:
    addiu $sp, $sp, -4  #Create Stack Space
    sw $ra, 0($sp)      #Save return address
    jal clear_screen    #Clear screen

    #Print menu options (syscall 4)
    la $a0, menu_options
    li $v0, 4
    syscall
    #Print menu prompt (syscall 4)
    la $a0, menu_prompt
    syscall

    #Print input prompt (syscall 4)
    la $a0, input_prompt
    syscall

    #Read users' choice (syscall 12)
    li $v0, 12
    syscall

    #Why do this? Using syscall 5, will cause an error.
    #This would crash the program if the player enters anythinng other a number.
    #Using syscall 12 makes sure any character can be used without crashing the program.

    beq $v0, '1', main_menu_option1   #Play game (1)
    beq $v0, '2', main_menu_option2   #How to play (2)
    beq $v0, '3', quit_program        #Exit game (3)
    b main_menu

    quit_program:
        #Terminate program (Quit)
        li $v0, 10
        syscall

    main_menu_option2:
        jal game_instructions   #Load game instructions
        b main_menu

    main_menu_option1:
        lw $ra, 0($sp)          #Retrieve return address
        addiu $sp, $sp, 4       #Delete stack Space
        
        jal game_logic

jr $ra  #Return to main function

.globl game_instructions
game_instructions:
    addiu $sp, $sp, -24    #Allocate 20 bytes for stack space
    sw $ra, 4($sp)         #Save return address
    sw $t0, 8($sp)
    sw $t1, 12($sp)
    sw $t2, 16($sp)
    sw $t3, 20($sp)
    
    la $a0, inst_board1
    la $a1, inst_board_copy
    jal copy_board 
    jal clear_screen

    #Set-up registers
    li $v0, 4           #Load syscall 4
    li $a1, 1           #Loop counter
    li $t0, 48          #ASCII number 0
    li $t1, 6           #Index 3
    li $t2, 12          #Index 9
    li $t3, 18          #Index 15

    #Loop to print board
    game_instructions_loop:
        beq $a1, 9, game_instructions_complete

        #Modulo 3
        div $a2, $a1, 3
        mfhi $a2

        #Print Tic-Tac-Toe board
        addi $a1, $a1, 1
        beq $a2, $zero, game_instructions_odd   
            #Even; Not divisible by 3
            la $a0, inst_board1

            #Modulo 3
            div $a2, $a1, 3
            mfhi $a2

            bne $a2, $zero, game_instructions_skip  #If odd, print modified board
            la $a0, inst_board_copy

            #Modify inst_board_copy
            addi $t0, $t0, 1
            sb $t0, inst_board_copy($t1)
            addi $t0, $t0, 1
            sb $t0, inst_board_copy($t2)
            addi $t0, $t0, 1
            sb $t0, inst_board_copy($t3)

            game_instructions_skip:
            syscall

            b game_instructions_loop
        game_instructions_odd: 
            #Odd; Divisible by 3
            la $a0, inst_board2
            syscall

            b game_instructions_loop
    game_instructions_complete:
    la $a0, inst_board1
    syscall

    #Print instructions (syscall 4)
    la $a0, inst_text1
    li $v0, 4
    syscall
    la $a0, inst_text2
    syscall
    la $a0, inst_text3
    syscall
    la $a0, inst_prompt
    syscall
    
    #Print input prompt (syscall 4)
    la $a0, input_prompt
    syscall

    #Read users' choice (syscall 12)
    li $v0, 12
    syscall

    lw $t3, 20($sp)
    lw $t2, 16($sp)
    lw $t1, 12($sp)
    lw $t0, 8($sp)
    lw $ra, 4($sp)          #Retrieve return address
    addiu $sp, $sp, 24      #Delete stack Space

jr $ra  #Return to previous function (caller)