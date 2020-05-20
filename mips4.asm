# Bailee Miller 
# 2001224727 
# CS 218, MIPS Assignment #4
# Provided template.

#  In recreational mathematics, a Magic Square is an
#  arrangement of numbers (usually integers) in a square
#  grid, where the numbers in each row, and in each column,
#  and the numbers in the forward and backward main diagonals,
#  all add up to the same number.  A magic square has the same
#  number of rows as it has columns, typically referred to as
#  the order.  A magic square that contains the integers
#  from 1 to n^2 is called a normal magic square.

#  This program creates odd-order normal magic squares.


###########################################################
#  data segment

.data

# -----
#  Define constants.

TRUE = 1
FALSE = 0

ORDER_MIN = 3
ORDER_MAX = 25

# -----
#  Define variables for main.

hdr:		.ascii	"\nMIPS Assignment #4 \n"
		.asciiz	"Program to create an odd-order magic square. \n\n"

doneMsg:	.ascii	"\nThanks for playing.\n"
		.asciiz	"Program Terminated.\n"

msOrder:	.word	0

# -----
#  Local variables for createMagicSquare() function.

errMsg:		.ascii	"\nError, invalid order.  "
		.asciiz	"Unable to create magic square.\n"

# -----
#  Local variables for displaySquare() function.

MSheader:	.ascii	"\n***************************************"
		.ascii	"***************************************** \n"
MStitle:	.asciiz	"Magic Square: "

orderMsg:	.asciiz	"Order : "
sumMsg:		.asciiz "Sum: "

blnks1:		.asciiz	" "
blnks2:		.asciiz	"  "
blnks3:		.asciiz	"   "
blnks4:		.asciiz	"    "

newLine:	.asciiz	"\n"

# -----
#  Local variables for readOrder() function.

msPmt:		.asciiz	"Enter Order for Odd-Order Magic Square: "

errBadValue:	.ascii	"Error, order must be >=3 and odd. "
		.asciiz "Please re-enter. \n\n"

spc:		.asciiz	"   "

# -----
#  Local variables for doAnother() function.

qPmt:		.asciiz	"\nCreate another magic square (y/n)? "
ansErr:		.asciiz	"Error, must answer with (y/n)."

ans:		.space	12


########################################################################
#  text/code segment

.text

.globl main
.ent main
main:

# -----
#  Display main program header.

	la	$a0, hdr
	li	$v0, 4
	syscall					# print header

# -----
#  Read order, create magic square, display magic square.

	li	$s0, 1
mainLoop:
	la	$a0, msOrder
	jal	readOrder

	move	$s2, $v0			# save address of array

	move	$a0, $s2
	lw	$a1, msOrder
	jal	createMagicSquare

	la $a0, msOrder
	jal calcMagicSquareOrder

	move $s3, $v0 

	move	$a0, $s2
	lw	$a1, msOrder
	move	$a2, $s3
	jal	displayMagicSquare

	add	$s0, $s0, 1

# -----
#  See if user wants to do another?

	jal	doAnother
	beq	$v0, TRUE, mainLoop

# -----
#  Done, terminate program.

	la	$a0, doneMsg
	li	$v0, 4
	syscall					# print header

	li	$v0, 10
	syscall
.end main

# ----------------------------------------------------------------------
#  Function to read magic square order from user.

#  Prompt for, read, and verify the order for a magic square.
#  Ensure that order is between ORDER_MIN and ORDER_MAX and is odd.
#  If orderis not valid, re-prompt until a valid number is provided.
#  Once order is valid, allocate necessary memory for a two-dimensional
#  array (order x order) size for word (4-byte) values.

#  Note, uses read intger and allocate memory syscalls.
# -----
#    Arguments:
#	$a0, magic square order, address
#    Returns:
#	$v0 - address of allocated memory

.globl	readOrder
.ent	readOrder
readOrder:
	promtUser: 
		la $a0, msPmt		# prompt user to enter an order
		li $v0, 4 
		syscall 

		li $v0, 5 			#read value entered by user 
		syscall 

		move $t0, $v0 		# move value from $v0

		la $t2, msOrder		# save order value 
		sw $t0, ($t2) 

		bgt $t0, ORDER_MAX, numError 	#check if above max
		blt $t0, ORDER_MIN, numError	#check if below min

		div	$t1, $t0, 2						#check if value is odd
		mfhi $t1
		beq $t1, 0, numError

		mul $t0, $t0, $t0 		# rows x columns
		mul $a0, $t0, 4			# byte needed 

		li $v0, 9				# allocate heap memory 
		syscall 				# $v0 will have the address of the allocated memory 

		j doneReading 

	numError: 
		la $a0, errBadValue
		li $v0, 4 
		syscall 
		j promtUser 

	doneReading: 
		jr	$ra

