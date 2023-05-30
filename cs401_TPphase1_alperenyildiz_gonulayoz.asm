.data  
T0: .space 4                          # the pointers to your lookup tables
T1: .space 4                                     
T2:  .space 4                                 
T3:  .space 4                                 
fin: .asciiz "/Users/Gonul/CS401-Project/tables.dat"      # put the fullpath name of the file AES.dat here
buffer: .space 20000                    # temporary buffer to read from file

s:    .word 0xd82c07cd, 0xc2094cbd, 0x6baa9441, 0x42485e3f
rkey: .word 0x82e2e670, 0x67a9c37d, 0xc8a7063b, 0x4da5e71f

test_data: .asciiz "f"
temp: .space 5000

char_x: .ascii "x"

.text

li $a0, 1024      			# Allocate 32 bytes
li $v0, 9       			# System call number for sbrk
syscall
move $t0, $v0   			# Move the base address to $t0
la $t1, T0
sw $t0, ($t1)

li $a0, 1024      			# Allocate 32 bytes
li $v0, 9       			# System call number for sbrk
syscall
move $t0, $v0   			# Move the base address to $t0
la $t1, T1 				#load address of T1
sw $t0, ($t1) 				#store the address of allocated space in T1

li $a0, 1024      			# Allocate 32 bytes
li $v0, 9       			# System call number for sbrk
syscall
move $t0, $v0   			# Move the base address to $t0
la $t1, T2 				#load address of T2
sw $t0, ($t1) 				#store the address of allocated space in T1

li $a0, 1024      			# Allocate 32 bytes
li $v0, 9       			# System call number for sbrk
syscall
move $t0, $v0   			# Move the base address to $t0
la $t1, T3 				#load address of T3
sw $t0, ($t1) 				#store the address of allocated space in T1


la $a0, test_data

addiu $t1, $a0, 5    # Get the address of the 6th character (index 5)
lb $t2, 0($t1)       # Load the ASCII value into $t2
addi $a0, $zero, 1
addi $a1, $zero, 1

jal READ_FILE
j ROUND_OPERATION
j Exit

READ_FILE:
sub $sp, $sp, 4   # we adjust the stack for saving return address and argument
sw  $ra, 0($sp)   # stores the return address in stack

la $t0, char_x
lb $t1, 0($t0)

move $t2, $zero #read boolean value
move $t3, $zero
move $t4, $zero


### while (int i < 4)###
jal OPEN_FILE

LOOP_1:
	slti $t5, $t4, 4
	beq $t5, $zero, EXIT_LOOP_1

	move $a3, $zero
	move $t0, $zero
	move $t8, $zero #to keep track of at which word we are at

LOOP_2:
	addi $t0, $t0, 1
	slti $t1, $t0, 3072
	beq $t1, $zero, EXIT_LOOP_2
	jal READ_CHAR
	move $s3, $v0
	lb $s3, ($s3)

	subi $s7, $s3, 48	# the ascii value of x: 48
	bne $s7, $zero, LOOP_2
	move $s4, $zero # index for LOOP3, i = 0
	move $s7, $zero # concat integer, currently 0
	addi $t7, $zero, 28 # sll amount, 28 in the first iteration, 24 in the second,...	
	
	jal READ_CHAR
		
LOOP_3:
	slti $s5, $s4, 8  # $s5 = 1 if i < 8
	beq $s5, $zero, END_LOOP_3 # if $s5 is 0, meaning that i >= 8, terminate the loop
	jal READ_CHAR
			
	move $a0, $v0
	jal CHAR_TO_NUM
	move $s3, $v0

	sllv $s3, $s3, $t7 # shift the int that is read to the left by the shift amount 
	or $s7, $s7, $s3 # logical or will concatenate the integer values and will turn the hexa number to binary

	addi $t7, $t7, -4 # shift amount -= 4
	addi $s4, $s4, 1 # i += 1

	j LOOP_3
		
END_LOOP_3:
        beq $t4, 0, T0_LABEL
	beq $t4, 1, T1_LABEL
	beq $t4, 2, T2_LABEL
	beq $t4, 3, T3_LABEL

T0_LABEL:
	la $t9, T0
	lw $t9, 0($t9)
	add $t9, $t9, $t8
	sll $v1, $a3, 2 
	add $t9, $t9, $v1
	sw $s7, 0($t9)
	addi $t8, $t8, 4
	j LOOP_2
		
T1_LABEL:
	la $t9, T1
	lw $t9, 0($t9)
	add $t9, $t9, $t8
	sll $v1, $a3, 2 
	add $t9, $t9, $v1
	sw $s7, 0($t9)
	addi $t8, $t8, 4
	j LOOP_2

T2_LABEL:
	la $t9, T2
	lw $t9, 0($t9)
	add $t9, $t9, $t8
	sll $v1, $a3, 2 
	add $t9, $t9, $v1
	sw $s7, 0($t9)
	addi $t8, $t8, 4
	j LOOP_2

