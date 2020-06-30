.data
array: 	.byte 95:42 # creates an array of 42 chars and sets each one as a underscore space since 95 is the decimal value for underscore
Leftborder: 	.asciiz "|" # used for the border on the left side
Rightborder: 	.asciiz "|" # used for the border on the right side and all the underscore in the middle
newline: 	.asciiz "\n" # makes a new line
prompt:		.asciiz "Please enter a number between 1 and 7: "
player1:	.asciiz "X"
computer:	.asciiz "O"
underscore:	.asciiz "_"
Columeful:	.asciiz "The column you are trying to add to is full. Please enter a different number between 1 and 7: "
Instruction:	.asciiz "Please enter a number betweeen 1 and 7: "
comp:		.asciiz "After the computer's turn, the board looks like this:\n"
start:		.asciiz "Wow! A new game starts now!"
player1Win: 	.asciiz "\nCongrulations! You Win!\n"
CompWin: 	.asciiz "\nOh! You lose!\n"
newGame: 	.asciiz "Enter 1 if you would like to play again and 0 if you would like to quit: "

a0:.byte 30
a2:.byte 25
a3:.byte 100
a00:.byte 52
a22:.byte 7
wina0:.byte 72
wina2:.byte 10
wina00:.byte 84
wina000:.byte 88  ##set the sound elements

.text
main: 					
	jal PrintPlayBoard               ##display  Board
	la $a0, newline
	li $v0, 4
	syscall
input: 
	la $a0, prompt
	li $v0, 4
	syscall 			#prompt user to enter number
	
	li $v0, 5
	syscall 			#retrieve column number
	
	li $t1, 8
Loop:					
	add $s0, $v0, $zero             #move the column number to $s0
	
	li $t0, 0			
	slt $t2, $s0, $t1               #check whether the number is between 1 and 7
	
	beq $t2, $zero, InValid	
	slt $t2, $t0, $s0
	beq $t2, $zero, InValid
	
	addi $s0, $s0, -1
	addi $s0, $s0, 35 		#start checking at bottom row
	lb $t0, underscore
loop:	
	lb $t1, array($s0)
	beq $t0, $t1, playerAdd 		#check whether there is number or not.if empty, add the new number
	addi $s0, $s0, -7 		#move up a row
	li $t2, -1
	
	slt $t2, $t2, $s0		#branch to FULL if the column is full
	beq $t2, $zero, Full
	j loop
	
cominput:					
	li $a1, 7                        #generates random number
	li $v0, 42
	syscall
	
	add $s0, $a0, $zero		#set the $s0 random number
	addi $s0, $s0, 35
	lb $t0, underscore
com:	
	lb $t1, array($s0)
	beq $t0, $t1, comAdd             # if empty and then add the number
	addi $s0, $s0, -7
	li $t2, 0
	
	slt $t2, $t2, $s0		#jump to cominput to generate a new random number if the column is full
	beq $t2, $zero, cominput
	j com
	
playerAdd:					#add a piece for user (X's)
	lb $t0, player1
	sb $t0, array($s0)

        li $v0,31
        li $a1,750
        lb $a0,a00
        lb $a2,a22
        lb $a3,a3
        syscall                           # play correct sound
	
	
	jal PrintPlayBoard 		#display updated board
	
	lb $t0, player1
	jal Checkwinner 			#checks if they won
	
	add $s1, $s0, $zero
	
	la $a0, newline
	li $v0, 4
	syscall
	
	j cominput				#play the computer's turn
	
comAdd:					#add a piece for computer (O's)
	lb $t0, computer
	sb $t0, array($s0)
	
	la $a0, comp			#display updated board 
	li $v0, 4
	syscall
	
	jal PrintPlayBoard
	
	lb $t0, computer
	jal Checkwinner
	
	la $a0, newline
	li $v0, 4
	syscall
	
	j main
	
Full:
        li $v0,31
        li $a1,1000
        lb $a0,a0
        lb $a2,a2
        lb $a3,a3
        syscall                         #play error sound
				
					
	la $a0, Columeful			#tells user that Full Column information 
	li $v0, 4
	syscall 
	
	li $v0, 5			#let user to type a new number
	syscall 
	j Loop 				#jump back 

	
InValid:

        li $v0,31
        li $a1,1000
        lb $a0,a0
        lb $a2,a2
        lb $a3,a3
        syscall                         #play error sound
				
					
	la $a0, Instruction			#prompt user again
	li $v0, 4
	syscall 
	li $v0, 5			#get the new number
	syscall 
	j Loop 				#jump back 

Boardunpate:				#resets the game board
	lb $s0, underscore
	add $t0, $zero, $zero

