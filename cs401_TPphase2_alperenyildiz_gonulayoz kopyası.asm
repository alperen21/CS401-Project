.data  
result: .space 4000
T0: .space 4                          # the pointers to your lookup tables
T1: .space 4                                     
T2:  .space 4                                 
T3:  .space 4                                 
fin: .asciiz "/Users/alperenyildiz/CS401-Project/tables.dat"      # put the fullpath name of the file AES.dat here
buffer: .space 20000                    # temporary buffer to read from file
s:    .word 0xd82c07cd, 0xc2094cbd, 0x6baa9441, 0x42485e3f
rkey: .word 0x82e2e670, 0x67a9c37d, 0xc8a7063b, 0x4da5e71f
rkeyy: .space 4000
rcon: .word 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01
key: .word 0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c
t: .space 16
test_data: .asciiz "f"
temp: .space 5000
char_x: .ascii "x"
message: .word 0x6bc1bee2, 0x2e409f96, 0xe93d7e11, 0x7393172a

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
addiu $t1, $a0, 5    			# Get the address of the 6th character (index 5)
lb $t2, 0($t1)       			# Load the ASCII value into $t2
addi $a0, $zero, 1
addi $a1, $zero, 1

jal READ_FILE


jal ENCRYPT
j Exit
jal ROUND_OPERATION_ALL


jal INIT_RKEY
move $a0, $zero
la $s0, result
subi $s0, $s0, 4
jal KEY_SCHEDULE
jal STORE_KEYS #first iteration

addi $a0, $a0, 1
jal KEY_SCHEDULE
jal STORE_KEYS #second iteration

addi $a0, $a0, 1
jal KEY_SCHEDULE
jal STORE_KEYS #third iteration

addi $a0, $a0, 1
jal KEY_SCHEDULE
jal STORE_KEYS #fourth iteration


addi $a0, $a0, 1
jal KEY_SCHEDULE
jal STORE_KEYS #five iteration

addi $a0, $a0, 1
jal KEY_SCHEDULE
jal STORE_KEYS #sixth iteration


addi $a0, $a0, 1
jal KEY_SCHEDULE
jal STORE_KEYS #seventh iteration

addi $a0, $a0, 1
jal KEY_SCHEDULE
jal STORE_KEYS #eigth iteration




#move $a0, $zero
#la $a1, rkey
#jal ROUND_OPERATION

j Exit
READ_FILE:
sub $sp, $sp, 4   			# we adjust the stack for saving return address and argument
sw  $ra, 0($sp)   			# stores the return address in stack
la $t0, char_x
lb $t1, 0($t0)
move $t2, $zero 			#read boolean value
move $t3, $zero
move $t4, $zero
### while (int i < 4)###
jal OPEN_FILE
LOOP_1:
	slti $t5, $t4, 4
	beq $t5, $zero, EXIT_LOOP_1
	move $a3, $zero
	move $t0, $zero
	move $t8, $zero 		#to keep track of at which word we are at
LOOP_2:
	addi $t0, $t0, 1
	slti $t1, $t0, 3072
	beq $t1, $zero, EXIT_LOOP_2
	jal READ_CHAR
	move $s3, $v0
	lb $s3, ($s3)
	subi $s7, $s3, 48		# the ascii value of x: 48
	bne $s7, $zero, LOOP_2
	move $s4, $zero 		# index for LOOP3, i = 0
	move $s7, $zero 		# concat integer, currently 0
	addi $t7, $zero, 28 		# sll amount, 28 in the first iteration, 24 in the second,...	
	
	jal READ_CHAR
		
