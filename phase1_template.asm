.data  
T0: .space 4                           # the pointers to your lookup tables
T1: .space 4                           
T2: .space 4                           
T3: .space 4                           
Hexa: .word "0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "1001", "1010", "1011", "1100", "1101", "1110", "1111"
fin: .asciiz "/Users/alperenyildiz/CS401-Project/tables.dat"      # put the fullpath name of the file AES.dat here
buffer: .space 5000                    # temporary buffer to read from file


temp: .space 5000

char_zero: .asciiz "0"
char_a: .asciiz "a"

.text
#open a file for writing
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
la   $s1, buffer   # address of buffer that keeps the characters


# your code goes here

CONCAT:
	#a0 is the first string
	#a1 is the second string
	#a2 is the buffer string

HEXA_TO_BINARY:

	#a0 is input which is a string of a hexadecimal number

	### start function ###
	sub $sp, $sp, 8
	sw  $ra, 4($sp)
	sw  $a0, 0($sp)
	### start function ###
	
	la $t3, char_zero       # Load the address of the character "0" into $t0
        lb $s1, ($t3)      # Load the ASCII value of the character into $t1


	la $t4, char_a       # Load the address of the character "0" into $t0
        lb $s2, ($t4)      # Load the ASCII value of the character into $t1


	
	### start loop ###
	move $t0, $zero
	Loop1: slti $t1, $t0, 9
	beq $t1, $zero, Exit1 
	### start loop ###
	
	
		#$t2 = input[i]
		sll $t2, $t0, 2 #4i
		add $t2, $t2, $a0 #base + 4i
		lw $t2, 0($t2) #t2 = array[i]
		#$t2 = input[i]
		
		sub $t3, $t2, $s1 #if the character is 0-9 then this will be its integer value if not, it will be greater than 9
		
		### start if ### 
		slti $t4, $t3, 10
		bne $t4, $zero , EXIT_IF_1
		### start if ###
		
			sub $t3, $t2, $s2 #if the character is 0-9 then this will be its integer value if not, it will be greater than 9
			addi $t3, $t3, 10
			
		### end if ###
		EXIT_IF_1:
		### end if ###
		
		
		### get ith element of Hexa look up ###
		la $s3, Hexa
		sll $t3, $t3, 2
		addi $t3, $s3, $t3
		### get ith element of Hexa look up ###
		
		
		la $t4, temp
		add $a0, $t4, $zero
		add $a1, $t3, $zero
		add $a2, $t4, $zero
		
		jal CONCAT
		
		lw $a0, 0($sp)
		lw $ra, 8($sp)
			
	
	### end loop ###
	Exit1:
	### end loop ###
	

	
	
	
	### end function ###
	lw $a0, 0($sp)
	lw $ra, 8($sp)
	add $sp, $sp, 8
	jr $ra
	### end function ###


Exit:
li $v0,10
syscall             #exits the program