.end	readOrder
# ----------------------------------------------------------------------
#  Function to create an odd-order normal magic square.
# -----
#  Formula for multiple dimension array indexing:
#	addr(row,col) = base_address + (rowIndex * order + colIndex) * elementSize

# -----
#  Arguments
#	$a0 - empty magic sqaure, address
#	$a1 - magic square order, value

.globl	createMagicSquare
.ent	createMagicSquare
createMagicSquare:
	move $t0, $a0 		# arr address 
	move $t1, $a1 		# order 

	mul $s0, $t1, $t1 	# this will be the largest number in the square 

	li $t2, 1
	sub $t6, $t1, 1 	# store the number of rows and cols 

	subu $t3, $t1, 1 	# rowIndex 
	div $t4, $t1, 2		# colIndex

	mul $t5, $t3, $t1 		# (rowIndex * order 
	addu $t5, $t5, $t4 		# + colIndex)
	mul $t5, $t5, 4 		# * elementSize 			
	 
	addu $t5, $t0, $t5 		# + base_address

	sw $t2, ($t5) 		#store 1 in the middle of the top row 

	fillMagicSquareLoop:
		addu $t2, $t2, 1			# k + 1
		bgt $t2, $s0, doneCreatingSquare 

		addu $t3, $t3, 1 			# go up a row
		addu $t4, $t4, 1 			# move a column to the right

		bgt $t3, $t6, aboveTopRow 		# check if above box
		bgt $t4, $t6, rightOfSquare 	# check if to the right of box 

		mul $t5, $t3, $t1 			# (rowIndex * order  
		addu $t5, $t5, $t4 			# + colIndex)
		mul $t5, $t5, 4 			# * elementSize 

		addu $t5, $t0, $t5 			# + base_address

		lw $t7, ($t5)				# check to see if square is filled 
		bne $t7, 0, squareFilled

		sw $t2, ($t5)

		j fillMagicSquareLoop 
		
		aboveTopRow:
			bgt $t4, $t6, rightCorner 

			li, $t3, 0				# set to bottom row 

			mul $t5, $t3, $t1 		# (rowIndex * order  
			addu $t5, $t5, $t4 		# + colIndex)
			mul $t5, $t5, 4 		# * elementSize 

			addu $t5, $t0, $t5 		# + base_address

			lw $t7, ($t5)			# check to see if square is filled 
			bne $t7, 0, squareFilled 

			sw $t2, ($t5)

			j fillMagicSquareLoop 		

		rightOfSquare: 
			li $t4, 0				# set to left-most column

			mul $t5, $t3, $t1 		# (rowIndex * order 
			addu $t5, $t5, $t4 		# + colIndex)
			mul $t5, $t5, 4 		# * elementSize 

			addu $t5, $t0, $t5 		# + base_address

			lw $t7, ($t5)			# check to see if square is filled 
			bne $t7, 0, squareFilled

			sw $t2, ($t5)	

			j fillMagicSquareLoop 

		rightCorner: 
			subu $t3, $t3, 2		# set to two rows down
			subu $t4, $t4, 1		# set to one column to the left 

			mul $t5, $t3, $t1 		# (rowIndex * order 
			addu $t5, $t5, $t4 		# + colIndex)
			mul $t5, $t5, 4 		# * elementSize 

			addu $t5, $t0, $t5 		# + base_address

			lw $t7, ($t5)			# check to see if square is filled 
			bne $t7, 0, squareFilled

			sw $t2, ($t5)

			j fillMagicSquareLoop

		squareFilled: 
			subu $t3, $t3, 2		# go down two rows b/c we have already incremented the rows  
			subu $t4, $t4, 1		# go left one row b/c we have already icremented the cols

			mul $t5, $t3, $t1 		# (rowIndex * order 
			addu $t5, $t5, $t4 		# + colIndex)
			mul $t5, $t5, 4 		# * elementSize

			addu $t5, $t0, $t5 		# + base_address

			lw $t7, ($t5)			# check to see if square is filled 
			bne $t7, 0, squareFilled

			sw $t2, ($t5)

			j fillMagicSquareLoop

	doneCreatingSquare:

	jr	$ra
.end createMagicSquare

# ----------------------------------------------------------------------
#  Function to calulate the sum for an odd-order normal magic square.

#  Formula:
#	sum = order (order^2 +1) / 2

# -----
#  Arguments
#	$a0 - magic square order, value

# -----
#  Returns
#	$v0 - sum, value

.globl	calcMagicSquareOrder
.ent	calcMagicSquareOrder
calcMagicSquareOrder:
	lw $t0, ($a0) 
	lw $t1, ($a0)

	mul $t2, $t0, $t0		# order^2
	addu $t2, $t2, 1		# 	+ 1
	mul $t2, $t1, $t2		# order (order^2) + 1
	div $t2, $t2, 2			#	/ 2

	move $v0, $t2 		

	jr	$ra
