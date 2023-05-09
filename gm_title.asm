.data
title_name:  .asciiz " ______  __   ______       ______  ______   ______       ______  ______   ______    \n/\\__  _\\/\\ \\ /\\  ___\\     /\\__  _\\/\\  __ \\ /\\  ___\\     /\\__  _\\/\\  __ \\ /\\  ___\\   \n\\/_/\\ \\/\\ \\ \\\\ \\ \\____    \\/_/\\ \\/\\ \\  __ \\\\ \\ \\____    \\/_/\\ \\/\\ \\ \\/\\ \\\\ \\  __\\   \n   \\ \\_\\ \\ \\_\\\\/\\_____\\      \\ \\_\\ \\ \\_\\ \\_\\\\ \\_____\\      \\ \\_\\ \\ \\_____\\\\ \\_____\\ \n    \\/_/  \\/_/ \\/_____/       \\/_/  \\/_/\\/_/ \\/_____/       \\/_/  \\/_____/ \\/_____/ \n"
title_credits: .asciiz "     TIC-TAC-TOE v1: 2023 Jesus Aguayo\n\n\n"
title_prompt: .asciiz "\t\t\t       Enter any key to start\n\n"

.text

.globl game_title
game_title:
    #Print game title (syscall 4)
    la $a0, title_name
    li $v0, 4
    syscall
    #Print game credits (syscall 4)
    la $a0, title_credits
    syscall
    #Print option 1: start game (syscall 4)
    la $a0, title_prompt
    syscall
    #Print input prompt (syscall 4)
    la $a0, input_prompt
    syscall

    #Read users' choice (syscall 12)
    li $v0, 12
    syscall
    
jr $ra  #Return to main function