arrayclean:	
	beq $t0, 42, newInstruction
	sb $s0, array($t0)
	addi $t0, $t0, 1
	j arrayclean

	
newInstruction:					#give the user a message that the board was cleared and the game is restarting
	la $a0, start
	li $v0, 4
	syscall
	
	la $a0, newline
	li $v0, 4
	syscall
	
	j main 				#jump back to beginning

PrintPlayBoard: 				#displays the board
	subu $sp, $sp, 4 		#adds enough room on the stack for the return address
	sw $ra, ($sp)
   
	add $t0, $zero, $zero 		#$t0 is set to 0
   
while: 
	beq $t0, 42, exit 		#loops until all the array has been displayed
 
	la $a0, Leftborder 		#displays the left border
	li $v0, 4
	syscall
            
        add $t1, $zero, $zero		#makes sure $t1 is set to zero on each starting for new column
            
row: 
	beq $t1, 7, RowComplete 	#when a row is displayed and then need to jump for making a new line
      
	lb $a0, array($t0) 		#loads the byte(Defaults is underscore) into $a0 to be displayed
	li $v0, 11 			
	syscall
             
	la $a0, Rightborder			# displays a right border mark
	li $v0, 4
	syscall
            
	addi $t0, $t0, 1		#increments the values of $t0 and $t1 for counting 
	addi $t1, $t1, 1
            
	j row 				#jumps back to row   
	
RowComplete:
	la $a0, newline			#makes a new line for the next row
	li $v0, 4
	syscall
	j while

exit:
	lw $ra, ($sp)
	addu $sp, $sp, 4
	jr $ra
  
Checkwinner:				
	subu $sp, $sp, 4
	sw $ra, 0($sp)
    
	add $t2, $zero, $t0 		#load current piece into t2
	add $t0, $zero, $zero
	
	add $s1, $s0, $zero
	jal HorRight
	addi $t0, $t0, -1
	add $s1, $s0, $zero
	jal HorLeft
    
	add $s1, $s0, $zero
	add $t0, $zero, $zero
    
	add $s1, $s0, $zero
	jal VerDown
    
	add $t0, $zero, $zero
	add $s1, $s0, $zero
	jal DiagLeft
    
	add $t0, $zero, $zero
	add $s1, $s0, $zero
	jal DiagRight

	lw $ra, 0($sp)
	addu $sp, $sp, 4
	jr $ra
    
HorRight:
	subu $sp, $sp, 4
	sw $ra, ($sp)

	addi $t6, $zero, 1 		#checking horizontally from the right (next piece)

	addi $t5, $zero, 7
	slt $t4, $s1, $t5
	beq $t4, 1, CheckLoop

	addi $t5, $zero, 14
	slt $t4, $s1, $t5
	beq $t4, 1, CheckLoop

	addi $t5, $zero, 21
	slt $t4, $s1, $t5
	beq $t4, 1, CheckLoop

	addi $t5, $zero, 28
	slt $t4, $s1, $t5
	beq $t4, 1, CheckLoop

	addi $t5, $zero, 35
	slt $t4, $s1, $t5
	beq $t4, 1, CheckLoop

	addi $t5, $zero, 42
	slt $t4, $s1, $t5
	beq $t4, 1, CheckLoop

HorLeft:
	subu $sp, $sp, 4
	sw $ra, ($sp)

	addi $t6, $zero, -1 		#checking horizontally from the left (next piece)

	addi $t5, $zero, 7
	slt $t4, $s1, $t5
	subi $t5, $zero, 8
	beq $t4, 1, CheckLoop

	addi $t5, $zero, 14
	slt $t4, $s1, $t5
	subi $t5, $zero, 8
	beq $t4, 1, CheckLoop

	addi $t5, $zero, 21
	slt $t4, $s1, $t5
	subi $t5, $zero, 8
	beq $t4, 1, CheckLoop

	addi $t5, $zero, 28
	slt $t4, $s1, $t5
	subi $t5, $zero, 8
	beq $t4, 1, CheckLoop

	addi $t5, $zero, 35
	slt $t4, $s1, $t5
	subi $t5, $zero, 8
	beq $t4, 1, CheckLoop

	addi $t5, $zero, 42
	slt $t4, $s1, $t5
	subi $t5, $zero, 8
	beq $t4, 1, CheckLoop

VerDown:        
	subu $sp, $sp, 4
	sw $ra, ($sp)

	li $t5, 42
	addi $t6, $zero, 7
	j CheckLoopVertDown