.end	calcMagicSquareOrder

# ----------------------------------------------------------------------
#  Function to print a formatted magic square.
#  Note, a magic square is an (order x order) two-dimensional array.

#  Arguments:
#	$a0 - magic square to display, address
#	$a1 - order (size) of the square, value
#	$a2 - magic square number, value

.globl	displayMagicSquare
.ent	displayMagicSquare
displayMagicSquare:
	move $s0, $a0 		# move array address into $t0
	move $s1, $a1 		# order = $t1 
	move $s2, $a2 		# sum = $t2 

	la $a0, orderMsg		# print 'order: ' 
	li $v0, 4 
	syscall 

	move $a0, $s1			
	li $v0, 1
	syscall 

	la $a0, newLine 		# print a new line 
	li $v0, 4
	syscall 

	la $a0, sumMsg			# print 'sum: '
	li $v0, 4 
	syscall 

	move $a0, $s2 
	li $v0, 1 
	syscall

	la $a0, newLine 		# print a new line 
	li $v0, 4
	syscall 

	la $a0, newLine 		# print a new line 
	li $v0, 4
	syscall 

	#--------------------
	# Begin Printing Array 

	mul $s3, $s1, $s1 
	mul $s3, $s3, 4

	mul $s4, $s1, 4 		
	
	li $t0, 1				# outer loop counter for offset 

	outerLoop:
		mul $t1, $s4, $t0 				# calc offset 
		bgt $t1, $s3, donePrinting 		# check if offset greater than last element in array 

		subu $t3, $s3, $t1				# subtract offset 

		li $t4, 0						# inner loop counter

		innerLoop:
			addu $s5, $s0, $t3 

			lw $t5 ($s5) 				# strore value in register
			move $s6, $t5 

			li $t7, 0			
			spaceLoop:					# calculate how many spaces are necessary to print before the value
				divu $t6, $s6, 10  		
				addu $t7, $t7, 1
				move $s6, $t6 
				bne $t6, 0, spaceLoop 

			beq $t7, 4, oneBlank		
			beq $t7, 3, twoBlanks
			beq $t7, 2, threeBlanks
			beq $t7, 1, fourBlanks

			oneBlank:
				la $a0, blnks1 		
				li $v0, 4 
				syscall 

				move $a0, $t5 			# print value 		
				li $v0, 1 
				syscall

				j nextValue

			twoBlanks:
				la $a0, blnks2 		
				li $v0, 4 
				syscall 

				move $a0, $t5 			# print value 		
				li $v0, 1
				syscall

				j nextValue

			threeBlanks:
				la $a0, blnks3 		
				li $v0, 4 
				syscall

				move $a0, $t5 			# print value 		
				li $v0, 1 
				syscall

				j nextValue

			fourBlanks:
				la $a0, blnks4 		
				li $v0, 4 
				syscall

				move $a0, $t5 			# print value 		
				li $v0, 1 
				syscall

				j nextValue

			nextValue: 
				addu $t4, $t4, 1			# add one to inner loop counter 
				addu $t3, $t3, 4 			# i++ for array 
				beq $t4, $s1, printNewLine
				j innerLoop 

			printNewLine:
				addu $t0, $t0 1		

				la $a0, newLine 		# print a new line 
				li $v0, 4
				syscall 

				j outerLoop

	donePrinting:
		jr $ra 

.end displayMagicSquare

# ----------------------------------------------------------------------
#  Function to ask user if they want to do another magic square.

#  Basic flow:
#	prompt user
#	read user answer (as character)
#		if y -> return TRUE
#		if n -> return FALSE
#	otherwise, display error and re-prompt

#  Note, uses read string syscall.

# -----
#  Arguments:
#	none
#  Returns:
#	$v0 - TRUE/FALSE

.globl	doAnother
.ent	doAnother
doAnother: 
	promptUser1:
		la $a0, qPmt		# ask user if they want to create another square
		li $v0, 4
		syscall 

		la $a0, ans  		# read string 
		li $a1, 6 
		li $v0, 8		
		syscall 

		move $t0, $a0
		lb $t1, ($t0)
		li $t2, 'n' 
		beq $t1, $t2, donePlaying 

		li $t2, 'y'
		beq $t1, $t2, playAgain

		la $a0, ansErr
		li $v0, 4
		syscall 

		j promptUser1 
		
		playAgain:
			addu $t0, $a0, 2		# check that a null follows 'y'
			lb $t1, ($t0)
			li $t2, '\n'
			bne $t1, $t2, exitProgram 

			li $v0, 1
			j exitProgram 

		donePlaying: 
			li $v0, 0
		
	exitProgram: 
		jr	$ra

.end	doAnother

# ----------------------------------------------------------------------

