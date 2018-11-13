.data
bi_a: .asciiz "1a234"
ch: .ascii "0"
len: .word 5
.text
j main

# Initializes a new big integer
# $a0 - no. of bytes
make_bi:
	# addi $a0, $a0, 1
	addi $a0, $a0, -1
	div $a0, $a0, 4
	mul $a0, $a0, 4
	# convert to next 4 multiple, add 4 for storing size
	addi $a0, $a0, 8
	li	$v0,9			# To allocate a block of memory
	syscall				# $v0 <-- address
	addi $a0, $a0, -4
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
# $a1 - length of string
make_bi_from_str:
	# $t0 - bi
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	move $s0, $a0
	move $s1, $a1
	
	# make_bi with length given
	move $a0, $a1
	jal make_bi
	# Save address of bi in $s3
	move $s3, $v0
	# get size in $s2
	lw $s2, 0($s3)

	# s4 - points to the last byte in array
	addi $s4, $v0, 3
	add $s4, $s4, $s2

	make_bi_from_str_loop_begin:
		# if $s1 <= 0, break_loop
		slti $t0, $s1, 1
		# if ($s1 < 1) != 0, break_loop
		bne $t0, $0, make_bi_from_str_break_loop
		addi $s1, $s1, -1
		# t2 - Address of character to copy
		add $t2, $s0, $s1
		# Load char into $a0
		lb $a0, 0($t2)
		# Convert to int
		jal ascii_to_int
		# Store int in the last byte in array
		sb $v0, 0($s4)
		addi $s4, $s4, -1
		j make_bi_from_str_loop_begin

	make_bi_from_str_break_loop:
	# move $t0, $v0
	# Return address of bi
	move $v0, $s3
	lw $s4, 20($sp)
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra

main:
      #la $a0, ch
      #lb $a0, 0($a0)
      #jal ascii_to_int
      #jal make_bi_100
      #jal make_bi_100
      la $a0, bi_a
      la $a1, len
      lw $a1, 0($a1)
      jal make_bi_from_str
      
	li   $v0, 10          # system call for exit
	syscall
