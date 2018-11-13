.data
arr: 

bi_0: .word 0 : 100
bi_1: .word 0 : 100
bi_2: .word 0 : 100
bi_3: .word 0 : 100
bi_4: .word 0 : 100
bi_5: .word 0 : 100

bi_t0: .word 0 : 100
bi_t1: .word 0 : 100
bi_t2: .word 0 : 100
bi_t3: .word 0 : 100
bi_t4: .word 0 : 100
bi_t5: .word 0 : 100

.text
j main

# Initializes a new big integer
# $a0 - no. of bytes
make_bi:
	# addi $a0, $a0, 1
	addi $a0, $a0, -1
	div $a0, $a0, 4
	mul $a0, $a0, 4
	# convert to next 4 multiple, add 1 for storing size
	addi $a0, $a0, 2
	li	$v0,9			# To allocate a block of memory
	syscall				# $v0 <-- address
	addi $a0, $a0, -1
	sw $a0, 0($v0)
	jr $ra


# Initializes a new big integer 100 bytes long
make_bi_100:
	li $a0, 100
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal make_bi
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


# $a0 - stores character to convert
ascii_to_int:
	li $t1, 97
	slt $t0, $a0, $t1
	bne $t0, 0, ascii_to_int_if2
	addi $v0, $a0, -87
	jr $ra

	ascii_to_int_if2:
	li $t1, 65
	slt $t0, $a0, $t1
	bne $t0, 0, ascii_to_int_if3
	addi $v0, $a0, -55
	jr $ra

	ascii_to_int_if3:
	addi $v0, $a0, -48
	jr $ra


# Makes a big integer from a string
# $a0 - address of string
make_bi_from_str:
	
	jr $ra


add_bi_bi:
	jr $ra	

sub_bi_bi:
	jr $ra

mult_bi_bi:
	jr $ra

comp_bi_bi:
	jr $ra

main:
	la $t0, bi_a
	la $t1, bi_b
	
	