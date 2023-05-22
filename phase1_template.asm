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
    
addi $s0, $zero, 28 #ENVIRONMENT VARIABLE DO NOT USE S0 REGISTER


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

jal READ_CHAR
jal READ_CHAR



move $t3, $zero
LOOP_1:
	slti $t4, $t3, 3069
	beq $t4, $zero, EXIT_LOOP_1


	move $t4, $zero
	LOOP_2:
		slti $t5, $t4, 8
		beq $t5, $zero, EXIT_LOOP_2

		jal READ_CHAR
		move $a0, $v0
		jal PRINT

	EXIT_LOOP_2:

	move $t4, $zero
	LOOP_3:
		slti $t5, $t4, 4
		beq $t5, $zero, EXIT_LOOP_3

		#do nothing
		jal READ_CHAR

	EXIT_LOOP_3:

	

	addi $t3, $t3, 1
EXIT_LOOP_1:
jr $ra


READ_CHAR:
#open a file for writing
sub $sp, $sp, 4   # we adjust the stack for saving return address and argument
sw  $ra, 0($sp) 

li   $v0, 13       # system call for open file
la   $a0, fin      # file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, buffer   # address of buffer to which to read
li   $a2, 1     # hardcoded buffer length
syscall            # read from file

move $s0, $v0	   # the number of characters read from the file
la   $s1, buffer   # 

move $v0, $s1

sub $sp, $sp, -4   # we adjust the stack for saving return address and argument
lw  $ra, 0($sp) 



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
sub $sp, $sp, 4   # we adjust the stack for saving return address and argument
sw  $ra, 0($sp)   # stores the return address in stack


li $v0, 1
syscall 

lw  $ra, 0($sp)   # stores the argument in stack

jr $ra

CONCAT:
sub $sp, $sp, 12   # we adjust the stack for saving return address and argument
sw  $ra, 8($sp)   # stores the return address in stack
sw  $a0, 4($sp)   # stores the argument in stack
sw  $a1, 0($sp)   # stores the argument in stack

move $t0, $zero # integer to hold the concat result

sllv $a0, $a0, $s0
subi $s0, $s0, 4

sllv $a1, $a1, $s0
subi $s0, $s0, 4

or $t0, $t0, $a0
or $t0, $t0, $a1

move $v0, $t0

lw  $ra, 8($sp)   # stores the return address in stack
lw  $a0, 4($sp)   # stores the argument in stack
lw  $a1, 0($sp)   # stores the argument in stack
sub $sp, $sp, -12   # we adjust the stack for saving return address and argument

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

