.data
bi_a: .asciiz "0123456789abc"
len_a: .word 13
bi_b: .asciiz "11000000000000001"
len_b: .word 17
ch: .ascii "0"
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
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	move $s0, $a0
	move $s1, $a1
	
	# make_bi with half the length given
	addi $a0, $a1, 1
	div $s4, $a0, 2
	move $a0, $s4
	jal make_bi
	# Save address of bi in $s3
	move $s3, $v0
	# get size in $s2
	lw $s2, 0($s3)

	# s4 - points to the last byte in array
	add $s4, $v0, $s4
	addi $s4, $s4, 3
	

	# Parity bit for loop
	andi $s5, $s1, 1
	# xori $s5, 1
	# move $s5, $0

	# Index of character to copy 
	move $s6, $0

	make_bi_from_str_loop_begin:
		# if $s1 <= 0, break_loop
		slti $t0, $s1, 1
		# if ($s1 < 1) != 0, break_loop
		bne $t0, $0, make_bi_from_str_break_loop
		addi $s1, $s1, -1
		# t2 - Address of character to copy
		add $t2, $s0, $s6
		addi $s6, $s6, 1
		# Load char into $a0
		lb $a0, 0($t2)
		# Convert to int
		jal ascii_to_int
		# Store int in the last byte of array if parity bit is 0
		bne $s5, $0, make_bi_from_str_else1
			lb $t0, 0($s4)
			mul $v0, $v0, 16
			add $t0, $t0, $v0
			sb $t0, 0($s4)
			li $s5, 1
			j make_bi_from_str_after_else1
		# Else store it in the upper half of the byte
		make_bi_from_str_else1:
			lb $t0, 0($s4)
			add $t0, $t0, $v0
			sb $t0, 0($s4)
			addi $s4, $s4, -1
			li $s5, 0
		make_bi_from_str_after_else1:

		j make_bi_from_str_loop_begin

	make_bi_from_str_break_loop:
	# move $t0, $v0
	# Return address of bi
	move $v0, $s3
	lw $s6, 28($sp)
	lw $s5, 24($sp)
	lw $s4, 20($sp)
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 32
	jr $ra

# $a0, $a1, $a2 are added
# $v0 - Lower half of sum
# $a0 - Upper half of sum (carry)
add_3_words:
	addu $t1, $a0, $a1
	sltu $t0, $t1, $a0    # set carry-in bit
	addu $v0, $t1, $a2
	sltu $t2, $v0, $t1    # set carry-in bit
	addu $a0, $t0, $t2     # Add carry bits
	jr $ra

# $a0 - first bi
# $a1 - second bi
add_bi_bi:
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)

	move $s5, $a0
	move $s6, $a1

	# find sizes of bi
	lw $s0, 0($a0)
	lw $s1, 0($a1)
	# put the bigger of the sizes in $s3
	move $s3, $s1
	slt $t0, $s3, $s0
	# if $s3 not less than $s0, goto skip_if1
	beq $t0, $0, add_bi_bi_skip_if1
	move $s3, $s0
	add_bi_bi_skip_if1:
	addi $s3, $s3, 4
	# make a new bi with this size + 4
	move $a0, $s3
	jal make_bi
	move $s4, $v0
	lw $s3, 0($v0)
	# Make byte-sizes word-sizes
	div $s0, $s0, 4
	div $s1, $s1, 4
	div $s3, $s3, 4

	# Loop counter
	move $s2, $0
	move $a0, $0
	# while s2 < s3
	add_bi_bi_loop_begin:
	slt $t0, $s2, $s3
	beq $t0, $0, add_bi_bi_break_loop
		# $a1, $a2 <= lw((4 * $s2 + 4)+($s<>))
		# $a0 <= carry
		mul $t0, $s2, 4
		addi $t0, $t0, 4
		move $a1, $0
		move $a2, $0
		# if s2 < s0, lw from $s5
		slt $t1, $s2, $s0
		beq $t1, $0, add_bi_bi_skip_else1
			add $t1, $t0, $s5
			lw $a1, 0($t1)
		add_bi_bi_skip_else1:
		# if s2 < s1, lw from $s6
		slt $t1, $s2, $s1
		beq $t1, $0, add_bi_bi_skip_else2
			add $t1, $t0, $s6
			lw $a2, 0($t1)
		add_bi_bi_skip_else2:
		# Store the sum in the new bi
		addi $sp, $sp, -4
		sw $t0, 0($sp)
		jal add_3_words
		lw $t0, 0($sp)
		addi $sp, $sp, 4
		# add $t1, $v0, $t0
		# add $t1, $t1, $s4
		# sw $t0, 0($t1)
		add $t1, $t0, $s4
		sw $v0, 0($t1)
		addi $s2, $s2, 1
		j add_bi_bi_loop_begin
	add_bi_bi_break_loop:
	move $v0, $s4
	lw $s6, 28($sp)
	lw $s5, 24($sp)
	lw $s4, 20($sp)
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 32
	jr $ra


main:
      #la $a0, ch
      #lb $a0, 0($a0)
      #jal ascii_to_int
      #jal make_bi_100
      #jal make_bi_100
      la $a0, bi_a
      la $a1, len_a
      lw $a1, 0($a1)
      jal make_bi_from_str
      move $s0, $v0

      la $a0, bi_b
      la $a1, len_b
      lw $a1, 0($a1)
      jal make_bi_from_str
      move $s1, $v0
      
      move $a0, $s0
      move $a1, $s1
      jal add_bi_bi
      
	li   $v0, 10          # system call for exit
	syscall