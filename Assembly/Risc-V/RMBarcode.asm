#-------------------------------------------------------------------------------
#author: Damian Kowalczyk
#data : 2023.01.10
#description :  RISC V program which decodes RM4SCC barcode 
#-------------------------------------------------------------------------------
.eqv BMP_FILE_SIZE 90122
.eqv BYTES_PER_ROW 1800

	.data
.align 4
res:	.space 2
image:	.space BMP_FILE_SIZE
fname:	.asciz "source.bmp"
result: .space 200
	.text
main:
	jal	read_bmp		
	li	a0, 0		#x and colour register
	li	a5, 0		#x counter
	li 	a6, 0		#distance between symbols
	li	a1, 35		#y
	li	s4, 600		#bitmap limit
	li	s5, 6		#
	li 	a3,0x00000000	#black color saved 
	la 	a2,result	#adress where we save the result
	
find_start:		#This branch seeks for the first black pixel in the middle line	
	addi a0,a5,0	
	jal     get_pixel
	beq a0, a3,check_start	
	addi a5,a5,1
	bgt a5,s4,exit
	j find_start

check_start:		#This branch checks whether the black pixel is also in the top line to confirm start symbol	
	addi a0,a5,0
	li a1,40
	jal     get_pixel
	beq a0, a3,count_distancefirst
	j find_start 

count_distancefirst:	#Here we count the distance between the symbols 
	add a0,a5,a6
	li	a1, 35
	jal     get_pixel
	bne a0, a3,count_distancesecond
	addi a6,a6,1
	j count_distancefirst

count_distancesecond:
	add a0,a5,a6
	li	a1, 35
	jal     get_pixel
	beq a0, a3,setup_char
	addi a6,a6,1
	j count_distancesecond

setup_char:
	add a5,a5,a6		
	j start_reading_top
	
start_reading_top:	#This branch decodes top part of the 4 next symbols
	addi a0,a5,0
	li a1,40
	jal     get_pixel
	bne a0, a3,first_top_zero			
	beq a0, a3,first_top_one

first_top_one:
	add a0,a5,a6
	li a1,40
	jal     get_pixel			
	bne a0, a3,second_top_onezero			
	beq a0, a3,second_top_oneone

second_top_oneone:
	li t5,6
	j start_reading_bottom

second_top_onezero:
	add a0,a5,a6
	add a0,a0,a6
	li a1,40
	jal     get_pixel			
	bne a0, a3,third_top_zerozero			
	beq a0, a3,third_top_zeroone

third_top_zerozero:
	li t5,4
	j start_reading_bottom

third_top_zeroone:
	li t5,5
	j start_reading_bottom

first_top_zero:
	add a0,a5,a6
	li a1,40
	jal     get_pixel			
	bne a0, a3,second_top_zero			
	beq a0, a3,second_top_one	
	
second_top_zero:	
	li t5,1
	j start_reading_bottom
	
second_top_one:
	add a0,a5,a6
	add a0,a0,a6
	li a1,40
	jal     get_pixel			
	bne a0, a3,third_top_zero			
	beq a0, a3,third_top_one

third_top_zero:
	li t5,2
	j start_reading_bottom
	
third_top_one:
	li t5,3
	j start_reading_bottom

start_reading_bottom:	#This branch decodes bottom part of the 4 next symbols
	addi a0,a5,0
	li a1,29
	jal     get_pixel
	bne a0, a3,first_bottom_zero			
	beq a0, a3,first_bottom_one	

first_bottom_zero:
	add a0,a5,a6
	li a1,29
	jal     get_pixel			
	bne a0, a3,second_bottom_zerozero			
	beq a0, a3,second_bottom_zeroone		
	
second_bottom_zerozero:
	li t4,1
	j store_character	
	
second_bottom_zeroone:
	add a0,a5,a6
	add a0,a0,a6
	li a1,29
	jal     get_pixel			
	bne a0, a3,third_bottom_onezero			
	beq a0, a3,third_bottom_oneone
	
third_bottom_onezero:
	li t4,2
	j store_character
	
third_bottom_oneone:
	li t4,3
	j store_character

first_bottom_one:
	add a0,a5,a6
	li a1,29
	jal     get_pixel			
	bne a0, a3,second_bottom_zero			
	beq a0, a3,second_bottom_one
	
second_bottom_zero:
	add a0,a5,a6
	add a0,a0,a6
	li a1,29
	jal     get_pixel			
	bne a0, a3,third_bottom_zero			
	beq a0, a3,third_bottom_one
	
second_bottom_one:
	li t4,6
	j store_character
	
third_bottom_zero:	
	li t4,4
	j store_character
	
third_bottom_one:	
	li t4,5
	j store_character
	
store_character:	#This branch stores the character according to ascii table 
	addi t5,t5,-1 
	mul t5,t5,s5
	add t4,t4,t5
	li t6,11
	bge t4,t6,alphabet_chars
	blt  t4,t6,numeric_chars
	
numeric_chars:
	addi t4,t4,47
	sb t4 (a2)
	addi a2,a2,1
	j before_next_char

alphabet_chars:
	addi t4,t4,54
	sb t4 (a2)
	addi a2,a2,1
	j before_next_char

before_next_char:	#This branch checks whether the next symbol is not a check symbol which is not printed 
	li t5,4
	mul t6,a6,t5
	add a5,a5,t6
	bgt a5,s4,exit
	add t6,t6,a6
	add a0,a5,t6
	bgt a0,s4,exit
	li a1,35
	jal     get_pixel
	bne  a0, a3,exit
	j start_reading_top

exit:	
	li a7,4
	la a0,result		#Print the resulting string
	ecall

	li 	a7,10		#Terminate the program
	ecall

# ============================================================================
read_bmp:
#description: 
#	reads the contents of a bmp file into memory
#arguments:
#	none
#return value: none
	addi sp, sp, -4		#push $s1
	sw s1, 0(sp)
#open file
	li a7, 1024
        la a0, fname		#file name 
        li a1, 0		#flags: 0-read file
        ecall
	mv s1, a0      # save the file descriptor
	
#read file
	li a7, 63
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

#close file
	li a7, 57
	mv a0, s1
        ecall
	
	lw s1, 0(sp)		#restore (pop) s1
	addi sp, sp, 4
	jr ra


# ============================================================================
get_pixel:
#description: 
#	returns color of specified pixel
#arguments:
#	a0 - x coordinate
#	a1 - y coordinate - (0,0) - bottom left corner
#return value:
#	a0 - 0RGB - pixel color

	la t1, image		#adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2		#adress of pixel array in $t2
	
	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 		#t1= y*BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0		#$t3= 3*x
	add t1, t1, t3		#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1	#pixel address 
	
	#get color
	lbu a0,(t2)		#load B
	lbu t1,1(t2)		#load G
	slli t1,t1,8
	or a0, a0, t1
	lbu t1,2(t2)		#load R
        slli t1,t1,16
	or a0, a0, t1
					
	jr ra

# ============================================================================