LOOP_3:
	slti $s5, $s4, 8  		# $s5 = 1 if i < 8
	beq $s5, $zero, END_LOOP_3 	# if $s5 is 0, meaning that i >= 8, terminate the loop
	jal READ_CHAR
			
	move $a0, $v0
	jal CHAR_TO_NUM
	move $s3, $v0
	sllv $s3, $s3, $t7 		# shift the int that is read to the left by the shift amount 
	or $s7, $s7, $s3 		# logical or will concatenate the integer values and will turn the hexa number to binary
	addi $t7, $t7, -4 		# shift amount -= 4
	addi $s4, $s4, 1 		# i += 1
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
	sub $sp, $sp, 44
	sw $ra, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	sw $a0, 36($sp)
	sw $a1, 40($sp)
	
	#move $s0, $zero			# i = 0 and is kept in $s0
	#move $s1, $zero  			# j = 0 and is kept in $s1
		
	la $s0, T0				# $s0 keeps the address of TO
	lw $s0, 0($s0)
	la $s1, T1				# $s1 keeps the address of T1
	lw $s1, 0($s1)
	la $s2, T2				# $s2 keeps the address of T2
	lw $s2, 0($s2)
	la $s3, T3				# $s3 keeps the address of T3
	lw $s3, 0($s3)
	
	move $s4, $zero				# $s4 is for the result 
	
	sll $t2, $a0, 2				# t2 = 4i
	add $t2, $t2, $a1			# t2  = &rkey[i]
	lw $t2, 0($t2)				# t2 = rkey[i]
	xor $s4, $s4, $t2			# s4 = rkey[i]
	
	la $t0, s				# the address of s is kept in $t0
	move $s5, $t0				# to save the address of s
	
	sll $t1, $a0, 2				# i = 4i and is kept in $t1
	add $t2, $t0, $t1			# $t2 = &s[i]
	lw $t2, 0($t2)				# $t2 = s[i]
	
	srl $t2, $t2, 24			# s[i] >> 24
	sll $t2, $t2, 2				
	add $t3, $s3, $t2			# $t3 = &T3[s[i] >> 24]
	lw $t3, 0($t3) 				# $t3 = T3[s[i] >> 24]
	
	xor $s4, $s4, $t3			# result = rkey[i] ^ T3[s[i] >> 24]
	
	jal INCREMENT_INDEX			
	move $a0, $v0				# $a0 += 1
	
						# second phase
	sll $t1, $a0, 2				# 4(i+1)
	add $t2, $s5, $t1			# t2 = &s[i+1]
	lw $t2, 0($t2)				# t2 = s[i+1]	
	
	srl $t2, $t2, 16			# t2 = s[i+1] >> 16
	and $t2, $t2, 0xff			# t2 = (s[i+1] >> 16) & 0xff
	sll $t2, $t2, 2				# to calculate address
	add $t2, $t2, $s1			# t2 = &T1[(s[i+1] >> 16) & 0xff]
	lw $t2, 0($t2)				# t2 = T1[(s[i+1] >> 16) & 0xff]
	
	xor $s4, $s4, $t2			# result = rkey[i] ^ T3[s[i] >> 24] ^ T1[(s[i+1] >> 16) & 0xff]
	
	jal INCREMENT_INDEX
	move $a0, $v0
	
	sll $t1, $a0, 2				# 4(i+2)
	add $t2, $s5, $t1			# t2 = &s[i+2]
	lw $t2, 0($t2)				# t2 = s[i+2]
	
	srl $t2, $t2, 8				# $t2 = s[i+2] >> 8
	and $t2, $t2, 0xff			# $t2 = s[i+2] >> 8 & 0xff
	sll $t2, $t2, 2				# to calculate address
	add $t2, $t2, $s2     			# $t2 = &T2[s[i+2] >> 8 & 0xff]
	lw $t2, 0($t2) 				# $t2 = T2[s[i+2] >> 8 & 0xff]
	xor $s4, $s4, $t2			# result = rkey[i] ^ T3[s[i] >> 24] ^ T1[(s[i+1] >> 16) & 0xff] ^ T2[s[i+2] >> 8 & 0xff]
	
	jal INCREMENT_INDEX
	move $a0, $v0			
	
	sll $t1, $a0, 2				# 4(i+3)
	add $t2, $s5, $t1			# t2 = &s[i+3]
	lw $t2, 0($t2)				# t2 = s[i+3]
	and $t2, $t2, 0xff			# $t2 = s[i+3] & 0xff
	sll $t2, $t2, 2
	add $t2, $t2, $s0			# $t2 = &T0[s[i+3] & 0xff]
	lw $t2, 0($t2)				# $t2 = T0[s[i+3] & 0xff]
	
	xor $s4, $s4, $t2			# result = rkey[i] ^ T3[s[i] >> 24] ^ T1[(s[i+1] >> 16) & 0xff] ^ T2[s[i+2] >> 8 & 0xff] ^ T0[s[i+3] & 0xff]
	
	
	move $v0, $s4
	
	# END OF THE PROCEDURE #
	lw $ra, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	lw $a0, 36($sp)
	lw $a1, 40($sp)
	sub $sp, $sp, -44
	jr $ra
	