DiagLeft:        
	subu $sp, $sp, 4
	sw $ra, ($sp)

	li $t5, 0
	addi $t8, $zero, 7
	addi $s3, $zero, 1
	j CheckLoopDiagLeft

DiagRight:        
	subu $sp, $sp, 4
	sw $ra, ($sp)

	li $t5, 0
	addi $t8, $zero, 7
	j CheckLoopDiagRight

CheckLoop:
	beq $t0, 4, HaveWinner
	beq $s1, $t5, noWinner
	lb $t3, array($s1)
	bne $t3, $t2, noWinner 		#checks if pieces match
	addi $t0, $t0, 1
	add $s1, $s1, $t6
	
	j CheckLoop
     
    
CheckLoopVertDown:
	beq $t0, 4, HaveWinner
	slt $t4, $s1, $t5
	beq $t4, $zero, noWinner
	lb $t3, array($s1)
	bne $t3, $t2, noWinner		#checks if pieces match
	addi $t0, $t0, 1
	add $s1, $s1, $t6
	
	j CheckLoopVertDown
    
CheckLoopVertUp:
	beq $t0, 4, HaveWinner
	slt $t4, $t5, $s1
	beq $t4, $zero, noWinner
	lb $t3, array($s1)
	bne $t3, $t2, noWinner		#checks if pieces match
	addi $t0, $t0, 1
	add $s1, $s1, $t6
	
	j CheckLoopVertUp
	
CheckLoopDiagLeft:
	beq $t0, 4, HaveWinner
	slt $t4, $t5, $s1
	beq $t4, $zero, noWinner
	blt $s3, 1, CheckLoopDiaLeft2
	div $s1, $t8
	mflo $s2			#row number
	mfhi $s3			#column number
	addi $s2, $s2, 1
	addi $s3, $s3, -1
	lb $t3, array($s1)
	bne $t3, $t2, noWinner		#checks if pieces match
	addi $t0, $t0, 1
	mul $s1, $s2, $t8
	add $s1, $s1, $s3
	
	j CheckLoopDiagLeft
	
CheckLoopDiaLeft2:
	lb $t3, array($s1)
	bne $t3, $t2, noWinner
	addi $t0, $t0, 1
	beq $t0, 4, HaveWinner
	
	j noWinner

CheckLoopDiagRight:
	beq $t0, 4, HaveWinner
	slt $t4, $t5, $s1
	beq $t4, $zero, noWinner
	bgt $s3, 5, CheckLoopDiaRight2
	div $s1, $t8
	mflo $s2			#row number
	mfhi $s3			#column number
	addi $s2, $s2, 1
	add $s3, $s3, 1
	lb $t3, array($s1)		
	bne $t3, $t2, noWinner		#checks if pieces match
	addi $t0, $t0, 1
	mul $s1, $s2, $t8
	add $s1, $s1, $s3
	
	j CheckLoopDiagRight
	
CheckLoopDiaRight2:
	lb $t3, array($s1)
	bne $t3, $t2, noWinner
	addi $t0, $t0, 1
	beq $t0, 4, HaveWinner
	
	j noWinner

noWinner:
        lw $ra, ($sp)
        addu $sp, $sp, 4 
        jr $ra
	
HaveWinner:



###play winner sound###
li $v0,32
li $a0,1000
syscall

li $v0,31
li $a1,500
lb $a0,wina0
lb $a2,wina2
lb $a3,a3
syscall

li $v0,32
li $a0,500
syscall

li $v0,33
li $a1,500
lb $a0,a00
lb $a2,wina2
lb $a3,a3
syscall
li $v0,31
li $a1,500
lb $a0,wina0
lb $a2,wina2
lb $a3,a3
syscall

li $v0,32
li $a0,500
syscall

li $v0,33
li $a1,500
lb $a0,wina000
lb $a2,wina2
lb $a3,a3
syscall



     	lb $t7, computer
     	beq $t7, $t2, ComputerWin
        la $a0, player1Win
        li $v0, 4
        syscall

        li $v0,31
        li $a1,750
        lb $a0,a00
        lb $a2,a22
        lb $a3,a3
        syscall                          #play correct sound
        
        la $a0, newGame			#prompt the user to start a new game
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        
        bne $v0, $zero, Boardunpate	#reset the board if the input isn't 0
        
        li $v0, 10			#terminate the game
        syscall
 
ComputerWin:
        la $a0, CompWin
        li $v0, 4
        syscall
        
        la $a0, newGame			#prompt the user to start a new game
        li $v0, 4
        syscall
        
        li $v0, 5
        syscall
        
        bne $v0, $zero, Boardunpate	#reset the board if the input isn't zero
        
        li $v0, 10			#terminate the game
        syscall
