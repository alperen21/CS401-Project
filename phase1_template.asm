.data  
T0: .space 4                           # the pointers to your lookup tables
T1: .space 4                           
T2: .space 4                           
T3: .space 4                           
fin: .asciiz "/Users/alperenyildiz/CS401-Project/tables.dat"      # put the fullpath name of the file AES.dat here
buffer: .space 5000                    # temporary buffer to read from file

test_data: .asciiz "f"
temp: .space 5000

char_x: .ascii "x"

.text


la $a0, test_data

addiu $t1, $a0, 5    # Get the address of the 6th character (index 5)
lb $t2, 0($t1)       # Load the ASCII value into $t2
    



addi $a0, $zero, 1
addi $a1, $zero, 1



jal READ_FILE

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
### while (int i < 4)###


	# jal READ_CHAR
	# move $a0, $v0
	# jal PRINT
	move $t0, $zero

	### while (j < 3070) ###
	LOOP_2:
		addi $t0, $t0, 1
		slti $t1, $t0, 3072
		beq $t1, $zero, EXIT_LOOP_2
	### while (j < 3070) ###
		jal READ_CHAR
		move $s3, $v0
		#move $s6, $v0
		lb $s3, ($s3)

		# subi $a0, $zero, 1
		# jal PRINT_INT
		# move $a0, $s3
		# jal PRINT_INT

		subi $s7, $s3, 48	# the ascii value of x: 48

		bne $s7, $zero, LOOP_2

		move $s4, $zero # index for LOOP3, i = 0
		move $s7, $zero # concat integer, currently 0
		addi $t7, $zero, 28 # sll amount, 28 in the first iteration, 24 in the second,...
		
	
		jal READ_CHAR

		## 8 kere say ###
		LOOP_3:
			slti $s5, $s4, 8  # $s5 = 1 if i < 8
			beq $s5, $zero, END_LOOP_3 # if $s5 is 0, meaning that i >= 8, terminate the loop

			jal READ_CHAR
			move $s3, $v0

			sllv $s3, $s3, $t7 # shift the int that is read to the left by the shift amount 
			or $s7, $s7, $s3 # logical or will concatenate the integer values and will turn the hexa number to binary


			addi $t7, $t7, -4 # shift amount -= 4
			addi $s4, $s4, 1 # i += 1

			
		



		j LOOP_3
		END_LOOP_3:

		addi $t7, $zero, 1
		li $t0, 3
		sll $t7, $t7, $t0

		move $a0, $t7
		jal PRINT_INT


		

	### endwhile (j < 3070) ###
	jal LOOP_2
	EXIT_LOOP_2:
	### endwhile (j < 3070) ###
	

	addi $t4, $t4, 1

### endwhile (int i < 4)###
	jal LOOP_1
EXIT_LOOP_1:
### endwhile (int i < 4)###

lw  $ra, 0($sp) 
addi $sp, $sp, 4   # we adjust the stack for saving return address and argument
jr $ra

OPEN_FILE:
#open a file for writing
sub $sp, $sp, 4   # we adjust the stack for saving return address and argument
sw  $ra, 0($sp) 

li   $v0, 13       # system call for open file
la   $a0, fin      # file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

lw  $ra, 0($sp) 
sub $sp, $sp, -4   # we adjust the stack for saving return address and argument

jr $ra

READ_CHAR:
sub $sp, $sp, 4   # we adjust the stack for saving return address and argument
sw  $ra, 0($sp) 
#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, buffer   # address of buffer to which to read
li   $a2, 1        # hardcoded buffer length
syscall            # read from file

move $s0, $v0	   # the number of characters read from the file
la   $s1, buffer   # 

move $v0, $s1

lw  $ra, 0($sp) 
sub $sp, $sp, -4   # we adjust the stack for saving return address and argument

jr $ra

PRINT:
sub $sp, $sp, 4   # we adjust the stack for saving return address and argument
sw  $ra, 0($sp)   # stores the return address in stack


li $v0, 4
syscall 

lw  $ra, 0($sp)   # stores the argument in stack
addi $sp, $sp, 4

jr $ra


PRINT_INT:
li $v0, 1
syscall 
jr $ra


CONCAT:
sub $sp, $sp, 4   # we adjust the stack for saving return address and argument
sw  $ra, 0($sp)   # stores the return address in stack

sllv $s3, $s3, $s0
subi $s0, $s0, 4

or $s5, $s5, $s3

sw  $ra, 0($sp)   
sub $sp, $sp, -4   # we adjust the stack for saving return address and argument


jr $ra



CHAR_TO_NUM:
sub $sp, $sp, 8   # we adjust the stack for saving return address and argument
sw  $ra, 4($sp)   # stores the return address in stack
sw  $a0, 0($sp)   # stores the argument in stack


la $t0, test_data
lb $t2, 0($t0)
subi $t1, $t2, 48

#if statement to determine if the char is greater than 9
subi $t2, $t1, 10
slt $t3, $t2, $zero
beq $t3, 1, EXIT_IF_1

subi $t1, $t1, 39


EXIT_IF_1:

move $v0, $t1

sub $sp, $sp, -8  
jr $ra


Exit:
li $v0,10
syscall             #exits the program