INCREMENT_INDEX:
	sub $sp, $sp, 8
	sw $ra, 4($sp)				# for return address
	sw $a0, 0($sp)
	addi $a0, $a0, 1			# incrementing the index by 1
	
	slti $t0, $a0, 4			# checking if the index is greater than 3
	bne $t0, $zero, EXIT_INCREMENT
	
	subi $a0, $a0, 4
	
EXIT_INCREMENT:
	addi $v0, $a0, 0
	lw  $ra, 4($sp)				# for return address
	lw $a0, 0($sp)				# for index 
	sub $sp, $sp, -8  
	jr $ra
ROUND_OPERATION_ALL:
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	move $t4, $zero
	
ROUND_OPERATION_ALL_LOOP:			# initialize index as 0
	slti $t5, $t4, 4			# check if index is smaller than 4
	beq $t5, 0, EXIT_LOOP			# if index is not smaller than 4, exit loop
	
	
	la $a1, rkey
	move $a0, $t4
	jal ROUND_OPERATION
	
	la $t5, t				# $t5 = &t
	sll $t6, $t4,2				# t6 = 4i
	add $t6, $t6, $t5			# t6 = &t[i]
	sw $v0, 0($t6)				# t[i] = v0 which is the result of ROUND_OPERATION
	
	addi $t4, $t4, 1
	j ROUND_OPERATION_ALL_LOOP
	EXIT_LOOP:
	
	lw  $ra, 0($sp)				# for return address
	sub $sp, $sp, -4
	jr $ra
	