T3_LABEL:
	la $t9, T3
	lw $t9, 0($t9)
	add $t9, $t9, $t8
	sll $v1, $a3, 2 
	add $t9, $t9, $v1
	sw $s7, 0($t9)
		
	addi $t8, $t8, 4
	j LOOP_2
	addi $a3, $a3, 4			#to increment the value that holds the number of the word
	jal LOOP_2
	
EXIT_LOOP_2:
	addi $t4, $t4, 1
	jal LOOP_1
	
EXIT_LOOP_1:
	lw  $ra, 0($sp) 
	addi $sp, $sp, 4   			# we adjust the stack for saving return address and argument
	jr $ra

OPEN_FILE:
	sub $sp, $sp, 4   			# we adjust the stack for saving return address and argument
	sw  $ra, 0($sp) 

	li   $v0, 13       			# system call for open file
	la   $a0, fin      			# file name
	li   $a1, 0        			# Open for reading
	li   $a2, 0
	syscall            			# open a file (file descriptor returned in $v0)
	move $s6, $v0      			# save the file descriptor 

	lw  $ra, 0($sp) 
	sub $sp, $sp, -4   			# we adjust the stack for saving return address and argument
	jr $ra

READ_CHAR:
	sub $sp, $sp, 4   			# we adjust the stack for saving return address and argument
	sw  $ra, 0($sp) 

	li   $v0, 14       			# system call for read from file
	move $a0, $s6      			# file descriptor 
	la   $a1, buffer   			# address of buffer to which to read
	li   $a2, 1        			# hardcoded buffer length
	syscall            			# read from file

	move $s0, $v0	   			# the number of characters read from the file
	la   $s1, buffer   
	move $v0, $s1
	lw  $ra, 0($sp) 
	sub $sp, $sp, -4  			# we adjust the stack for saving return address and argument
	jr $ra

CHAR_TO_NUM:
	sub $sp, $sp, 8   			# we adjust the stack for saving return address and argument
	sw  $ra, 4($sp)   			# stores the return address in stack
	sw  $a0, 0($sp)   			# stores the argument in stack
	move $t9, $a0 
	lb $t2, 0($t9)
	subi $t1, $t2, 48

	subi $t2, $t1, 10 			# $t2 is 0 if integer - 10 is 0, integer = 10
	slt $t3, $t2, $zero 			# $t2 < zero => $t3 = 1
	beq $t3, 1, EXIT_IF_1 

	subi $t1, $t1, 39

EXIT_IF_1:
	move $v0, $t1
	sub $sp, $sp, -8  
	jr $ra
	
ROUND_OPERATION:

	# BEGINNING OF THE PROCEDURE #
	sub $sp, $sp, 12
	sw $ra, 8($sp)				# for return address
	sw $a0, 4($sp)				# for index
	sw $a1, 0($sp)				# for rkey
	
	#move $s0, $zero			# i = 0 and is kept in $s0
	#move $s1, $zero  			# j = 0 and is kept in $s1
		
	la $s0, T0				# $s0 keeps the address of TO
	la $s1, T1				# $s1 keeps the address of T1
	la $s2, T2				# $s2 keeps the address of T2
	la $s3, T3				# $s3 keeps the address of T3
	
	move $s4, $zero				# $s4 is for the result 
	
	la $t0, s				# the address of s is kept in $t0
	sll $t1, $a0, 2				# i = 4i and is kept in $t1
	add $t2, $a0, $t1			# $t2 = &s[i]
	lw $t2, 0($t2)				# $t2 = s[i]
	
	srl $t2, $t2, 24			# s[i] >> 24
	sll $t2, $t2, 2				
	add $t3, $s3, $t2			# $t3 = &T3[s[i] >> 24]
	lw $t3, 0($t3) 				# $t3 = T3[s[i] >> 24]
	
	xor $s4, $s4, $t3			# result = T3[s[i] >> 24]
	
	# END OF THE PROCEDURE #
	lw  $ra, 8($sp)				# for return address
	lw $a0, 4($sp)				# for index
	lw $a1, 0($sp)	 			# for rkey
	sub $sp, $sp, -12  
	jr $ra
	
INCREMENT_INDEX:

	sub $sp, $sp, 8
	sw $ra, 4($sp)				# for return address
	sw $a0, 0($sp)
	
	addi $a0, $a0, 1			# incrementing the index by 1
	
	slti $t0, $a0, 4			# checking if the index is greater than 3
	bne $t0, $zero, EXIT_INCREMENT
	
	subi $a0, $a0, 4
	
EXIT_INCREMENT:
	
	addi $v0, $a0, 0
	lw  $ra, 4($sp)				# for return address
	lw $a0, 0($sp)				# for index 
	sub $sp, $sp, -8  
	jr $ra

Exit:
	li $v0,10
	syscall             			#exits the program
