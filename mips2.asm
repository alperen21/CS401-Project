.data

array1: .word 1, 1, 2, 2, 3, 3, 4, 4, 5, 5 
array2: .word 2, 2, 3, 3, 4, 4, 5, 5, 6, 6 

tempArray1: .space 40 #for storing different elements in array1
tempArray2: .space 40 #for storing different elements in array2


message: .asciiz "The sum of the same elements is "

.text

move $a0, $t5
	li $v0,1
	syscall
	li $a0, 32
        li $v0, 11
        syscall