KEY_SCHEDULE:
	sub $sp, $sp, 48
	sw $ra, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	sw $a0, 36($sp)
	sw $a1, 40($sp)
	sw $s0, 44($sp)
	

	
	
	la $s0, rkeyy			#s0 = &rkeyy[0]
	addi $s0, $s0, 8		#s0 = &rkeyy[2]
	
	lw $s1, 0($s0)			#s1 = rkeyy[2]
	srl $s1, $s1, 24		#s1 = rkeyy[2] >> 24
	and $s1, $s1, 0xFF		#s1 = a
	
	
	lw $s2, 0($s0)			#s2 = rkeyy[2]
	srl $s2, $s2, 16		#s2 = rkeyy[2] >> 24
	and $s2, $s2, 0xFF		#s2 = b
	
	
	lw $s3, 0($s0)			#s3 = rkeyy[2]
	srl $s3, $s3, 8			#s3 = rkeyy[2] >> 24
	and $s3, $s3, 0xFF		#s3 = c
	
	
	lw $s4, 0($s0)			#s4 = rkeyy[2]
	and $s4, $s4, 0xFF		#s4 = d
	
	la $s5, T2
	lw $s5, 0($s5)			#s5 = &T2[0]
	
	sll $s2, $s2, 2
	add $s2, $s5, $s2		#s2 = &T2[b]
	lw $s2, 0($s2)			#s2 = T2[b]
	and $s2, $s2, 0xFF		#s2 = T2[b] & 0xFF
	
	

	sll $s3, $s3, 2
	add $s3, $s5, $s3		#s3 = &T2[c]
	lw $s3, 0($s3)			#s3 = T2[c]
	and $s3, $s3, 0xFF		#s3 = f
	
	sll $s4, $s4, 2
	add $s4, $s5, $s4		#s4 = &T2[d]
	lw $s4, 0($s4)			#s4 = T2[d]
	and $s4, $s4, 0xFF		#s4 = g
	
	sll $s1, $s1, 2
	add $s1, $s5, $s1		#s1 = &T2[a]
	lw $s1, 0($s1)			#s1 = T2[a]
	and $s1, $s1, 0xFF		#s1 = h
	
	la $s6, rcon
	sll $a0, $a0, 2
	add $s6, $s6, $a0
	lw $s6, 0($s6)			#s6 = rcon[i]
	
	xor $s2, $s2, $s6		#s2 = e
	
	# e = s2
	# f = s3
	# g = s4
	# h = s1
	
	move $s5, $zero				# s5 = result
	
	sll $s2, $s2, 24
	sll $s3, $s3, 16
	sll $s4, $s4, 8
	
	xor $s5, $s5, $s2
	xor $s5, $s5, $s3
	xor $s5, $s5, $s4
	xor $s5, $s5, $s1 			# s6 = tmp
	
	# s0 = &rkey[0]
	# s1 = rkey[0]
	# s2 = rkey[1]
	# s3 = rkey[2]
	# s4 = rkey[3]
	
	la $s0, rkeyy				#s0 = &rkeyy[0]
	
	lw $s1, 0($s0)				#s1 = rkeyy[0]
	xor $s1, $s1, $s5			#s1 = rkeyy[0] ^ tmp
	sw $s1, 0($s0)				# rkeyy[0] = rkeyy[0] ^ tmp
	
	addi $s0, $s0, 4			#s0 = &rkeyy[1]
	lw $s2, 0($s0)				#s2 = rkeyy[0]
	xor $s2, $s2, $s1
	sw $s2, 0($s0)				# rkeyy[1] = rkeyy[1] ^ rkeyy[0]
	
	
	addi $s0, $s0, 4			#s0 = &rkeyy[1]
	lw $s3, 0($s0)				#s2 = rkeyy[0]
	xor $s3, $s3, $s2
	sw $s3, 0($s0)				# rkeyy[1] = rkeyy[1] ^ rkeyy[0]
	
	addi $s0, $s0, 4			#s0 = &rkeyy[1]
	lw $s4, 0($s0)				#s2 = rkeyy[0]
	xor $s4, $s4, $s3
	sw $s4, 0($s0)				# rkeyy[1] = rkeyy[1] ^ rkeyy[0]
	
	# s1 = rkey[0]
	# s2 = rkey[1]
	# s3 = rkey[2]
	# s4 = rkey[3]
	
	
	lw $ra, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	lw $a0, 36($sp)
	lw $a1, 40($sp)
	lw $s0, 44($sp)
	sub $sp, $sp, -48

	jr $ra

STORE_KEYS:
	# s0 -> where we left at the array (address)
	sub $sp, $sp, 44
	sw $ra, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	sw $a0, 36($sp)
	sw $a1, 40($sp)
	
	la $s1, rkeyy		# s1 = &rkeyy[0]
	
	
	addi $s0, $s0, 4
	lw $s2, 0($s1)		# s2 = rkeyy[0]
	sw $s2, 0($s0)		# result[0] = rkeyy[0]
	
	
	
	addi $s1, $s1, 4
	addi $s0, $s0, 4
	lw $s2, 0($s1)		# s2 = rkeyy[1]
	sw $s2, 0($s0)		# result[1] = rkeyy[1]
	
	addi $s1, $s1, 4
	addi $s0, $s0, 4
	lw $s2, 0($s1)		# s2 = rkeyy[2]
	sw $s2, 0($s0)		# result[2] = rkeyy[2]
	
	addi $s1, $s1, 4
	addi $s0, $s0, 4
	lw $s2, 0($s1)		# s2 = rkeyy[3]
	sw $s2, 0($s0)		# result[3] = rkeyy[3]
	
	
	
	
	
	
	
	lw $ra, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	lw $a0, 36($sp)
	lw $a1, 40($sp)
	sub $sp, $sp, -44
	
	jr $ra
	
	
INIT_RKEY:
	sub $sp, $sp, 44
	sw $ra, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	sw $a0, 36($sp)
	sw $a1, 40($sp)
	
	
	la $s0, rkeyy			#s0 = &rkeyy[0]
	la $s1, key			#s1 = &key[0]
	
	lw $s2, 0($s1)			#s2 = key[0]
	sw $s2, 0($s0)			#store
	
	addi $s1, $s1, 4		#s1 = &key[1]
	addi $s0, $s0, 4		#s0 = &rkeyy[1]
	lw $s2, 0($s1)			#s2 = key[1]
	sw $s2, 0($s0)			#store
	
	addi $s1, $s1, 4		#s1 = &key[2]
	addi $s0, $s0, 4		#s0 = &rkeyy[2]
	lw $s2, 0($s1)			#s2 = key[2]
	sw $s2, 0($s0)			#store
	
	addi $s1, $s1, 4		#s1 = &key[3]
	addi $s0, $s0, 4		#s0 = &rkeyy[3]
	lw $s2, 0($s1)			#s2 = key[3]
	sw $s2, 0($s0)			#store
	
	


	lw $ra, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	lw $a0, 36($sp)
	lw $a1, 40($sp)
	sub $sp, $sp, -44
	
	jr $ra


KEY_WHITENING:

	sub $sp, $sp, 44
	sw $ra, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	sw $a0, 36($sp)
	sw $a1, 40($sp)
	
	la $s0, key	# s0 = key
	la $s1, message	# s1 = message
	la $s7, s
	
	move $s2, $zero	#s2 = index
	
	
	
	KW_LOOP:
	slti $s3, $s2, 4
	beq $s3, $zero, KW_LOOP_END
	
	sll $s3, $s2, 2 # s3 = 4 * s2 (index multiplied with 4 to calculate address)
	
	add $s4, $s0, $s3 # s3 = &key[i]
	lw $s4, 0($s4)	#s3 = key[i]
	
	add $s5, $s1, $s3 # s4 = &message[i]
	lw $s5, 0($s5) # s4 = message[i]
	
	
	xor $s6, $s4, $s5 # s6 = key[i] ^ message[i]
	
	
	add $t0, $s7, $s3 #t0 = &s[i]
	sw $s6, 0($t0) # s[i] = key[i] ^ message[i]
	
	addi $s2, $s2, 1
	j KW_LOOP
	KW_LOOP_END:
	
	
	

	lw $ra, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	lw $a0, 36($sp)
	lw $a1, 40($sp)
	sub $sp, $sp, -44
	
	jr $ra

ENCRYPT:

sub $sp, $sp, 44
sw $ra, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)
sw $s7, 32($sp)
sw $a0, 36($sp)
sw $a1, 40($sp)
	
jal KEY_WHITENING # s becomes the whitened key



jal INIT_RKEY
move $s1, $zero #index for the loop
la $s0, result #s0 = result

la $s3, s


E_LOOP:
	slti $t0, $s1, 8
	beq $t0, $zero, E_LOOP_EXIT
	
	move $a0, $s1

	jal KEY_SCHEDULE
	jal STORE_KEYS
	
	move $a0, $zero
	
	la $a1, rkeyy	
	
	jal ROUND_OPERATION
	move $s4, $v0
	
	addi $a0, $a0, 1
	jal ROUND_OPERATION
	move $s5, $v0
	
	addi $a0, $a0, 1
	jal ROUND_OPERATION
	move $s6, $v0
	
	addi $a0, $a0, 1
	jal ROUND_OPERATION
	move $s7, $v0
	
	
	sw $s4 ,0($s3)
	sw $s5 ,4($s3)
	sw $s6 ,8($s3)
	sw $s7 ,12($s3)

	addi $s1, $s1, 1
j E_LOOP
E_LOOP_EXIT:


lw $ra, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
lw $s7, 32($sp)
lw $a0, 36($sp)
lw $a1, 40($sp)
sub $sp, $sp, -44
	
jr $ra




Exit:
	li $v0,10
	syscall             			#exits the program